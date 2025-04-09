import os
import json
import numpy as np
import pandas as pd
from flask import Flask, request, jsonify
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.neighbors import NearestNeighbors
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer

app = Flask(__name__)

# Initialize data storage
product_data = None
user_data = None
models = {}

# Sample product data for initial testing
SAMPLE_PRODUCTS = [
    {
        "id": "1",
        "name": "Classic Cotton T-shirt",
        "description": "A comfortable cotton t-shirt for everyday wear. Perfect for casual outings and relaxed settings.",
        "price": 19.99,
        "currency": "USD",
        "colors": ["White", "Black", "Navy", "Red", "Olive Green"],
        "sizes": ["S", "M", "L", "XL"],
        "category": "Tops",
        "retailer": "Amazon",
        "gender": "unisex",
        "rating": 4.5,
        "reviewCount": 120
    },
    # More product samples will be loaded from actual request data
]

# Color-related data for features
COLOR_FAMILIES = {
    'red': ['red', 'maroon', 'burgundy', 'crimson', 'scarlet', 'ruby', 'cherry'],
    'pink': ['pink', 'rose', 'fuchsia', 'magenta', 'salmon'],
    'orange': ['orange', 'peach', 'coral', 'amber', 'terracotta', 'rust'],
    'yellow': ['yellow', 'gold', 'mustard', 'lemon', 'honey'],
    'green': ['green', 'olive', 'emerald', 'lime', 'mint', 'sage', 'forest green', 'hunter green'],
    'blue': ['blue', 'navy', 'teal', 'turquoise', 'cobalt', 'royal blue', 'sky blue', 'cyan'],
    'purple': ['purple', 'lavender', 'violet', 'plum', 'lilac', 'mauve', 'indigo', 'amethyst'],
    'brown': ['brown', 'tan', 'beige', 'camel', 'khaki', 'chestnut', 'chocolate', 'coffee'],
    'neutral': ['white', 'black', 'gray', 'grey', 'silver', 'ivory', 'cream'],
}

COLOR_TONES = {
    'red': 'warm',
    'burgundy': 'cool',
    'crimson': 'warm',
    'scarlet': 'warm',
    'maroon': 'cool',
    'ruby': 'cool',
    'cherry': 'cool',
    'pink': 'cool',
    'rose': 'cool',
    'salmon': 'warm',
    'fuchsia': 'cool',
    'magenta': 'cool',
    'orange': 'warm',
    'peach': 'warm',
    'coral': 'warm',
    'amber': 'warm',
    'terracotta': 'warm',
    'rust': 'warm',
    'yellow': 'warm',
    'gold': 'warm',
    'mustard': 'warm',
    'lemon': 'cool',
    'honey': 'warm',
    'green': 'neutral',
    'olive': 'warm',
    'emerald': 'cool',
    'lime': 'cool',
    'mint': 'cool',
    'sage': 'cool',
    'forest green': 'cool',
    'hunter green': 'cool',
    'blue': 'cool',
    'navy': 'cool',
    'teal': 'cool',
    'turquoise': 'cool',
    'cobalt': 'cool',
    'royal blue': 'cool',
    'sky blue': 'cool',
    'cyan': 'cool',
    'purple': 'cool',
    'lavender': 'cool',
    'violet': 'cool',
    'plum': 'cool',
    'lilac': 'cool',
    'mauve': 'cool',
    'indigo': 'cool',
    'amethyst': 'cool',
    'brown': 'warm',
    'tan': 'warm',
    'beige': 'warm',
    'camel': 'warm',
    'khaki': 'warm',
    'chestnut': 'warm',
    'chocolate': 'warm',
    'coffee': 'warm',
    'white': 'neutral',
    'black': 'neutral',
    'gray': 'neutral',
    'grey': 'neutral',
    'silver': 'cool',
    'ivory': 'warm',
    'cream': 'warm',
}

