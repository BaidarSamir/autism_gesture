from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os
import torch
import cv2
import numpy as np
from PIL import Image
import torchvision.transforms as transforms
import torch.nn as nn
import torchvision.models as models
from typing import Dict
import tempfile
import uuid
import logging
import shutil

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPI app
app = FastAPI(title="Autism Gesture Detection API")

# CORS configuration for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust in production to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Device setup
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
logger.info(f"Using device: {device}")

# Configuration (from your original code)
CONFIG = {
    'SEQUENCE_LENGTH': 16,
    'IMG_SIZE': (224, 224),
    'GESTURE_NAMES': ['ArmFlapping', 'HeadBanging', 'Spinning']
}

# Your BinaryGestureClassifier model (from your code)
class BinaryGestureClassifier(nn.Module):
    def __init__(self, sequence_length=16, dropout=0.3):
        super(BinaryGestureClassifier, self).__init__()
        self.backbone = models.resnet18(pretrained=True)
        self.backbone.fc = nn.Identity()
        for param in list(self.backbone.parameters())[:-10]:
            param.requires_grad = False
        self.feature_dim = 512
        self.sequence_length = sequence_length
        self.temporal = nn.LSTM(
            input_size=self.feature_dim,
            hidden_size=128,
            num_layers=1,
            batch_first=True,
            dropout=dropout,
            bidirectional=True
        )
        self.attention = nn.Sequential(
            nn.Linear(256, 64),
            nn.Tanh(),
            nn.Linear(64, 1)
        )
        self.classifier = nn.Sequential(
            nn.Dropout(dropout),
            nn.Linear(256, 64),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(64, 2)
        )

    def forward(self, x):
        batch_size, seq_len, C, H, W = x.shape
        x = x.view(batch_size * seq_len, C, H, W)
        features = self.backbone(x)
        features = features.view(batch_size, seq_len, self.feature_dim)
        lstm_out, _ = self.temporal(features)
        attention_weights = self.attention(lstm_out)
        attention_weights = torch.softmax(attention_weights, dim=1)
        attended_features = torch.sum(lstm_out * attention_weights, dim=1)
        output = self.classifier(attended_features)
        return output

