# ML Recommendation Engine Guide

This guide provides detailed information on how the SkinTone Shop machine learning recommendation engine works and how to extend or modify its functionality.

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [ML Engine Components](#ml-engine-components)
4. [Data Flow](#data-flow)
5. [Adding New Features](#adding-new-features)
6. [Improving Recommendation Algorithms](#improving-recommendation-algorithms)
7. [Integrating with New Retailers](#integrating-with-new-retailers)
8. [Testing and Evaluation](#testing-and-evaluation)
9. [Troubleshooting](#troubleshooting)

## Overview

The ML recommendation engine is a Python-based service that analyzes product data and user skin tone information to provide personalized clothing recommendations. It uses machine learning algorithms to predict compatibility between products and skin tones.

The system consists of:
- A Flask API server
- Feature extraction and preprocessing logic
- Machine learning models trained on product-skin tone compatibility data
- Fallback rule-based compatibility algorithms

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│  Flutter App    │◄──►│  Flask API      │◄──►│  ML Engine      │
│  (Dart)         │    │  (Python)       │    │  (Python)       │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │                 │
                       │  Retailer APIs  │
                       │  (External)     │
                       │                 │
                       └─────────────────┘
```

The Flutter app communicates with the ML engine through a Flask API server. The ML engine processes product data from various retailers and makes recommendations based on user skin tone information.

## ML Engine Components

The ML engine is located in `ml_recommendation_engine.py` and consists of the following key components:

### 1. Feature Extractors

```python
def extract_product_features(product):
    """Extract features from a product for machine learning"""
    # Convert product data into numerical/categorical features
    features = {
        'color_features': extract_color_features(product['colors']),
        'category_features': get_category_encoding(product['category']),
        'price_features': normalize_price(product['price']),
        # More features...
    }
    return features
```

The feature extractors convert product data into a format suitable for machine learning algorithms. This includes:
- Encoding color information
- Categorizing product types
- Normalizing prices
- Extracting text features from descriptions

### 2. Compatibility Models

```python
def train_compatibility_model(products, skin_tones):
    """Train a model to predict skin tone compatibility"""
    # Prepare training data
    X = []  # Features
    y = []  # Target (compatibility scores)
    
    # Create training examples
    for product in products:
        for skin_tone in skin_tones:
            features = combine_features(product, skin_tone)
            compatibility = calculate_base_compatibility(product, skin_tone)
            X.append(features)
            y.append(compatibility)
    
    # Train model
    model = RandomForestRegressor(n_estimators=100)
    model.fit(X, y)
    
    return model
```

The ML engine uses several models for different tasks:
- A random forest regression model for predicting compatibility scores
- A nearest neighbors model for finding similar products
- Text embedding models for understanding product descriptions

### 3. Color Analysis

```python
def color_compatibility_score(product_colors, skin_undertone):
    """Calculate compatibility based on color theory"""
    # Apply color theory rules to determine compatibility
    compatibility = 0
    
    for color in product_colors:
        color_family = get_color_family(color)
        color_tone = get_color_tone(color)
        
        # Calculate compatibility based on color theory
        if skin_undertone == 'warm' and color_tone == 'warm':
            compatibility += 10
        elif skin_undertone == 'cool' and color_tone == 'cool':
            compatibility += 10
        elif color_tone == 'neutral':
            compatibility += 5
        else:
            compatibility -= 5
            
    return compatibility / len(product_colors)
```

The engine uses color theory principles to determine compatibility between clothing colors and skin tones.

### 4. Flask API

```python
@app.route('/api/recommend', methods=['POST'])
def recommend_products():
    """Generate product recommendations for a user"""
    data = request.json
    products = data.get('products', [])
    user_info = data.get('userInfo', {})
    
    # Convert to internal format
    product_df = prepare_product_dataframe(products)
    user_features = prepare_user_features(user_info)
    
    # Generate recommendations
    recommendations = get_recommendations(product_df, user_features, model)
    
    return jsonify({
        'status': 'success',
        'recommendations': recommendations
    })
```

The Flask API exposes endpoints for:
- Initializing the ML engine with product data
- Getting product recommendations for a user
- Calculating compatibility for a specific product

## Data Flow

1. **Initialization**:
   - The Flutter app starts and loads product data
   - It sends this data to the ML engine to initialize models
   - The ML engine processes and indexes the products

2. **Recommendation**:
   - User completes skin tone profile
   - App requests recommendations
   - ML engine calculates compatibility scores
   - Results are returned to the app for display

3. **Product-Specific Compatibility**:
   - User views a specific product
   - App requests compatibility score for that product
   - ML engine calculates and returns score and explanation

## Adding New Features

To add new features to the recommendation engine, follow these steps:

### 1. Identify the New Feature

Determine what new aspects of products or users you want to consider. Examples include:
- Fabric type influence on compatibility
- Seasonal appropriateness
- Style preference matching
- Brand affinity

### 2. Update Feature Extraction

Modify the `extract_product_features` function in `ml_recommendation_engine.py`:

```python
def extract_product_features(product):
    features = {
        # Existing features...
    }
    
    # Add new feature
    if 'fabric' in product and product['fabric']:
        features['fabric_type'] = encode_fabric_type(product['fabric'])
    
    return features
```

### 3. Create Encoding Function for the Feature

```python
def encode_fabric_type(fabric):
    """Convert fabric information to numerical features"""
    fabric_types = {
        'cotton': [1, 0, 0, 0, 0],
        'silk': [0, 1, 0, 0, 0],
        'wool': [0, 0, 1, 0, 0],
        'polyester': [0, 0, 0, 1, 0],
        'linen': [0, 0, 0, 0, 1],
        # Add more fabric types...
    }
    
    # Lowercase and normalize fabric name
    fabric = fabric.lower()
    
    # Find best match if exact match not found
    if fabric not in fabric_types:
        for key in fabric_types:
            if key in fabric:
                return fabric_types[key]
        # Default to zeros if no match
        return [0, 0, 0, 0, 0]
        
    return fabric_types[fabric]
```

### 4. Update the Model Training

Modify the training code to use the new feature:

```python
def train_compatibility_model(products, skin_tones):
    # Existing code...
    
    # Update feature combination to include new feature
    def combine_features(product, skin_tone):
        features = []
        # Add existing features
        features.extend(product['color_features'])
        features.extend(product['category_features'])
        
        # Add new fabric feature if available
        if 'fabric_type' in product:
            features.extend(product['fabric_type'])
        else:
            # Add zeros if feature not available
            features.extend([0, 0, 0, 0, 0])
            
        # Add skin tone features
        features.extend(encode_skin_tone(skin_tone))
        
        return features
    
    # Continue with model training...
```

### 5. Update Compatibility Calculation

If you want to include the new feature in the rule-based fallback algorithm:

```python
def calculate_base_compatibility(product, skin_tone):
    compatibility = color_compatibility_score(product['colors'], skin_tone['undertone'])
    
    # Add fabric compatibility
    if 'fabric_type' in product:
        fabric_score = fabric_compatibility_score(product['fabric_type'], skin_tone)
        compatibility = (compatibility + fabric_score) / 2
    
    return compatibility
```

### 6. Create new compatibility function

```python
def fabric_compatibility_score(fabric_type, skin_tone):
    """Calculate how well a fabric complements a skin tone"""
    # Implementation depends on fashion domain knowledge
    # This is a simplified example
    
    score = 50  # Neutral starting point
    
    # Example rules based on fashion principles
    if 'winter' in skin_tone['season']:
        # Winter skin tones look good with structured fabrics
        if fabric_type in ['wool', 'tweed', 'cashmere']:
            score += 20
    elif 'summer' in skin_tone['season']:
        # Summer skin tones complement light, flowing fabrics
        if fabric_type in ['linen', 'silk', 'light cotton']:
            score += 20
    # Add more rules...
    
    return min(100, max(0, score))  # Ensure score is in [0, 100]
```

## Improving Recommendation Algorithms

To improve the existing algorithms:

### 1. Enhance the ML Model

```python
def train_improved_compatibility_model(products, skin_tones):
    # Prepare data as before...
    
    # Use a more sophisticated model
    from sklearn.ensemble import GradientBoostingRegressor
    from sklearn.model_selection import GridSearchCV
    
    # Define model with hyperparameters to tune
    model = GradientBoostingRegressor()
    
    # Define hyperparameter search space
    param_grid = {
        'n_estimators': [50, 100, 200],
        'learning_rate': [0.01, 0.1, 0.2],
        'max_depth': [3, 5, 7],
    }
    
    # Perform grid search with cross-validation
    grid_search = GridSearchCV(
        model, param_grid, cv=5, 
        scoring='neg_mean_squared_error'
    )
    
    # Train model
    grid_search.fit(X, y)
    
    # Get best model
    best_model = grid_search.best_estimator_
    
    return best_model
```

### 2. Implement Ensemble Approach

```python
def ensemble_recommendation(product_df, user_features):
    """Generate recommendations using multiple models"""
    # Get recommendations from different models
    rf_recommendations = get_recommendations_random_forest(product_df, user_features, rf_model)
    nn_recommendations = get_recommendations_nearest_neighbors(product_df, user_features, nn_model)
    rule_recommendations = get_recommendations_rule_based(product_df, user_features)
    
    # Combine recommendations with weights
    final_recommendations = {}
    
    # For each product, combine scores
    for product_id in product_df['id']:
        rf_score = get_score(rf_recommendations, product_id)
        nn_score = get_score(nn_recommendations, product_id)
        rule_score = get_score(rule_recommendations, product_id)
        
        # Weighted average
        final_score = (0.5 * rf_score) + (0.3 * nn_score) + (0.2 * rule_score)
        
        final_recommendations[product_id] = final_score
    
    # Sort and return top recommendations
    sorted_recommendations = sorted(
        final_recommendations.items(),
        key=lambda x: x[1],
        reverse=True
    )
    
    return sorted_recommendations
```

### 3. Implement Context-Aware Recommendations

```python
def context_aware_recommendations(product_df, user_features, context=None):
    """Generate recommendations considering context"""
    
    # Default recommendations
    recommendations = get_recommendations(product_df, user_features, model)
    
    # Apply context-specific adjustments
    if context:
        if 'season' in context:
            recommendations = adjust_for_season(recommendations, context['season'])
        
        if 'occasion' in context:
            recommendations = adjust_for_occasion(recommendations, context['occasion'])
            
    return recommendations
```

## Integrating with New Retailers

To make the ML engine work with additional retailers:

### 1. Standardize Data Format

Ensure all product data follows a consistent format regardless of source:

```python
def normalize_product_data(product, retailer):
    """Normalize product data from different retailers"""
    normalized = {
        'id': product.get('id', ''),
        'name': product.get('name', ''),
        'description': product.get('description', ''),
        'price': float(product.get('price', 0)),
        'colors': [],
        'category': '',
        'retailer': retailer,
    }
    
    # Handle retailer-specific color extraction
    if retailer == 'amazon':
        normalized['colors'] = extract_amazon_colors(product)
    elif retailer == 'newretailer':
        normalized['colors'] = extract_newretailer_colors(product)
    else:
        # Default color extraction
        normalized['colors'] = product.get('colors', [])
    
    # Handle retailer-specific category mapping
    if retailer == 'amazon':
        normalized['category'] = map_amazon_category(product.get('category', ''))
    elif retailer == 'newretailer':
        normalized['category'] = map_newretailer_category(product.get('category', ''))
    else:
        normalized['category'] = product.get('category', '')
        
    return normalized
```

### 2. Create Retailer-Specific Feature Extractors

```python
def extract_newretailer_colors(product):
    """Extract color information from NewRetailer products"""
    if 'variant_options' in product:
        for option in product['variant_options']:
            if option['type'] == 'color':
                return [val['name'] for val in option['values']]
    
    if 'color' in product:
        return [product['color']]
        
    return ['Unknown']
```

### 3. Update API to Handle Retailer-Specific Fields

```python
@app.route('/api/init_retailer', methods=['POST'])
def initialize_retailer():
    """Initialize the engine with data from a specific retailer"""
    data = request.json
    retailer_name = data.get('retailer', '')
    products = data.get('products', [])
    
    # Normalize data for this retailer
    normalized_products = [
        normalize_product_data(p, retailer_name) 
        for p in products
    ]
    
    # Add to product database
    add_products_to_database(normalized_products)
    
    # Retrain model if needed
    if data.get('retrainModel', False):
        global model
        model = train_compatibility_model(get_all_products(), get_all_skin_tones())
    
    return jsonify({
        'status': 'success',
        'message': f'Successfully initialized {retailer_name} with {len(products)} products'
    })
```

## Testing and Evaluation

To evaluate the recommendation engine:

### 1. Split Testing

```python
def evaluate_model(model, test_data):
    """Evaluate model performance on test data"""
    X_test, y_test = test_data
    
    # Make predictions
    y_pred = model.predict(X_test)
    
    # Calculate metrics
    from sklearn.metrics import mean_squared_error, mean_absolute_error
    
    mse = mean_squared_error(y_test, y_pred)
    mae = mean_absolute_error(y_test, y_pred)
    
    print(f"Mean Squared Error: {mse:.4f}")
    print(f"Mean Absolute Error: {mae:.4f}")
    
    return {
        'mse': mse,
        'mae': mae,
    }
```

### 2. A/B Testing

Implement A/B testing to compare different recommendation algorithms:

```python
@app.route('/api/recommend_ab', methods=['POST'])
def ab_test_recommendations():
    """Serve recommendations with A/B testing"""
    data = request.json
    
    # Randomly assign user to test group
    import random
    test_group = 'A' if random.random() < 0.5 else 'B'
    
    if test_group == 'A':
        # Original algorithm
        recommendations = get_recommendations(
            prepare_product_dataframe(data.get('products', [])),
            prepare_user_features(data.get('userInfo', {})),
            model_a
        )
    else:
        # New algorithm
        recommendations = get_improved_recommendations(
            prepare_product_dataframe(data.get('products', [])),
            prepare_user_features(data.get('userInfo', {})),
            model_b
        )
    
    # Record test group for analytics
    record_ab_test(
        user_id=data.get('userId', 'anonymous'),
        test_group=test_group,
        recommendations=recommendations
    )
    
    return jsonify({
        'status': 'success',
        'recommendations': recommendations,
        'test_group': test_group
    })
```

### 3. User Feedback Collection

```python
@app.route('/api/feedback', methods=['POST'])
def collect_feedback():
    """Collect user feedback on recommendations"""
    data = request.json
    
    user_id = data.get('userId', 'anonymous')
    product_id = data.get('productId', '')
    rating = data.get('rating', 0)  # User rating (1-5)
    purchased = data.get('purchased', False)
    
    # Store feedback for model improvement
    store_feedback(user_id, product_id, rating, purchased)
    
    # Use feedback to update model if enough data collected
    update_model_with_feedback()
    
    return jsonify({
        'status': 'success',
        'message': 'Feedback recorded'
    })
```

## Troubleshooting

Common issues and solutions:

### 1. Poor Recommendations

If recommendations seem inaccurate:

1. **Check Feature Extraction**:
   ```python
   def debug_feature_extraction(product):
       features = extract_product_features(product)
       print(f"Product: {product['name']}")
       print(f"Features: {features}")
       return features
   ```

2. **Inspect Model Weights**:
   ```python
   def inspect_model_importance():
       if hasattr(model, 'feature_importances_'):
           importances = model.feature_importances_
           feature_names = get_feature_names()
           
           for name, importance in zip(feature_names, importances):
               print(f"{name}: {importance:.4f}")
   ```

### 2. Performance Issues

If the recommendation engine is slow:

1. **Add Caching**:
   ```python
   from functools import lru_cache
   
   @lru_cache(maxsize=1000)
   def get_product_features(product_id):
       """Get cached product features"""
       product = get_product_by_id(product_id)
       return extract_product_features(product)
   ```

2. **Optimize Database Queries**:
   ```python
   def get_recommendations_optimized(product_df, user_features, model):
       """Optimized recommendation function"""
       # Pre-compute features for all products instead of one by one
       all_features = compute_all_features(product_df)
       
       # Vectorized prediction
       scores = model.predict(all_features)
       
       # Create recommendations from scores
       recommendations = []
       for i, product_id in enumerate(product_df['id']):
           recommendations.append({
               'productId': product_id,
               'score': scores[i],
           })
           
       return sorted(recommendations, key=lambda x: x['score'], reverse=True)
   ```

### 3. Data Quality Issues

If there are issues with data consistency:

1. **Add Data Validation**:
   ```python
   def validate_product(product):
       """Check product data quality"""
       errors = []
       
       if not product.get('id'):
           errors.append('Missing product ID')
           
       if not product.get('name'):
           errors.append('Missing product name')
           
       if not product.get('colors') or len(product['colors']) == 0:
           errors.append('Missing color information')
           
       return errors
   ```

2. **Clean input data**:
   ```python
   def clean_product_data(product):
       """Clean and normalize product data"""
       cleaned = product.copy()
       
       # Ensure strings are properly formatted
       for field in ['name', 'description', 'category']:
           if field in cleaned and cleaned[field]:
               cleaned[field] = cleaned[field].strip()
       
       # Ensure colors are normalized
       if 'colors' in cleaned:
           cleaned['colors'] = [c.strip().lower() for c in cleaned['colors']]
           
       # Ensure price is a float
       if 'price' in cleaned:
           try:
               cleaned['price'] = float(cleaned['price'])
           except (ValueError, TypeError):
               cleaned['price'] = 0.0
               
       return cleaned
   ```

By following this guide, you can extend, improve, and troubleshoot the ML recommendation engine to provide even better personalized clothing recommendations.