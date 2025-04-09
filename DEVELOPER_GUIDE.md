# SkinTone Shop Developer Guide

## Overview

SkinTone Shop is a Flutter-powered e-commerce fashion application that provides intelligent, personalized clothing recommendations based on users' skin tones. It aggregates products from multiple retailers and applies machine learning to suggest items that complement each user's unique skin tone characteristics.

This guide provides detailed instructions for developers to understand the codebase structure and how to extend it, particularly by adding new retailer integrations or enhancing the existing functionality.

## Table of Contents

1. [Project Structure](#project-structure)
2. [Key Technologies](#key-technologies)
3. [Retailer Integration System](#retailer-integration-system)
   - [How the Retailer System Works](#how-the-retailer-system-works)
   - [Adding a New Retailer](#adding-a-new-retailer)
   - [Implementing a Custom API Adapter](#implementing-a-custom-api-adapter)
4. [Machine Learning Recommendation Engine](#machine-learning-recommendation-engine)
5. [Skin Tone Analysis System](#skin-tone-analysis-system)
6. [UI Components and Screens](#ui-components-and-screens)
7. [Testing Guidelines](#testing-guidelines)
8. [Deployment Instructions](#deployment-instructions)

## Project Structure

The project follows a standard Flutter application structure with additional organization for our specific needs:

```
lib/
├── constants/          # App-wide constants
├── models/             # Data models
├── providers/          # State management 
├── screens/            # UI screens
├── services/           # Services for API interaction, ML, etc.
├── utils/              # Utility functions
├── widgets/            # Reusable UI components
├── app.dart            # App initialization
└── main.dart           # Entry point
```

Key files for retailer integrations:
- `lib/models/retailer.dart` - Data model for retailers
- `lib/services/retailer_service.dart` - Basic service for managing retailers
- `lib/services/retailer_api_adapters.dart` - Adapters for different retailer APIs
- `lib/services/retailer_manager.dart` - Manager for API keys and configuration
- `lib/screens/retailer_settings_screen.dart` - UI for managing retailer connections

## Key Technologies

- **Flutter/Dart:** Cross-platform UI framework
- **HTTP Package:** For API requests
- **Provider:** For state management
- **Shared Preferences:** For local storage
- **Python/Flask:** For the ML recommendation backend
- **scikit-learn:** For ML algorithms

## Retailer Integration System

### How the Retailer System Works

The retailer integration system is designed with flexibility and scalability in mind. It follows an adapter pattern to allow easy integration of new retailer APIs without modifying existing code.

1. **Retailer Model**: Defines the structure for retailer data
2. **Retailer Service**: Manages basic retailer operations
3. **Retailer API Adapters**: Encapsulates retailer-specific API logic
4. **Retailer Manager**: Handles API keys and configurations

The data flow works as follows:
- The app initializes the `RetailerManager` which loads configured retailers
- Active retailers are used to fetch products via their specific adapters
- Products are normalized to a common format for display and recommendation

### Adding a New Retailer

To add a new retailer to the application, follow these steps:

#### Step 1: Update Constants

Add the new retailer name and configuration in `lib/constants/app_constants.dart`:

```dart
// Add retailer name constant
static const String newRetailerSource = "New Retailer Name";

// Add retailer API configuration 
static const Map<String, dynamic> newRetailerApiConfig = {
  'requiresApiKey': true,  // Set to false if no API key is needed
  'endpoint': 'https://api.newretailer.com/products',
  'country_codes': ['US', 'UK'],  // Supported countries
};
```

#### Step 2: Add Retailer to Default List

In `lib/services/retailer_service.dart`, add the new retailer to the `_setupDefaultRetailers()` method:

```dart
// New Retailer
Retailer(
  id: 'newretailer',
  name: AppConstants.newRetailerSource,
  baseUrl: 'https://www.newretailer.com',
  logoUrl: 'https://logo.clearbit.com/newretailer.com',
  searchUrlTemplate: 'https://www.newretailer.com/search?q={query}',
  productUrlTemplate: 'https://www.newretailer.com/product/{productId}',
  retailerCategory: RetailerCategory.fashionSpecialist, // Choose appropriate category
  apiConfig: {
    'requiresApiKey': true,
    'endpoint': 'https://api.newretailer.com/products',
    'country_codes': ['US', 'UK'],
  },
),
```

#### Step 3: Update Retailer Color Handling

In the `_generateMockProductsForRetailer` method, add colors specific to the retailer:

```dart
case 'newretailer':
  colors = ['Black', 'White', 'Blue', 'Red', 'Green'];
  break;
```

### Implementing a Custom API Adapter

For optimal integration with a new retailer's API, create a custom adapter class in `lib/services/retailer_api_adapters.dart`:

```dart
// New Retailer API adapter 
class NewRetailerApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  NewRetailerApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    // Check if API key is required and provided
    if (retailer.apiConfig['requiresApiKey'] == true && apiKey == null) {
      throw Exception('New Retailer API requires an API key');
    }
    
    // Build query parameters
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (apiKey != null) {
      queryParams['api_key'] = apiKey!;
    }
    
    if (query != null) {
      queryParams['search'] = query;  // Use the parameter name from retailer's API
    }
    
    if (category != null) {
      queryParams['category'] = category;  // Use the parameter name from retailer's API
    }
    
    try {
      // Make API request
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.newretailer.com/products';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': apiKey != null ? 'Bearer $apiKey' : '',  // Adjust auth method
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['products'] ?? [];  // Adjust based on API response structure
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from New Retailer: $e');
      return [];  // Return empty list on error to avoid app crashes
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    // Similar implementation to fetchProducts but for a single product
    // ...
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert API-specific JSON to our Product model
    // This is the most important part - make sure to map all fields correctly
    
    return Product(
      id: data['id'] ?? '',  // Use the ID field from the API
      name: data['name'] ?? '',  // Use the name field from the API
      description: data['description'] ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      currency: data['currency'] ?? 'USD',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: _mapCategory(data['category']),
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['id'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '0') ?? 0,
      inStock: data['in_stock'] == true,
      additionalInfo: _extractAdditionalInfo(data),
    );
  }
  
  // Helper methods for parsing retailer-specific data
  List<String> _extractColors(Map<String, dynamic> data) {
    // Extract colors based on the API's response structure
    if (data['colors'] is List) {
      return List<String>.from(data['colors'].map((c) => c['name']));
    } else if (data['color'] is String) {
      return [data['color']];
    }
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    // Extract sizes based on the API's response structure
    // ...
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    // Extract images based on the API's response structure
    // ...
  }
  
  String _mapCategory(String? apiCategory) {
    // Map the retailer's categories to our standardized categories
    if (apiCategory == null) return 'Uncategorized';
    
    final lowerCategory = apiCategory.toLowerCase();
    if (lowerCategory.contains('shirt') || lowerCategory.contains('blouse')) {
      return 'Shirts';
    } else if (lowerCategory.contains('dress')) {
      return 'Dresses';
    }
    // Add more mappings as needed
    
    return apiCategory;  // Return original if no mapping found
  }
  
  String _determineGender(Map<String, dynamic> data) {
    // Determine gender based on the API's response structure
    // ...
  }
  
  Map<String, dynamic> _extractAdditionalInfo(Map<String, dynamic> data) {
    // Extract any additional retailer-specific information
    return {
      'brand': data['brand'],
      'material': data['material'],
      // Add any other useful fields
    };
  }
}
```

#### Step 4: Update the Factory Class

Add the new adapter to the `RetailerApiAdapterFactory` in `lib/services/retailer_api_adapters.dart`:

```dart
static RetailerApiAdapter create(Retailer retailer, {String? apiKey}) {
  switch (retailer.id) {
    case 'amazon':
      return AmazonApiAdapter(retailer, apiKey: apiKey);
    case 'flipkart':
      return FlipkartApiAdapter(retailer, apiKey: apiKey);
    // ...existing adapters...
    case 'newretailer':
      return NewRetailerApiAdapter(retailer, apiKey: apiKey);
    default:
      // For retailers without specific adapters, use the generic one
      return GenericRetailerAdapter(retailer, apiKey: apiKey);
  }
}
```

## Machine Learning Recommendation Engine

The ML recommendation engine is implemented in Python and exposed via a Flask API. It analyzes products and skin tones to provide personalized recommendations.

### Extending the ML Engine

1. The ML code is located in `ml_recommendation_engine.py`
2. To enhance the recommendation algorithm, modify the `get_recommendations` function
3. To add new features, update the `extract_product_features` function

Example of adding a new feature:
```python
def extract_product_features(product):
    # Existing feature extraction
    features = {...}
    
    # Add new feature
    if 'material' in product and product['material']:
        features['material'] = product['material']
    
    return features
```

## Skin Tone Analysis System

The skin tone analysis system classifies users' skin tones by undertone (warm, cool, neutral) and depth (light, medium, deep).

### Enhancing the Skin Tone System

1. Skin tone definitions are in `lib/models/skin_tone.dart`
2. To add more detailed analysis, expand the `SkinToneInfo` class
3. Color compatibility logic is in `lib/services/product_recommendation_service.dart`

## UI Components and Screens

The UI is built with Flutter and organized into screens and reusable widgets.

### Adding a New Screen

1. Create a new Dart file in the `lib/screens/` directory
2. Implement a new StatefulWidget or StatelessWidget class
3. Add navigation to the new screen from appropriate places

Example:
```dart
class NewFeatureScreen extends StatelessWidget {
  const NewFeatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Feature'),
      ),
      body: // Your UI implementation
    );
  }
}
```

## Testing Guidelines

For comprehensive testing:

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components in isolation
3. **Integration Tests**: Test the interaction between components
4. **End-to-End Tests**: Test the entire application flow

Creating a test for a retailer adapter:
```dart
void main() {
  group('RetailerApiAdapter Tests', () {
    test('New Retailer Adapter constructs product correctly', () {
      final adapter = NewRetailerApiAdapter(MockRetailer());
      final mockData = {
        'id': '123',
        'name': 'Test Product',
        'price': '29.99',
        // Other fields
      };
      
      final product = adapter.constructProduct(mockData);
      
      expect(product.id, '123');
      expect(product.name, 'Test Product');
      expect(product.price, 29.99);
      // Test other fields
    });
  });
}
```

## Deployment Instructions

1. **Flutter App**:
   - Build the Flutter application: `flutter build apk` (Android) or `flutter build ios` (iOS)
   - Deploy to app stores following their respective guidelines

2. **ML Backend**:
   - Deploy the Flask API to a cloud service (AWS, Google Cloud, etc.)
   - Update the API endpoint in `lib/services/product_recommendation_service.dart`

## API Key Management

For adding retailer API keys:

1. Use the RetailerManager class to securely store API keys
2. Never hardcode API keys in the source code
3. Provide instructions for users to input their own API keys via the RetailerSettingsScreen

Example of using the RetailerManager:
```dart
final retailerManager = RetailerManager();
await retailerManager.initialize();
await retailerManager.setApiKey('newretailer', 'user-provided-api-key');
```

## Contribution Guidelines

1. Follow the existing code structure and naming conventions
2. Comment your code thoroughly, especially when implementing complex logic
3. Write unit tests for new functionality
4. Update this guide when adding major new features