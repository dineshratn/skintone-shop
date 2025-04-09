# SkinTone Shop - ML Recommendation Engine

## Overview

SkinTone Shop is a Flutter-powered e-commerce fashion application that provides personalized product recommendations based on users' skin tones. 

The application features a machine learning recommendation engine that analyzes product attributes (colors, categories) and user skin tone profiles to generate personalized recommendations.

## Architecture

The system consists of two main components:

1. **Flutter Mobile App**: Provides the user interface and handles the frontend logic
2. **Python ML Recommendation Engine**: Handles the sophisticated compatibility calculations and recommendations

## ML Recommendation Engine

The ML recommendation engine uses several advanced techniques to provide accurate compatibility scores:

### Features

- **Color Analysis**: Products are analyzed based on their color attributes and compatibility with different skin tones
- **Fallback Algorithm**: If the ML service is unavailable, a rule-based fallback algorithm is used
- **Category Weighting**: Product categories like "Tops" and "Dresses" receive higher weights as they have more visual impact
- **Collaborative Data**: User preferences are factored into the recommendation system

### Machine Learning Models

The engine uses several machine learning models:

1. **Random Forest Classifier**: Used to predict compatibility classes (high, medium, low)
2. **Feature Engineering**: Extracts relevant features from products and user profiles
3. **Similarity Algorithms**: Identifies patterns in user preferences and product attributes

### API Endpoints

The ML engine exposes the following endpoints:

- `/api/initialize`: Initializes the recommendation engine with product data
- `/api/recommend`: Generates product recommendations for a user
- `/api/compatibility`: Calculates compatibility score for a specific product

## Implementation

The implementation follows these steps:

1. User profile creation with skin tone information (undertone, depth)
2. Product data collection from multiple retailers
3. ML engine initialization with product data
4. Personalized recommendations generation based on skin tone compatibility

## Getting Started

To run the application:

1. Start the ML recommendation engine:
   ```
   python ml_recommendation_engine.py
   ```

2. Start the Flutter application:
   ```
   flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0
   ```

## Future Improvements

- Incorporate user feedback to improve recommendation accuracy
- Add image-based skin tone detection
- Implement more sophisticated product attribute extraction
- Add reinforcement learning to improve recommendations over time