# Predefined skin tones for training
SKIN_TONES = [
    {
        "id": "warm_light",
        "name": "Light Warm",
        "undertone": "warm",
        "depth": "light",
        "recommendedColors": [
            "Peach", "Coral", "Warm orange", "Golden yellow", "Olive green",
            "Warm red", "Terracotta", "Ivory", "Cream", "Bronze"
        ],
        "notRecommendedColors": [
            "Blue-based pink", "Cold blue", "Silver", "Icy pastels", "Deep purple"
        ]
    },
    {
        "id": "warm_medium",
        "name": "Medium Warm",
        "undertone": "warm",
        "depth": "medium",
        "recommendedColors": [
            "Amber", "Warm brown", "Orange red", "Teal", "Forest green",
            "Warm coral", "Camel", "Honey", "Mustard", "Bronze"
        ],
        "notRecommendedColors": [
            "Pastel blue", "Cool gray", "Magenta", "Baby pink", "Icy white"
        ]
    },
    {
        "id": "warm_deep",
        "name": "Deep Warm",
        "undertone": "warm",
        "depth": "deep",
        "recommendedColors": [
            "Bright orange", "Warm red", "Gold", "Copper", "Hunter green",
            "Tangerine", "Bright yellow", "Magenta", "Purple", "Fuchsia"
        ],
        "notRecommendedColors": [
            "Pale pastels", "Light beige", "Muted colors", "Olive", "Dusty rose"
        ]
    },
    {
        "id": "cool_light",
        "name": "Light Cool",
        "undertone": "cool",
        "depth": "light",
        "recommendedColors": [
            "Rose pink", "Blue-red", "Lavender", "Navy", "Emerald",
            "Raspberry", "Blue-toned purple", "Silver", "Soft white", "Gray"
        ],
        "notRecommendedColors": [
            "Orange", "Warm yellows", "Peach", "Coral", "Camel"
        ]
    },
    {
        "id": "cool_medium",
        "name": "Medium Cool",
        "undertone": "cool",
        "depth": "medium",
        "recommendedColors": [
            "Fuchsia", "Plum", "Ruby", "Royal blue", "Pine green",
            "True red", "Cool pink", "Cool mint", "Deep purple", "Burgundy"
        ],
        "notRecommendedColors": [
            "Rust", "Warm brown", "Yellow", "Orange", "Olive"
        ]
    },
    {
        "id": "cool_deep",
        "name": "Deep Cool",
        "undertone": "cool",
        "depth": "deep",
        "recommendedColors": [
            "Royal purple", "True red", "Hot pink", "Cobalt blue", "Emerald green",
            "Pure white", "Bright berry tones", "True blue", "Electric blue", "Wine red"
        ],
        "notRecommendedColors": [
            "Orange", "Khaki", "Muted browns", "Light pastels", "Warm yellows"
        ]
    },
    {
        "id": "neutral_light",
        "name": "Light Neutral",
        "undertone": "neutral",
        "depth": "light",
        "recommendedColors": [
            "Soft pink", "Light blue", "Camel", "Medium gray", "Sage green",
            "Periwinkle", "Soft white", "Navy", "Medium purple", "Teal"
        ],
        "notRecommendedColors": [
            "Very bright colors", "Neon colors", "Very dark colors"
        ]
    },
    {
        "id": "neutral_medium",
        "name": "Medium Neutral",
        "undertone": "neutral",
        "depth": "medium",
        "recommendedColors": [
            "Teal", "Medium blue", "Coral", "Burgundy", "Olive green",
            "Medium purple", "Camel", "Forest green", "Russet", "Navy"
        ],
        "notRecommendedColors": [
            "Neon colors", "Very pale pastels"
        ]
    },
    {
        "id": "neutral_deep",
        "name": "Deep Neutral",
        "undertone": "neutral",
        "depth": "deep",
        "recommendedColors": [
            "Emerald green", "Royal blue", "Bright red", "Pure white", "Orange",
            "Fuchsia", "Cobalt blue", "Gold", "Bright yellow", "Purple"
        ],
        "notRecommendedColors": [
            "Beige", "Pale yellow", "Light pastels", "Muted tones"
        ]
    }
]

