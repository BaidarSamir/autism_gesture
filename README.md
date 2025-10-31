# Autism Screening App

A cross-platform mobile application designed for early-stage autism screening in young children, leveraging AI movement detection and standardized diagnostic tools.

## Features

- User Authentication: Parents can register using email, password, and their child's name
- AI Movement Detection: Analyzes uploaded videos for specific movements and returns confidences
  - Head Banging
  - Arm Flapping
  - Spinning
  - Maps confidence to an overall indication (Likely / Not Likely) using a configurable threshold
- Diagnostic Tests:
  - M-CHAT: 20 Yes/No questions with a final risk level score
  - CARS-2: 15 questions with 4-option answers and specialized scoring
- Results Tracking: All test results are saved and viewable over time

## Technical Implementation

### Tech Stack

| Layer           | Technology                            |
|-----------------|----------------------------------------|
| Mobile          | Flutter                                |
| Backend/API     | FastAPI (Python), Uvicorn              |
| AI Processing   | PyTorch + TorchVision, Jupyter Notebook|
| CV Utilities    | OpenCV, PIL, NumPy                     |
| Native Tools    | C++ (OpenCV + Boost) via CMake         |
| Storage/Auth    | Firebase                               |
| Hosting         | AWS                                    |

Note: Earlier notes may reference Flask; this codebase uses FastAPI.

### AI Movement Detection Logic

- Processes video uploads server-side via the `/predict` endpoint
- Sampling: motion-aware optical flow + uniform sampling to a fixed sequence of 16 frames per video
- Preprocessing: resize to 224×224; normalize with ImageNet mean/std
- Model: ResNet-18 backbone (pretrained) → Bi-LSTM (hidden 128) with attention → binary logits per gesture
- Ensemble: Three independent binary classifiers (ArmFlapping, HeadBanging, Spinning); confidences aggregated; if a gesture’s confidence ≥ threshold (default 0.5) it’s considered detected
- Output: primary gesture (argmax by confidence), its confidence, and per-gesture confidences

### Backend/API (this repository)

- Code: `clipping_ssbd_videos/autism_gesture_api/main.py`
- Model weights: `clipping_ssbd_videos/autism_gesture_api/models/autism_gesture_ensemble.pth`
- Dependencies: `clipping_ssbd_videos/autism_gesture_api/requirements.txt`
- Endpoints:
  - `GET /health` → `{ "status": "healthy", "model_loaded": true }`
  - `POST /predict` (multipart/form-data, field name `file`, accepts MP4/AVI)
- Response example (valid JSON):
```json
{
  "primary_gesture": "ArmFlapping",
  "primary_confidence": 0.87,
  "detailed_confidences": {
    "ArmFlapping": 0.87,
    "HeadBanging": 0.12,
    "Spinning": 0.05
  }
}
```
- Field types
  - primary_gesture: string, one of ["ArmFlapping", "HeadBanging", "Spinning", "None"]
  - primary_confidence: number in [0, 1]
  - detailed_confidences: object with gesture names as keys and confidence numbers in [0, 1]
- Run locally (WSL Ubuntu or Windows Python):
```bash
cd clipping_ssbd_videos/autism_gesture_api
python -m pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Training Pipeline (Notebook)

- Notebook: `Gesture_Classification_Pipeline.ipynb`
- Includes data loading, motion-aware frame sampling, augmentations, training loops, and evaluation
- Optimizer: AdamW; LR scheduler on validation AUC; early stopping
- Metrics: Accuracy, AUC; confusion matrix and ROC plots
- Saves:
  - Per-gesture weights: `binary_classifier_<gesture>.pth`
  - Ensemble: `autism_gesture_ensemble.pth` (used by the API)
  - ONNX exports: `clipping_ssbd_videos/exported_models/*.onnx` and `ensemble_config.json`

### Dataset Utilities (SSBD)

- Download raw videos:
  - XML annotations under `clipping_ssbd_videos/ssbd-release/Annotations/`
  - Script: `clipping_ssbd_videos/scripts/download_ssbd.py` (requires `yt-dlp`)
- Clip gesture segments (uses native C++ tool):
  - Script: `clipping_ssbd_videos/scripts/clip_ssbd_video_segments.py`
  - Build native tools (WSL/Ubuntu):
```bash
sudo apt update
sudo apt install -y build-essential cmake libopencv-dev libboost-filesystem-dev libboost-system-dev
cd clipping_ssbd_videos/src
mkdir -p build && cd build
cmake ..
make -j
```
  - If OpenCV 4 symbol issues appear, run `bash fix_opencv4_compatibility.sh`, then clean and rebuild

## Data Handling

- Child names and test results stored in Firebase
- API and media handling hosted on AWS (deployment-specific)
- We recommend storing summaries/metrics rather than raw videos where possible; configure Firebase rules accordingly

## Results Presentation

- Shows per-movement confidences and an overall indication (Likely / Not Likely)
- Displays M-CHAT and CARS-2 results with risk bands
- Provides access to previous test results

## Target Audience

Parents of young children seeking early autism screening.

## Development Status

As of June 10, 2025 - Functional prototype completed
