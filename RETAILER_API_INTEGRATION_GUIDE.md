# SkinTone Shop: Retailer API Integration Guide

This guide provides step-by-step instructions for adding new retailer APIs to the SkinTone Shop application. It's intended for developers who need to extend the app's product sources by integrating with additional e-commerce platforms.

## Table of Contents

1. [Overview of the Retailer Integration System](#overview-of-the-retailer-integration-system)
2. [Integration Workflow](#integration-workflow)
3. [Step 1: Research the Retailer API](#step-1-research-the-retailer-api)
4. [Step 2: Add Retailer Constants](#step-2-add-retailer-constants)
5. [Step 3: Create a Custom API Adapter](#step-3-create-a-custom-api-adapter)
6. [Step 4: Register the Adapter in the Factory](#step-4-register-the-adapter-in-the-factory)
7. [Step 5: Add to Default Retailers List](#step-5-add-to-default-retailers-list)
8. [Step 6: Update Product Data Mapping](#step-6-update-product-data-mapping)
9. [Step 7: Testing the Integration](#step-7-testing-the-integration)
10. [Step 8: API Key Management](#step-8-api-key-management)
11. [Common Challenges and Solutions](#common-challenges-and-solutions)
12. [Example: Complete Integration for a Fictional Retailer](#example-complete-integration-for-a-fictional-retailer)

## Overview of the Retailer Integration System

SkinTone Shop uses an adapter-based architecture to support multiple retailer APIs. This design allows adding new retailers without modifying existing code. The key components are:

- **Retailer Model**: Data structure representing a retailer
- **RetailerService**: Manages retailer data and fetches products
- **RetailerApiAdapter**: Base class that defines the interface for retailer API integration
- **RetailerManager**: Manages API keys and retailer configurations

## Integration Workflow

The process of adding a new retailer consists of these key steps:

1. Research the retailer's API documentation and requirements
2. Define retailer constants in the app
3. Create a custom API adapter to communicate with the retailer
4. Register the adapter in the factory class
5. Add the retailer to the default list
6. Adapt product data mapping to standardize fields
7. Test the integration
8. Implement proper API key management

## Step 1: Research the Retailer API

Before implementing a new retailer, gather the following information:

- **API Documentation URL**: Where the API is documented
- **API Endpoint Structure**: Base URL and endpoints for product lists and details
- **Authentication Method**: API key, OAuth, etc.
- **Rate Limiting**: Any limits on request frequency
- **Response Format**: How product data is structured in responses
- **Required Headers**: Any special headers needed for requests
- **Query Parameters**: How to filter, sort, and paginate results

Create a document summarizing this information for reference:

```
Retailer: [Retailer Name]
API Documentation: [URL]
Base Endpoint: [Base URL]
Authentication: [Method + details]
Rate Limits: [Requests per hour/day]
Key Response Fields:
- Product ID: [Field name]
- Product Name: [Field name]
- Price: [Field name]
- Color options: [Field name and structure]
- etc.
```

## Step 2: Add Retailer Constants

Update `lib/constants/app_constants.dart` to add the new retailer:

```dart
// Retailer source name
static const String newRetailerSource = "New Retailer Name";

// API Configuration
static const Map<String, dynamic> newRetailerApiConfig = {
  'requiresApiKey': true,  // Whether API requires authentication
  'endpoint': 'https://api.newretailer.com/products',  // Base API endpoint
  'country_codes': ['US', 'UK', 'DE'],  // Supported countries
  'pagination_type': 'offset',  // How pagination works (offset, cursor, page)
  'max_per_page': 50,  // Maximum items per request
  'supports_filters': true,  // Whether API supports filtering
};
```

## Step 3: Create a Custom API Adapter

Create a new class in `lib/services/retailer_api_adapters.dart` that extends `RetailerApiAdapter`:

```dart
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
    // Implementation for fetching product lists
    
    // 1. Check if API key is required and available
    if (retailer.apiConfig['requiresApiKey'] == true && (apiKey == null || apiKey!.isEmpty)) {
      throw Exception('${retailer.name} API requires an API key');
    }
    
    // 2. Prepare query parameters
    final queryParams = <String, String>{
      // Map pagination parameters to what the API expects
      'limit': limit.toString(),  // Adjust field name if needed
      'offset': offset.toString(),  // Adjust field name if needed
    };
    
    if (query != null && query.isNotEmpty) {
      // Map search query to what the API expects
      queryParams['q'] = query;  // Adjust field name if needed
    }
    
    if (category != null && category.isNotEmpty) {
      // Map category to what the API expects
      queryParams['category'] = _mapCategoryToRetailerCategory(category);
    }
    
    // 3. Prepare headers
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    // 4. Add authentication if needed
    if (apiKey != null && apiKey!.isNotEmpty) {
      // Adjust based on the API's authentication method
      headers['Authorization'] = 'Bearer $apiKey';
      // OR: queryParams['api_key'] = apiKey!;
    }
    
    try {
      // 5. Get the API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.newretailer.com/products';
      
      // 6. Build the request URL
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      // 7. Make the API request
      final response = await http.get(uri, headers: headers);
      
      // 8. Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 9. Parse the products from the response
        // Adjust the path based on the API's response structure
        final List<dynamic> items = data['products'] ?? [];
        
        // 10. Convert each product to our standard model
        return items.map((item) => constructProduct(item)).toList();
      } else {
        // Handle error responses
        print('Error from ${retailer.name} API: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch products from ${retailer.name}: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error but return empty list to avoid app crashes
      print('Error fetching from ${retailer.name}: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    // Implementation for fetching a single product's details
    // This follows a similar pattern to fetchProducts but for one item
    
    if (retailer.apiConfig['requiresApiKey'] == true && (apiKey == null || apiKey!.isEmpty)) {
      throw Exception('${retailer.name} API requires an API key');
    }
    
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    
    if (apiKey != null && apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    
    try {
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.newretailer.com/products';
      
      // Adjust the URL structure based on the API
      final uri = Uri.parse('$endpoint/$productId');
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Some APIs nest the product data
        final productData = data['product'] ?? data;
        
        return constructProduct(productData);
      } else {
        throw Exception('Failed to fetch product details from ${retailer.name}: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details from ${retailer.name}: $e');
      return null;
    }
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert the retailer's product data structure to our standardized Product model
    
    // This is the most important method - it maps the retailer's specific
    // data structure to our app's standardized Product model
    
    return Product(
      id: data['id'] ?? data['product_id'] ?? '',  // Try multiple possible field names
      name: data['name'] ?? data['title'] ?? '',
      description: data['description'] ?? data['long_description'] ?? '',
      price: _extractPrice(data),
      currency: _extractCurrency(data),
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: _extractCategory(data),
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['id'] ?? data['product_id'] ?? ''),
      gender: _determineGender(data),
      rating: _extractRating(data),
      reviewCount: _extractReviewCount(data),
      inStock: _isInStock(data),
      additionalInfo: _extractAdditionalInfo(data),
    );
  }
  
  // Helper methods for extracting specific data
  
  double _extractPrice(Map<String, dynamic> data) {
    // Handle different price structures
    if (data['price'] is num) {
      return (data['price'] as num).toDouble();
    } else if (data['price'] is String) {
      return double.tryParse(data['price']) ?? 0.0;
    } else if (data['price'] is Map) {
      // Some APIs nest price data
      final priceData = data['price'];
      if (priceData['current'] is num) {
        return (priceData['current'] as num).toDouble();
      } else if (priceData['current'] is String) {
        return double.tryParse(priceData['current']) ?? 0.0;
      }
    }
    return 0.0;
  }
  
  String _extractCurrency(Map<String, dynamic> data) {
    // Extract currency code
    if (data['currency'] is String) {
      return data['currency'];
    } else if (data['price'] is Map && data['price']['currency'] is String) {
      return data['price']['currency'];
    }
    return 'USD';  // Default
  }
  
  List<String> _extractColors(Map<String, dynamic> data) {
    // Handle different color data structures
    
    // Scenario 1: Colors as a simple list of strings
    if (data['colors'] is List) {
      return (data['colors'] as List)
          .map((c) => c is String ? c : (c['name'] ?? '').toString())
          .where((c) => c.isNotEmpty)
          .toList();
    }
    
    // Scenario 2: Single color as string
    if (data['color'] is String && data['color'].toString().isNotEmpty) {
      return [data['color'].toString()];
    }
    
    // Scenario 3: Colors in a nested "variants" or "options" structure
    if (data['variants'] is List || data['options'] is List) {
      final variants = data['variants'] ?? data['options'] ?? [];
      final colorOption = variants.firstWhere(
        (v) => v['name']?.toString().toLowerCase() == 'color',
        orElse: () => {},
      );
      
      if (colorOption.isNotEmpty && colorOption['values'] is List) {
        return (colorOption['values'] as List)
            .map((v) => v is String ? v : v['name']?.toString() ?? '')
            .where((c) => c.isNotEmpty)
            .toList();
      }
    }
    
    // Default if no colors found
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    // Similar to _extractColors but for sizes
    // Implementation depends on the retailer's data structure
    return ['S', 'M', 'L', 'XL'];  // Default placeholder
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    // Extract product images
    List<String> images = [];
    
    // Scenario 1: Images as a list of URLs
    if (data['images'] is List) {
      images = (data['images'] as List)
          .map((img) => img is String ? img : (img['url'] ?? img['src'] ?? '').toString())
          .where((url) => url.isNotEmpty)
          .toList();
    }
    
    // Scenario 2: Single image
    else if (data['image'] is String) {
      images = [data['image']];
    }
    
    // Scenario 3: Image in a nested structure
    else if (data['image'] is Map && data['image']['url'] is String) {
      images = [data['image']['url']];
    }
    
    // Ensure we have at least a placeholder
    if (images.isEmpty) {
      images = ['https://via.placeholder.com/400?text=No+Image'];
    }
    
    return images;
  }
  
  String _extractCategory(Map<String, dynamic> data) {
    // Map the retailer's category to our standardized categories
    String originalCategory = '';
    
    if (data['category'] is String) {
      originalCategory = data['category'];
    } else if (data['product_type'] is String) {
      originalCategory = data['product_type'];
    } else if (data['type'] is String) {
      originalCategory = data['type'];
    }
    
    // Map to our standard categories
    return _mapToStandardCategory(originalCategory);
  }
  
  String _mapToStandardCategory(String retailerCategory) {
    // Convert retailer-specific category names to our standard ones
    final lowercaseCategory = retailerCategory.toLowerCase();
    
    if (lowercaseCategory.contains('t-shirt') || 
        lowercaseCategory.contains('tshirt') ||
        lowercaseCategory.contains('tee')) {
      return 'Tops';
    } else if (lowercaseCategory.contains('dress')) {
      return 'Dresses';
    } else if (lowercaseCategory.contains('shirt') || 
               lowercaseCategory.contains('blouse')) {
      return 'Shirts';
    } else if (lowercaseCategory.contains('pant') || 
               lowercaseCategory.contains('trouser') ||
               lowercaseCategory.contains('jean')) {
      return 'Pants';
    } else if (lowercaseCategory.contains('skirt')) {
      return 'Skirts';
    } else if (lowercaseCategory.contains('jacket') || 
               lowercaseCategory.contains('coat') ||
               lowercaseCategory.contains('sweater')) {
      return 'Outerwear';
    } else if (lowercaseCategory.contains('accessory') || 
               lowercaseCategory.contains('accessoire') ||
               lowercaseCategory.contains('hat') ||
               lowercaseCategory.contains('scarf') ||
               lowercaseCategory.contains('bag')) {
      return 'Accessories';
    }
    
    // If no matching category found, return original or Uncategorized
    return retailerCategory.isNotEmpty ? retailerCategory : 'Uncategorized';
  }
  
  String _determineGender(Map<String, dynamic> data) {
    // Determine the gender target of the product
    // Common field names: 'gender', 'department', 'audience'
    if (data['gender'] is String) {
      final gender = data['gender'].toString().toLowerCase();
      if (gender.contains('women') || gender.contains('female')) {
        return 'women';
      } else if (gender.contains('men') || gender.contains('male')) {
        return 'men';
      }
    }
    
    // Check department
    if (data['department'] is String) {
      final dept = data['department'].toString().toLowerCase();
      if (dept.contains('women') || dept.contains('female')) {
        return 'women';
      } else if (dept.contains('men') || dept.contains('male')) {
        return 'men';
      }
    }
    
    // Check category or product type for gender hints
    String textToSearch = '';
    if (data['category'] is String) textToSearch += data['category'].toString().toLowerCase();
    if (data['product_type'] is String) textToSearch += data['product_type'].toString().toLowerCase();
    if (data['name'] is String) textToSearch += data['name'].toString().toLowerCase();
    
    if (textToSearch.contains('women') || textToSearch.contains('ladies') || textToSearch.contains('girl')) {
      return 'women';
    } else if (textToSearch.contains('men') || textToSearch.contains('boy')) {
      return 'men';
    }
    
    // Default to unisex if no gender information found
    return 'unisex';
  }
  
  double _extractRating(Map<String, dynamic> data) {
    // Extract product rating
    if (data['rating'] is num) {
      return (data['rating'] as num).toDouble();
    } else if (data['rating'] is String) {
      return double.tryParse(data['rating']) ?? 0.0;
    } else if (data['ratings'] is Map && data['ratings']['average'] is num) {
      return (data['ratings']['average'] as num).toDouble();
    }
    return 0.0;
  }
  
  int _extractReviewCount(Map<String, dynamic> data) {
    // Extract review count
    if (data['review_count'] is num) {
      return (data['review_count'] as num).toInt();
    } else if (data['reviews_count'] is num) {
      return (data['reviews_count'] as num).toInt();
    } else if (data['ratings'] is Map && data['ratings']['count'] is num) {
      return (data['ratings']['count'] as num).toInt();
    }
    return 0;
  }
  
  bool _isInStock(Map<String, dynamic> data) {
    // Determine if the product is in stock
    if (data['in_stock'] is bool) {
      return data['in_stock'];
    } else if (data['is_in_stock'] is bool) {
      return data['is_in_stock'];
    } else if (data['availability'] is String) {
      final availability = data['availability'].toString().toLowerCase();
      return availability.contains('in stock') || 
             availability.contains('available') || 
             !availability.contains('out of stock');
    } else if (data['stock'] is num) {
      return (data['stock'] as num) > 0;
    }
    return true;  // Default to true if no stock information is available
  }
  
  Map<String, dynamic> _extractAdditionalInfo(Map<String, dynamic> data) {
    // Extract any additional useful information
    final additionalInfo = <String, dynamic>{};
    
    if (data['brand'] != null) {
      additionalInfo['brand'] = data['brand'];
    }
    
    if (data['material'] != null) {
      additionalInfo['material'] = data['material'];
    }
    
    if (data['features'] is List) {
      additionalInfo['features'] = data['features'];
    }
    
    // Add any sales or discount information
    if (data['on_sale'] is bool) {
      additionalInfo['isOnSale'] = data['on_sale'];
    }
    
    if (data['discount'] is num) {
      additionalInfo['discount'] = data['discount'];
    }
    
    if (data['original_price'] is num || data['original_price'] is String) {
      additionalInfo['originalPrice'] = data['original_price'];
    }
    
    return additionalInfo;
  }
  
  String _mapCategoryToRetailerCategory(String category) {
    // Convert our standard category to the retailer's category taxonomy
    // This is the inverse of _mapToStandardCategory
    // Implementation depends on the retailer's taxonomy
    return category;  // Simple pass-through for now
  }
}
```

## Step 4: Register the Adapter in the Factory

Update the `RetailerApiAdapterFactory` class in `lib/services/retailer_api_adapters.dart`:

```dart
static RetailerApiAdapter create(Retailer retailer, {String? apiKey}) {
  switch (retailer.id) {
    case 'amazon':
      return AmazonApiAdapter(retailer, apiKey: apiKey);
    case 'flipkart':
      return FlipkartApiAdapter(retailer, apiKey: apiKey);
    // Add your new retailer
    case 'newretailer':
      return NewRetailerApiAdapter(retailer, apiKey: apiKey);
    // Existing adapters...
    default:
      // Default to generic adapter
      return GenericRetailerAdapter(retailer, apiKey: apiKey);
  }
}
```

## Step 5: Add to Default Retailers List

Update the `_setupDefaultRetailers()` method in `lib/services/retailer_service.dart`:

```dart
// Add your new retailer to the list
Retailer(
  id: 'newretailer',
  name: AppConstants.newRetailerSource,
  baseUrl: 'https://www.newretailer.com',
  logoUrl: 'https://logo.clearbit.com/newretailer.com',
  searchUrlTemplate: 'https://www.newretailer.com/search?q={query}',
  productUrlTemplate: 'https://www.newretailer.com/product/{productId}',
  retailerCategory: RetailerCategory.fashionSpecialist,  // Choose appropriate category
  apiConfig: {
    'requiresApiKey': true,
    'endpoint': 'https://api.newretailer.com/products',
    'country_codes': ['US', 'UK', 'DE'],
  },
),
```

## Step 6: Update Product Data Mapping

Update the color mapping in the `_generateMockProductsForRetailer` method in `lib/services/retailer_service.dart`:

```dart
case 'newretailer':
  colors = ['Black', 'White', 'Blue', 'Red', 'Green'];
  break;
```

## Step 7: Testing the Integration

Test your integration with the new retailer:

1. **Unit Test**: Create a test file for your adapter
   ```dart
   void main() {
     group('NewRetailerApiAdapter Tests', () {
       test('constructs product correctly from API response', () {
         final adapter = NewRetailerApiAdapter(mockRetailer);
         final testData = {
           'id': '123',
           'name': 'Test Product',
           'price': 29.99,
           // Add other fields
         };
         
         final product = adapter.constructProduct(testData);
         
         expect(product.id, '123');
         expect(product.name, 'Test Product');
         expect(product.price, 29.99);
       });
     });
   }
   ```

2. **Integration Test**: Test the retailer service with the new adapter
   ```dart
   void main() {
     group('RetailerService Integration Tests', () {
       test('fetches products from new retailer', () async {
         final retailerService = RetailerService();
         await retailerService.initialize();
         
         final products = await retailerService.fetchProductsFromRetailers(
           specificRetailerIds: ['newretailer'],
         );
         
         expect(products, isNotEmpty);
         expect(products.first.retailer, 'New Retailer Name');
       });
     });
   }
   ```

3. **Manual Testing**: Test the retailer integration in the app UI

## Step 8: API Key Management

If your retailer requires an API key, ensure it's properly handled:

1. Update the `RetailerSettingsScreen` to allow users to enter the API key
2. Use the `RetailerManager` to securely store the API key:
   ```dart
   await _retailerManager.setApiKey('newretailer', userProvidedApiKey);
   ```
3. Retrieve the API key when needed:
   ```dart
   final apiKey = await _retailerManager.getApiKey('newretailer');
   ```

## Common Challenges and Solutions

### Handling Rate Limits

If the API has rate limits, implement strategies to avoid exceeding them:

```dart
// Add rate limiting tracking
DateTime _lastRequestTime;
int _requestsInWindow = 0;
final int _maxRequestsPerWindow = 50;  // From API documentation
final Duration _rateLimitWindow = Duration(hours: 1);

Future<void> _respectRateLimit() async {
  final now = DateTime.now();
  
  // Reset counter if window has passed
  if (_lastRequestTime != null && 
      now.difference(_lastRequestTime) > _rateLimitWindow) {
    _requestsInWindow = 0;
  }
  
  // Check if we're at the limit
  if (_requestsInWindow >= _maxRequestsPerWindow) {
    final timeToWait = _rateLimitWindow - now.difference(_lastRequestTime);
    if (timeToWait.inSeconds > 0) {
      print('Rate limit reached, waiting ${timeToWait.inSeconds} seconds');
      await Future.delayed(timeToWait);
      _requestsInWindow = 0;
    }
  }
  
  _lastRequestTime = now;
  _requestsInWindow++;
}
```

### Handling Different Authentication Methods

Different retailers may use different authentication methods:

```dart
// For API Key in header
headers['X-API-Key'] = apiKey;

// For Bearer token
headers['Authorization'] = 'Bearer $apiKey';

// For Basic auth
headers['Authorization'] = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

// For OAuth2
// This requires implementing a more complex OAuth flow
```

### Handling Pagination

Different APIs handle pagination differently:

```dart
// Offset-based pagination
queryParams['offset'] = offset.toString();
queryParams['limit'] = limit.toString();

// Page-based pagination
queryParams['page'] = (offset ~/ limit + 1).toString();
queryParams['per_page'] = limit.toString();

// Cursor-based pagination
if (previousResponse != null && previousResponse['next_cursor'] != null) {
  queryParams['cursor'] = previousResponse['next_cursor'];
}
```

## Example: Complete Integration for a Fictional Retailer

Here's a complete example for a fictional retailer called "FashionMart":

```dart
// In app_constants.dart
static const String fashionMartSource = "FashionMart";
static const Map<String, dynamic> fashionMartApiConfig = {
  'requiresApiKey': true,
  'endpoint': 'https://api.fashionmart.com/v2/products',
  'country_codes': ['US', 'CA', 'UK'],
  'pagination_type': 'page',
};

// In retailer_api_adapters.dart
class FashionMartApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  FashionMartApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (apiKey == null) {
      throw Exception('FashionMart API requires an API key');
    }
    
    final queryParams = <String, String>{
      'page': (offset ~/ limit + 1).toString(),
      'items_per_page': limit.toString(),
    };
    
    if (query != null) {
      queryParams['keyword'] = query;
    }
    
    if (category != null) {
      queryParams['product_type'] = category.toLowerCase();
    }
    
    try {
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.fashionmart.com/v2/products';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-API-Key': apiKey!,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from FashionMart: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    // Implementation
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    return Product(
      id: data['product_id'] ?? '',
      name: data['product_name'] ?? '',
      description: data['product_description'] ?? '',
      price: double.tryParse(data['price']['current_price']?.toString() ?? '0') ?? 0.0,
      currency: data['price']['currency_code'] ?? 'USD',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: data['product_type'] ?? 'Uncategorized',
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['product_id'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '0') ?? 0,
      inStock: data['inventory']['available'] == true,
      additionalInfo: {
        'brand': data['brand'],
        'isOnSale': data['on_sale'],
        'originalPrice': data['price']['regular_price'],
        'discountPercentage': data['price']['discount_percentage'],
      },
    );
  }
  
  // Helper methods
  List<String> _extractColors(Map<String, dynamic> data) {
    if (data['available_colors'] is List) {
      return List<String>.from(data['available_colors'].map((c) => c['color_name']));
    }
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    if (data['available_sizes'] is List) {
      return List<String>.from(data['available_sizes']);
    }
    return ['One Size'];
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['product_images'] is List) {
      return List<String>.from(data['product_images'].map((img) => img['high_res_url']));
    }
    return ['https://via.placeholder.com/400?text=No+Image'];
  }
  
  String _determineGender(Map<String, dynamic> data) {
    if (data['department'] is String) {
      final dept = data['department'].toString().toLowerCase();
      if (dept.contains('women')) return 'women';
      if (dept.contains('men')) return 'men';
    }
    return 'unisex';
  }
}

// In RetailerApiAdapterFactory
static RetailerApiAdapter create(Retailer retailer, {String? apiKey}) {
  switch (retailer.id) {
    // Existing cases...
    case 'fashionmart':
      return FashionMartApiAdapter(retailer, apiKey: apiKey);
    default:
      return GenericRetailerAdapter(retailer, apiKey: apiKey);
  }
}

// In RetailerService._setupDefaultRetailers()
// FashionMart
Retailer(
  id: 'fashionmart',
  name: AppConstants.fashionMartSource,
  baseUrl: 'https://www.fashionmart.com',
  logoUrl: 'https://logo.clearbit.com/fashionmart.com',
  searchUrlTemplate: 'https://www.fashionmart.com/search?q={query}',
  productUrlTemplate: 'https://www.fashionmart.com/product/{productId}',
  retailerCategory: RetailerCategory.fashionSpecialist,
  apiConfig: AppConstants.fashionMartApiConfig,
),
```

Following this guide will ensure your retailer integration works seamlessly with the existing system and maintains the same high-quality user experience throughout the app.