def get_color_family(color_str):
    """Get the color family a color belongs to"""
    normalized = color_str.lower()
    
    for family, colors in COLOR_FAMILIES.items():
        for color in colors:
            if color in normalized:
                return family
    
    return 'other'

def get_color_tone(color_str):
    """Get the undertone (warm, cool, neutral) of a color"""
    normalized = color_str.lower()
    
    # Check for exact matches
    if normalized in COLOR_TONES:
        return COLOR_TONES[normalized]
    
    # Check for partial matches
    for color, tone in COLOR_TONES.items():
        if color in normalized:
            return tone
    
    return 'neutral'  # Default

def color_compatibility_score(product_colors, skin_undertone):
    """Calculate compatibility based on color theory"""
    if not product_colors or not skin_undertone:
        return 50  # Neutral score for missing data
    
    compatibility_score = 50  # Start with neutral
    
    for color in product_colors:
        color_tone = get_color_tone(color)
        
        # Perfect match (warm-warm, cool-cool)
        if color_tone == skin_undertone:
            compatibility_score += 10
        # Neutral colors work with everything
        elif color_tone == 'neutral':
            compatibility_score += 5
        # Neutral skin tone works with all colors
        elif skin_undertone == 'neutral':
            compatibility_score += 5
        # Contrasting undertones can clash
        else:
            compatibility_score -= 5
    
    # Normalize score to 0-100 range
    return max(0, min(100, compatibility_score))

def extract_product_features(product):
    """Extract features from a product for machine learning"""
    features = {}
    
    # Basic product info
    features['category'] = product.get('category', '')
    features['gender'] = product.get('gender', '')
    features['price'] = float(product.get('price', 0))
    features['rating'] = float(product.get('rating', 0))
    features['review_count'] = int(product.get('reviewCount', 0))
    
    # Color features
    colors = product.get('colors', [])
    features['num_colors'] = len(colors)
    
    # Color family distribution
    color_families = {family: 0 for family in COLOR_FAMILIES.keys()}
    color_tones = {'warm': 0, 'cool': 0, 'neutral': 0}
    
    for color in colors:
        family = get_color_family(color)
        if family in color_families:
            color_families[family] += 1
        
        tone = get_color_tone(color)
        if tone in color_tones:
            color_tones[tone] += 1
    
    # Add normalized color family counts
    if features['num_colors'] > 0:
        for family, count in color_families.items():
            features[f'color_family_{family}'] = count / features['num_colors']
        
        for tone, count in color_tones.items():
            features[f'color_tone_{tone}'] = count / features['num_colors']
    else:
        for family in color_families:
            features[f'color_family_{family}'] = 0
        for tone in color_tones:
            features[f'color_tone_{tone}'] = 0
    
    return features

def prepare_product_dataframe(products):
    """Convert product list to a DataFrame with extracted features"""
    products_features = []
    
    for product in products:
        features = extract_product_features(product)
        features['id'] = product['id']
        products_features.append(features)
    
    return pd.DataFrame(products_features)