# Your AutismGestureDataset (from your code)
class AutismGestureDataset:
    def __init__(self, video_paths, labels, transform=None, sequence_length=16, img_size=(224, 224), mode='test'):
        self.video_paths = video_paths
        self.labels = labels
        self.transform = transform
        self.sequence_length = sequence_length
        self.img_size = img_size
        self.mode = mode

    def __len__(self):
        return len(self.video_paths)

    def extract_keyframes(self, video_path):
        cap = cv2.VideoCapture(video_path)
        frames = []
        motion_scores = []
        all_frames = []
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_resized = cv2.resize(frame_rgb, self.img_size)
            all_frames.append(frame_resized)
        cap.release()

        if len(all_frames) == 0:
            return None

        for i in range(1, len(all_frames)):
            frame1_gray = cv2.cvtColor(all_frames[i-1], cv2.COLOR_RGB2GRAY)
            frame2_gray = cv2.cvtColor(all_frames[i], cv2.COLOR_RGB2GRAY)
            try:
                flow = cv2.calcOpticalFlowPyrLK(
                    frame1_gray, frame2_gray,
                    np.array([[x, y] for x in range(0, frame1_gray.shape[1], 20)
                             for y in range(0, frame1_gray.shape[0], 20)], dtype=np.float32).reshape(-1, 1, 2),
                    None
                )[0]
                motion = np.mean(np.sqrt(np.sum(flow**2, axis=2))) if flow is not None else 0
            except:
                motion = 0
            motion_scores.append(motion)

        if len(all_frames) <= self.sequence_length:
            selected_frames = all_frames.copy()
            while len(selected_frames) < self.sequence_length:
                selected_frames.extend(all_frames[:min(len(all_frames), self.sequence_length - len(selected_frames))])
            frames = selected_frames[:self.sequence_length]
        else:
            if len(motion_scores) > 0:
                high_motion_indices = np.argsort(motion_scores)[-self.sequence_length//2:]
                uniform_indices = np.linspace(0, len(all_frames)-1, self.sequence_length//2, dtype=int)
                combined_indices = sorted(set(list(high_motion_indices) + list(uniform_indices)))
                if len(combined_indices) >= self.sequence_length:
                    indices = combined_indices[:self.sequence_length]
                else:
                    remaining = self.sequence_length - len(combined_indices)
                    extra_indices = np.linspace(0, len(all_frames)-1, remaining, dtype=int)
                    indices = sorted(set(list(combined_indices) + list(extra_indices)))[:self.sequence_length]
            else:
                indices = np.linspace(0, len(all_frames)-1, self.sequence_length, dtype=int)
            frames = [all_frames[i] for i in indices]

        return frames

    def __getitem__(self, idx):
        video_path = self.video_paths[idx]
        frames = self.extract_keyframes(video_path)
        if frames is None:
            frames = [np.zeros((*self.img_size, 3), dtype=np.uint8) for _ in range(self.sequence_length)]
        transformed_frames = []
        for frame in frames:
            frame_pil = Image.fromarray(frame.astype('uint8'))
            transformed_frame = self.transform(frame_pil)
            transformed_frames.append(transformed_frame)
        while len(transformed_frames) < self.sequence_length:
            transformed_frames.append(transformed_frames[-1])
        transformed_frames = transformed_frames[:self.sequence_length]
        video_tensor = torch.stack(transformed_frames)
        return video_tensor, torch.tensor(0, dtype=torch.long)

# Your AutismGestureEnsemble (from your code)
class AutismGestureEnsemble:
    def __init__(self, models_dict, gesture_names, threshold=0.5):
        self.models = models_dict
        self.gesture_names = gesture_names
        self.threshold = threshold
        for model in self.models.values():
            model.eval()

    def predict_single_video(self, video_path, return_details=False):
        transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        temp_dataset = AutismGestureDataset(
            [video_path], [0], transform=transform,
            sequence_length=CONFIG['SEQUENCE_LENGTH'],
            img_size=CONFIG['IMG_SIZE'], mode='test'
        )
        video_tensor, _ = temp_dataset[0]
        video_tensor = video_tensor.unsqueeze(0).to(device)
        results = {}
        detected_gestures = []
        with torch.no_grad():
            for gesture_name, model in self.models.items():
                outputs = model(video_tensor)
                probabilities = torch.softmax(outputs, dim=1)
                confidence = probabilities[0, 1].item()
                results[gesture_name] = {
                    'confidence': confidence,
                    'detected': confidence > self.threshold
                }
                if confidence > self.threshold:
                    detected_gestures.append({
                        'gesture': gesture_name,
                        'confidence': confidence
                    })
        detected_gestures.sort(key=lambda x: x['confidence'], reverse=True)
        prediction = {
            'has_autism_gesture': len(detected_gestures) > 0,
            'detected_gestures': detected_gestures,
            'primary_gesture': detected_gestures[0]['gesture'] if detected_gestures else None,
            'max_confidence': detected_gestures[0]['confidence'] if detected_gestures else 0.0,
            'all_confidences': results
        }
        if return_details:
            prediction['video_path'] = video_path
            prediction['threshold'] = self.threshold
        return prediction

# Load ensemble model at startup
def load_ensemble_model(model_path='./models/autism_gesture_ensemble.pth', threshold=0.5):
    if not os.path.exists(model_path):
        logger.error(f"Model file not found: {model_path}")
        return None
    ensemble_data = torch.load(model_path, map_location=device)
    gesture_names = ensemble_data['gesture_names']
    models_dict = {}
    for gesture_name in gesture_names:
        model = BinaryGestureClassifier(
            sequence_length=ensemble_data['config']['SEQUENCE_LENGTH']
        ).to(device)
        model.load_state_dict(ensemble_data['model_states'][gesture_name])
        model.eval()
        models_dict[gesture_name] = model
        logger.info(f"Loaded {gesture_name} classifier")
    ensemble = AutismGestureEnsemble(models_dict, gesture_names, threshold)
    logger.info(f"Ensemble model loaded: {model_path}")
    return ensemble

# Global ensemble model
ensemble = load_ensemble_model()

@app.post("/predict", response_model=Dict)
async def predict_gestures(file: UploadFile = File(...)):
    """
    Endpoint to receive a video file and return gesture predictions.
    """
    try:
        # Validate file type
        if file.content_type not in ["video/mp4", "video/avi"]:
            raise HTTPException(status_code=400, detail="Only MP4 or AVI files are supported")

        # Create temporary file
        temp_dir = tempfile.gettempdir()
        temp_file_path = os.path.join(temp_dir, f"{uuid.uuid4()}.{file.filename.split('.')[-1]}")

        # Save uploaded file
        with open(temp_file_path, "wb") as temp_file:
            shutil.copyfileobj(file.file, temp_file)

        # Check if ensemble model is loaded
        if ensemble is None:
            raise HTTPException(status_code=500, detail="Model not loaded")

        # Process video
        prediction = ensemble.predict_single_video(temp_file_path)

        # Clean up temporary file
        os.remove(temp_file_path)

        if 'error' in prediction:
            raise HTTPException(status_code=500, detail=f"Error processing video: {prediction['error']}")

        # Format response
        response = {
            "primary_gesture": prediction['primary_gesture'] or "None",
            "primary_confidence": float(prediction['max_confidence']),
            "detailed_confidences": {
                gesture_name: float(confidence_dict['confidence'])
                for gesture_name, confidence_dict in prediction['all_confidences'].items()
            }
        }

        return response

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
    finally:
        await file.close()

@app.get("/health")
async def health_check():
    """
    Health check endpoint.
    """
    return {"status": "healthy", "model_loaded": ensemble is not None}