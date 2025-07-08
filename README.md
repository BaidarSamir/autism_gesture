# Autism Screening App

A cross-platform mobile application designed for early-stage autism screening in young children, leveraging AI movement detection and standardized diagnostic tools.

## Features

- **User Authentication**: Parents can register using email, password, and their child's name.
- **AI Movement Detection**: Analyzes uploaded videos for specific movements:
  - Head Banging
  - Arm Flapping
  - Spinning
  - Returns a confidence score and diagnosis (Likely/Not Likely)
- **Diagnostic Tests**:
  - **M-CHAT**: 20 Yes/No questions with a final risk level score
  - **CARS-2**: 15 questions with 4-option answers and specialized scoring
- **Results Tracking**: All test results are saved and viewable over time

## Technical Implementation

### Tech Stack

| Layer           | Technology       |
|-----------------|------------------|
| Mobile          | Flutter          |
| Backend         | Flask (Python)   |
| AI Processing   | Jupyter Notebook |
| Storage         | Firebase         |
| Hosting         | AWS              |

### AI Movement Detection Logic

- Processes video uploads server-side
- Returns maximum confidence score among detected movements
- Diagnosis threshold:
  - If max ≥ threshold ⇒ return confidence score
  - If max < threshold ⇒ return 0

## Data Handling

- Child names and test results stored in Firebase
- AI processing and media handling hosted on AWS
- All test results are retained with no restrictions on retakes

## Results Presentation

- Shows both scores and diagnoses
- Provides access to previous test results
- Note: Does not currently include clinical suggestions

## Target Audience

Parents of young children seeking early autism screening

## Development Status

As of June 10, 2025 - Functional prototype completed