def train_compatibility_model(products, skin_tones):
    """Train a model to predict skin tone compatibility"""
    if not products or not skin_tones:
        return None
    
    # Create training dataset with product-skin tone pairs
    training_data = []
    
    for product in products:
        for skin_tone in skin_tones:
            # For each product and skin tone, create a training sample
            features = extract_product_features(product)
            features['undertone'] = skin_tone['undertone']
            features['depth'] = skin_tone['depth']
            
            # Calculate compatibility score for this pair
            recommended_colors = set([c.lower() for c in skin_tone['recommendedColors']])
            not_recommended_colors = set([c.lower() for c in skin_tone['notRecommendedColors']])
            
            score = 50  # Start at neutral
            for color in product['colors']:
                color_lower = color.lower()
                # Check for exact or partial matches in recommended colors
                for rec_color in recommended_colors:
                    if rec_color in color_lower or color_lower in rec_color:
                        score += 10
                        break
                
                # Check for exact or partial matches in not recommended colors
                for not_rec_color in not_recommended_colors:
                    if not_rec_color in color_lower or color_lower in not_rec_color:
                        score -= 10
                        break
            
            # Boost score for certain categories
            if product['category'] in ['Tops', 'Dresses']:
                score += 5  # These are more visible and impactful for skin tone
            
            # Ensure score is in 0-100 range
            score = max(0, min(100, score))
            
            # Add compatibility class (high, medium, low)
            if score >= 70:
                compatibility_class = 'high'
            elif score >= 40:
                compatibility_class = 'medium'
            else:
                compatibility_class = 'low'
            
            features['compatibility_score'] = score
            features['compatibility_class'] = compatibility_class
            
            training_data.append(features)
    
    # Convert to DataFrame
    df = pd.DataFrame(training_data)
    
    # Separate features and target
    X = df.drop(['compatibility_score', 'compatibility_class'], axis=1)
    y_score = df['compatibility_score']
    y_class = df['compatibility_class']
    
    # Create and train models
    categorical_features = ['category', 'gender', 'undertone', 'depth']
    numeric_features = [col for col in X.columns if col not in categorical_features]
    
    # Preprocessing pipeline
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numeric_features),
            ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_features)
        ])
    
    # Classification model (for high/medium/low)
    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf_pipeline = Pipeline([
        ('preprocessor', preprocessor),
        ('classifier', clf)
    ])
    
    clf_pipeline.fit(X, y_class)
    
    return {
        'classifier': clf_pipeline,
        'features': X.columns.tolist()
    }

def prepare_user_features(user_info):
    """Extract features from user information"""
    features = {}
    
    # Basic user skin tone info
    features['undertone'] = user_info.get('undertone', 'neutral')
    features['depth'] = user_info.get('depth', 'medium')
    
    # Add more user features as needed
    
    return features

def get_recommendations(product_df, user_features, model, top_n=10):
    """Generate recommendations for a user"""
    if product_df.empty or not model:
        return []
    
    # Create feature vectors for each product combined with user features
    prediction_data = []
    
    for _, product_row in product_df.iterrows():
        # Combine product features with user features
        combined_features = {**product_row.to_dict()}
        combined_features.update(user_features)
        prediction_data.append(combined_features)
    
    prediction_df = pd.DataFrame(prediction_data)
    
    # Get required features in the right order
    model_features = model['features']
    X_pred = prediction_df[model_features]
    
    # Predict compatibility class and get probabilities
    compatibility_probs = model['classifier'].predict_proba(X_pred)
    
    # Get index of 'high' class
    classes = model['classifier'].classes_
    high_idx = np.where(classes == 'high')[0][0] if 'high' in classes else 0
    
    # Add scores to product DataFrame
    product_df['compatibility_score'] = compatibility_probs[:, high_idx] * 100
    
    # Sort by compatibility score
    sorted_products = product_df.sort_values('compatibility_score', ascending=False)
    
    # Return top N product IDs with scores
    recommendations = []
    for _, row in sorted_products.head(top_n).iterrows():
        recommendations.append({
            'productId': row['id'],
            'compatibilityScore': int(row['compatibility_score']),
            'reason': generate_recommendation_reason(row, user_features)
        })
    
    return recommendations

def generate_recommendation_reason(product_row, user_features):
    """Generate a human-readable reason for the recommendation"""
    undertone = user_features.get('undertone', 'neutral')
    depth = user_features.get('depth', 'medium')
    
    category = product_row.get('category', 'item')
    
    # Generate appropriate reasoning based on compatibility score
    score = product_row.get('compatibility_score', 50)
    
    if score >= 80:
        return f"This {category.lower()} perfectly complements your {undertone} {depth} skin tone."
    elif score >= 60:
        return f"This {category.lower()} works well with your {undertone} {depth} skin tone."
    elif score >= 40:
        return f"This {category.lower()} is compatible with your skin tone."
    else:
        return f"This {category.lower()} has neutral compatibility with your skin tone."

@app.route('/api/initialize', methods=['POST'])
def initialize_engine():
    """Initialize the recommendation engine with products and skin tones"""
    global product_data, models
    
    data = request.json
    products = data.get('products', [])
    skin_tones = data.get('skinTones', SKIN_TONES)
    
    if not products:
        return jsonify({'error': 'No product data provided'}), 400
    
    try:
        # Convert products to DataFrame with features
        product_data = prepare_product_dataframe(products)
        
        # Train recommendation model
        model = train_compatibility_model(products, skin_tones)
        if model:
            models['compatibility'] = model
            return jsonify({'status': 'success', 'message': 'Models trained successfully'})
        else:
            return jsonify({'error': 'Failed to train models'}), 500
    
    except Exception as e:
        return jsonify({'error': f'Error initializing engine: {str(e)}'}), 500

@app.route('/api/recommend', methods=['POST'])
def recommend_products():
    """Generate product recommendations for a user"""
    global product_data, models
    
    data = request.json
    user_info = data.get('userInfo', {})
    products = data.get('products', [])
    
    # If products were provided, use them instead of stored data
    if products:
        product_data = prepare_product_dataframe(products)
    
    if product_data is None or product_data.empty:
        return jsonify({'error': 'No product data available'}), 400
    
    if 'compatibility' not in models:
        # Try to train the model with the current data
        skin_tones = SKIN_TONES
        model = train_compatibility_model(products or SAMPLE_PRODUCTS, skin_tones)
        if model:
            models['compatibility'] = model
        else:
            return jsonify({'error': 'Recommendation model not trained'}), 500
    
    try:
        # Extract user features
        user_features = prepare_user_features(user_info)
        
        # Get recommendations
        recommendations = get_recommendations(
            product_data, 
            user_features, 
            models['compatibility'],
            top_n=20
        )
        
        return jsonify({
            'status': 'success',
            'recommendations': recommendations
        })
    
    except Exception as e:
        return jsonify({'error': f'Error generating recommendations: {str(e)}'}), 500

@app.route('/api/compatibility', methods=['POST'])
def calculate_compatibility():
    """Calculate compatibility score for a specific product and user"""
    data = request.json
    product = data.get('product', {})
    user_info = data.get('userInfo', {})
    
    if not product:
        return jsonify({'error': 'No product data provided'}), 400
    
    try:
        # Extract product colors
        colors = product.get('colors', [])
        
        # Get user skin undertone
        undertone = user_info.get('undertone', '')
        
        # Calculate basic compatibility score
        score = color_compatibility_score(colors, undertone)
        
        # Adjust score based on product category
        category = product.get('category', '')
        if category in ['Tops', 'Dresses']:
            score += 5  # These items are more visible/impactful
        
        # Ensure score is within bounds
        score = max(0, min(100, score))
        
        # Generate reason
        if score >= 80:
            level = "High"
            reason = f"This {category.lower()} perfectly complements your {undertone} skin tone."
        elif score >= 50:
            level = "Medium"
            reason = f"This {category.lower()} works reasonably well with your {undertone} skin tone."
        else:
            level = "Low"
            reason = f"This {category.lower()} may not be the most flattering for your {undertone} skin tone."
        
        return jsonify({
            'productId': product.get('id', ''),
            'compatibilityScore': int(score),
            'compatibilityLevel': level,
            'reason': reason
        })
    
    except Exception as e:
        return jsonify({'error': f'Error calculating compatibility: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)