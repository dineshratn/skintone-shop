import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/retailer.dart';

// Base adapter class for retailer-specific APIs
abstract class RetailerApiAdapter {
  final Retailer retailer;
  
  RetailerApiAdapter(this.retailer);
  
  // Main method to fetch products, should be implemented by specific adapters
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  });
  
  // Helper method for product details
  Future<Product?> getProductDetails(String productId);
  
  // Helper method for constructing product from retailer-specific response
  Product constructProduct(Map<String, dynamic> data);
}

// Amazon API adapter 
class AmazonApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  AmazonApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (apiKey == null) {
      throw Exception('Amazon API requires an API key');
    }
    
    // This is a placeholder for the actual Amazon API implementation
    // In a real app, you would use Amazon Product Advertising API
    
    final queryParams = <String, String>{
      'api_key': apiKey!,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (query != null) {
      queryParams['keywords'] = query;
    }
    
    if (category != null) {
      queryParams['browse_node'] = _mapCategoryToAmazonNode(category);
    }
    
    try {
      // This is a placeholder URL, replace with actual Amazon API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.amazon.com/products';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products from Amazon: ${response.statusCode}');
      }
    } catch (e) {
      // In case of error, return empty list instead of throwing to allow
      // the app to continue with other retailers
      print('Error fetching from Amazon: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    if (apiKey == null) {
      throw Exception('Amazon API requires an API key');
    }
    
    try {
      // This is a placeholder URL, replace with actual Amazon API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.amazon.com/products';
      
      final uri = Uri.parse('$endpoint/$productId');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return constructProduct(data);
      } else {
        throw Exception('Failed to fetch product details from Amazon: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details from Amazon: $e');
      return null;
    }
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert Amazon-specific JSON structure to our Product model
    // This implementation is a placeholder for the actual parsing logic
    
    return Product(
      id: data['asin'] ?? '',
      name: data['title'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      currency: data['currency'] ?? 'USD',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: _extractCategory(data),
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['asin'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '0') ?? 0,
      inStock: data['in_stock'] == true,
      additionalInfo: _extractAdditionalInfo(data),
    );
  }
  
  // Helper methods for parsing Amazon specific data
  
  List<String> _extractColors(Map<String, dynamic> data) {
    if (data['color_options'] is List) {
      return List<String>.from(data['color_options']);
    } else if (data['color'] is String) {
      return [data['color']];
    }
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    if (data['size_options'] is List) {
      return List<String>.from(data['size_options']);
    } else if (data['size'] is String) {
      return [data['size']];
    }
    return ['One Size'];
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['images'] is List) {
      return List<String>.from(data['images']);
    } else if (data['image'] is String) {
      return [data['image']];
    }
    return ['https://via.placeholder.com/400?text=No+Image'];
  }
  
  String _extractCategory(Map<String, dynamic> data) {
    if (data['category'] is String) {
      return data['category'];
    } else if (data['department'] is String) {
      return data['department'];
    }
    return 'Uncategorized';
  }
  
  String _determineGender(Map<String, dynamic> data) {
    final category = data['category']?.toString().toLowerCase() ?? '';
    
    if (category.contains('women') || category.contains('girl')) {
      return 'women';
    } else if (category.contains('men') || category.contains('boy')) {
      return 'men';
    }
    
    return 'unisex';
  }
  
  Map<String, dynamic> _extractAdditionalInfo(Map<String, dynamic> data) {
    return {
      'brand': data['brand'],
      'best_seller_rank': data['best_seller_rank'],
      'prime_eligible': data['prime_eligible'],
    };
  }
  
  String _mapCategoryToAmazonNode(String category) {
    // Map our generic categories to Amazon browse node IDs
    // These are placeholder values, real implementation would use actual Amazon category IDs
    switch (category.toLowerCase()) {
      case 'tops':
        return '1040658';
      case 'dresses':
        return '1045024';
      case 'shirts':
        return '1040668';
      case 'pants':
        return '1040682';
      case 'skirts':
        return '1045022';
      case 'outerwear':
        return '1046378';
      case 'accessories':
        return '2474936011';
      default:
        return '7141123011'; // Default to clothing
    }
  }
}

// Flipkart API adapter 
class FlipkartApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  FlipkartApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (apiKey == null) {
      throw Exception('Flipkart API requires an API key');
    }
    
    // This is a placeholder for the actual Flipkart API implementation
    
    final queryParams = <String, String>{
      'api_key': apiKey!,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (query != null) {
      queryParams['q'] = query;
    }
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    try {
      // This is a placeholder URL, replace with actual Flipkart API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.flipkart.com/products';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Fk-Affiliate-Id': apiKey!,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['products'] ?? [];
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products from Flipkart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from Flipkart: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    if (apiKey == null) {
      throw Exception('Flipkart API requires an API key');
    }
    
    try {
      // This is a placeholder URL, replace with actual Flipkart API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.flipkart.com/products';
      
      final uri = Uri.parse('$endpoint/$productId');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Fk-Affiliate-Id': apiKey!,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return constructProduct(data);
      } else {
        throw Exception('Failed to fetch product details from Flipkart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details from Flipkart: $e');
      return null;
    }
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert Flipkart-specific JSON structure to our Product model
    
    return Product(
      id: data['product_id'] ?? '',
      name: data['title'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['selling_price']?.toString() ?? '0') ?? 0.0,
      currency: data['currency'] ?? 'INR',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: data['category_path']?.toString().split('>')?.last?.trim() ?? 'Uncategorized',
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['product_id'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '0') ?? 0,
      inStock: data['instock'] == true,
      additionalInfo: {
        'brand': data['brand'],
        'discount': data['discount'],
        'flipkart_assured': data['flipkart_assured'],
      },
    );
  }
  
  // Helper methods for parsing Flipkart specific data
  
  List<String> _extractColors(Map<String, dynamic> data) {
    final colorVariants = data['variant_options']?.firstWhere(
      (variant) => variant['name'] == 'Color',
      orElse: () => {'values': []},
    );
    
    if (colorVariants != null && colorVariants['values'] is List) {
      return List<String>.from(colorVariants['values'].map((v) => v['value']));
    } else if (data['color'] is String) {
      return [data['color']];
    }
    
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    final sizeVariants = data['variant_options']?.firstWhere(
      (variant) => variant['name'] == 'Size',
      orElse: () => {'values': []},
    );
    
    if (sizeVariants != null && sizeVariants['values'] is List) {
      return List<String>.from(sizeVariants['values'].map((v) => v['value']));
    } else if (data['size'] is String) {
      return [data['size']];
    }
    
    return ['One Size'];
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['images'] is List) {
      return List<String>.from(data['images']);
    } else if (data['image'] is String) {
      return [data['image']];
    }
    
    return ['https://via.placeholder.com/400?text=No+Image'];
  }
  
  String _determineGender(Map<String, dynamic> data) {
    final category = data['category_path']?.toString().toLowerCase() ?? '';
    
    if (category.contains('women') || category.contains('girl')) {
      return 'women';
    } else if (category.contains('men') || category.contains('boy')) {
      return 'men';
    }
    
    return 'unisex';
  }
}

// Nordstrom API adapter 
class NordstromApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  NordstromApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (apiKey == null) {
      throw Exception('Nordstrom API requires an API key');
    }
    
    // This is a placeholder for the actual Nordstrom API implementation
    
    final queryParams = <String, String>{
      'api_key': apiKey!,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (query != null) {
      queryParams['keyword'] = query;
    }
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    try {
      // This is a placeholder URL, replace with actual Nordstrom API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.nordstrom.com/products';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['products'] ?? [];
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products from Nordstrom: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from Nordstrom: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    if (apiKey == null) {
      throw Exception('Nordstrom API requires an API key');
    }
    
    try {
      // This is a placeholder URL, replace with actual Nordstrom API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.nordstrom.com/products';
      
      final uri = Uri.parse('$endpoint/$productId');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return constructProduct(data);
      } else {
        throw Exception('Failed to fetch product details from Nordstrom: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details from Nordstrom: $e');
      return null;
    }
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert Nordstrom-specific JSON structure to our Product model
    
    return Product(
      id: data['style_id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      currency: data['currency'] ?? 'USD',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: data['category'] ?? 'Uncategorized',
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['style_id'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '0') ?? 0,
      inStock: data['in_stock'] == true,
      additionalInfo: {
        'brand': data['brand'],
        'designer': data['designer'],
        'is_sale': data['is_sale'],
      },
    );
  }
  
  // Helper methods for parsing Nordstrom specific data
  
  List<String> _extractColors(Map<String, dynamic> data) {
    if (data['available_colors'] is List) {
      return List<String>.from(data['available_colors'].map((c) => c['name']));
    } else if (data['color'] is String) {
      return [data['color']];
    }
    
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    if (data['available_sizes'] is List) {
      return List<String>.from(data['available_sizes'].map((s) => s['name']));
    } else if (data['size'] is String) {
      return [data['size']];
    }
    
    return ['One Size'];
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['images'] is List) {
      return List<String>.from(data['images'].map((img) => img['url']));
    } else if (data['image'] is String) {
      return [data['image']];
    }
    
    return ['https://via.placeholder.com/400?text=No+Image'];
  }
  
  String _determineGender(Map<String, dynamic> data) {
    final department = data['department']?.toString().toLowerCase() ?? '';
    
    if (department.contains('women')) {
      return 'women';
    } else if (department.contains('men')) {
      return 'men';
    }
    
    return 'unisex';
  }
}

// Macy's API adapter 
class MacysApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  MacysApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (apiKey == null) {
      throw Exception('Macy\'s API requires an API key');
    }
    
    final queryParams = <String, String>{
      'apiKey': apiKey!,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (query != null) {
      queryParams['searchphrase'] = query;
    }
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    try {
      // This is a placeholder URL, replace with actual Macy's API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.macys.com/v4/catalog/search';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Macys-Webservice-Client-Id': apiKey!,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['searchresults'] ?? [];
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products from Macy\'s: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from Macy\'s: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    if (apiKey == null) {
      throw Exception('Macy\'s API requires an API key');
    }
    
    try {
      // This is a placeholder URL, replace with actual Macy's API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.macys.com/v4/catalog/product';
      
      final uri = Uri.parse('$endpoint/$productId');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Macys-Webservice-Client-Id': apiKey!,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return constructProduct(data);
      } else {
        throw Exception('Failed to fetch product details from Macy\'s: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details from Macy\'s: $e');
      return null;
    }
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert Macy's-specific JSON structure to our Product model
    
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: double.tryParse(data['price']['current']['value']?.toString() ?? '0') ?? 0.0,
      currency: data['price']['current']['currency'] ?? 'USD',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: data['category'] ?? 'Uncategorized',
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['id'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['customerRating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['numberOfReviews']?.toString() ?? '0') ?? 0,
      inStock: data['availability'] == 'in_stock',
      additionalInfo: {
        'brand': data['brand'] ?? '',
        'isOnSale': data['price']['isOnSale'] ?? false,
        'originalPrice': data['price']['original']?['value'] ?? 0.0,
      },
    );
  }
  
  // Helper methods for parsing Macy's specific data
  
  List<String> _extractColors(Map<String, dynamic> data) {
    if (data['colors'] is List) {
      return List<String>.from(data['colors'].map((c) => c['name']));
    } else if (data['color'] is String) {
      return [data['color']];
    }
    
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    if (data['sizes'] is List) {
      return List<String>.from(data['sizes'].map((s) => s['name']));
    } else if (data['size'] is String) {
      return [data['size']];
    }
    
    return ['One Size'];
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['images'] is List) {
      return List<String>.from(data['images'].map((img) => img['url']));
    } else if (data['image'] is Map) {
      return [data['image']['url']];
    }
    
    return ['https://via.placeholder.com/400?text=No+Image'];
  }
  
  String _determineGender(Map<String, dynamic> data) {
    final department = data['gender']?.toString().toLowerCase() ?? '';
    
    if (department.contains('women')) {
      return 'women';
    } else if (department.contains('men')) {
      return 'men';
    }
    
    return 'unisex';
  }
}

// Target API adapter 
class TargetApiAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  TargetApiAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    if (apiKey == null) {
      throw Exception('Target API requires an API key');
    }
    
    final queryParams = <String, String>{
      'key': apiKey!,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (query != null) {
      queryParams['keyword'] = query;
    }
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    try {
      // This is a placeholder URL, replace with actual Target API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.target.com/products/v3';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['products'] ?? [];
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products from Target: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from Target: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    if (apiKey == null) {
      throw Exception('Target API requires an API key');
    }
    
    try {
      // This is a placeholder URL, replace with actual Target API endpoint
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.target.com/products/v3';
      
      final uri = Uri.parse('$endpoint/$productId');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'key': apiKey!,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return constructProduct(data);
      } else {
        throw Exception('Failed to fetch product details from Target: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details from Target: $e');
      return null;
    }
  }
  
  @override
  Product constructProduct(Map<String, dynamic> data) {
    // Convert Target-specific JSON structure to our Product model
    
    return Product(
      id: data['tcin'] ?? '',
      name: data['item']['product_description']['title'] ?? '',
      description: data['item']['product_description']['downstream_description'] ?? '',
      price: double.tryParse(data['price']['current_retail']?.toString() ?? '0') ?? 0.0,
      currency: 'USD',
      colors: _extractColors(data),
      sizes: _extractSizes(data),
      images: _extractImages(data),
      category: _extractCategory(data),
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(data['tcin'] ?? ''),
      gender: _determineGender(data),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['total_reviews']?.toString() ?? '0') ?? 0,
      inStock: _determineInStock(data),
      additionalInfo: {
        'brand': data['item']['product_brand']['brand'] ?? '',
        'isOnSale': data['price']['is_on_sale'] ?? false,
        'regularPrice': data['price']['reg_retail'] ?? 0.0,
      },
    );
  }
  
  // Helper methods for parsing Target specific data
  
  List<String> _extractColors(Map<String, dynamic> data) {
    final variations = data['item']['variation_attributes']?.firstWhere(
      (attr) => attr['name'] == 'color',
      orElse: () => {'values': []},
    );
    
    if (variations != null && variations['values'] is List) {
      return List<String>.from(variations['values'].map((v) => v['value']));
    }
    
    return ['Unknown'];
  }
  
  List<String> _extractSizes(Map<String, dynamic> data) {
    final variations = data['item']['variation_attributes']?.firstWhere(
      (attr) => attr['name'] == 'size',
      orElse: () => {'values': []},
    );
    
    if (variations != null && variations['values'] is List) {
      return List<String>.from(variations['values'].map((v) => v['value']));
    }
    
    return ['One Size'];
  }
  
  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['item']['enrichment']['images'] is List) {
      return List<String>.from(data['item']['enrichment']['images'].map((img) => img['base_url']));
    }
    
    return ['https://via.placeholder.com/400?text=No+Image'];
  }
  
  String _extractCategory(Map<String, dynamic> data) {
    final primaryCategory = data['item']['primary_category'] ?? {};
    return primaryCategory['name'] ?? 'Uncategorized';
  }
  
  String _determineGender(Map<String, dynamic> data) {
    // Try to extract gender from product classification
    final classifications = data['item']['product_classification'];
    if (classifications != null) {
      final classStr = classifications.toString().toLowerCase();
      if (classStr.contains('women')) return 'women';
      if (classStr.contains('men')) return 'men';
    }
    
    return 'unisex';
  }
  
  bool _determineInStock(Map<String, dynamic> data) {
    final availability = data['fulfillment']['is_available_to_promise'];
    return availability == true;
  }
}

// Generic retailer adapter for retailers without specific implementations
class GenericRetailerAdapter extends RetailerApiAdapter {
  final String? apiKey;
  
  GenericRetailerAdapter(Retailer retailer, {this.apiKey}) : super(retailer);
  
  @override
  Future<List<Product>> fetchProducts({
    String? query, 
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    final requiresApiKey = retailer.apiConfig['requiresApiKey'] == true;
    
    if (requiresApiKey && (apiKey == null || apiKey!.isEmpty)) {
      throw Exception('${retailer.name} API requires an API key');
    }
    
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    
    if (apiKey != null) {
      queryParams['api_key'] = apiKey!;
    }
    
    if (query != null) {
      queryParams['q'] = query;
    }
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    try {
      // Use the retailer's configured endpoint or a default one
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.${retailer.id}.com/products';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      // Add authorization if we have an API key
      if (apiKey != null && apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Try to find a list of products in common response formats
        List<dynamic> items = [];
        if (data['products'] is List) {
          items = data['products'];
        } else if (data['items'] is List) {
          items = data['items'];
        } else if (data['results'] is List) {
          items = data['results'];
        } else if (data['data'] is List) {
          items = data['data'];
        } else if (data is List) {
          items = data;
        }
        
        return items.map((item) => constructProduct(item)).toList();
      } else {
        throw Exception('Failed to fetch products from ${retailer.name}: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching from ${retailer.name}: $e');
      return [];
    }
  }
  
  @override
  Future<Product?> getProductDetails(String productId) async {
    final requiresApiKey = retailer.apiConfig['requiresApiKey'] == true;
    
    if (requiresApiKey && (apiKey == null || apiKey!.isEmpty)) {
      throw Exception('${retailer.name} API requires an API key');
    }
    
    try {
      // Use the retailer's configured endpoint or a default one
      final endpoint = retailer.apiConfig['endpoint'] as String? ?? 
          'https://api.${retailer.id}.com/products';
      
      final uri = Uri.parse('$endpoint/$productId');
      
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      // Add authorization if we have an API key
      if (apiKey != null && apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Some APIs wrap the product in a response object
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
    // Generic product construction trying common field names
    
    // Try to find an ID
    final id = data['id'] ?? data['product_id'] ?? data['sku'] ?? '';
    
    // Try to find a name/title
    final name = data['name'] ?? data['title'] ?? data['product_name'] ?? 'Unknown Product';
    
    // Try to find a description
    final description = data['description'] ?? data['product_description'] ?? '';
    
    // Try to find pricing information
    dynamic price = 0.0;
    String currency = 'USD';
    
    if (data['price'] is Map) {
      price = data['price']['current'] ?? data['price']['value'] ?? 0.0;
      currency = data['price']['currency'] ?? 'USD';
    } else if (data['price'] is num) {
      price = data['price'];
    } else if (data['current_price'] is num) {
      price = data['current_price'];
    }
    
    // Try to get a numeric price
    double priceValue = 0.0;
    if (price is String) {
      priceValue = double.tryParse(price) ?? 0.0;
    } else if (price is num) {
      priceValue = price.toDouble();
    }
    
    // Try to find color information
    List<String> colors = [];
    if (data['colors'] is List) {
      colors = List<String>.from(data['colors'].map((c) => 
        c is String ? c : (c['name'] ?? c['value'] ?? 'Unknown')
      ));
    } else if (data['color'] is String) {
      colors = [data['color']];
    } else if (data['available_colors'] is List) {
      colors = List<String>.from(data['available_colors'].map((c) => 
        c is String ? c : (c['name'] ?? c['value'] ?? 'Unknown')
      ));
    }
    
    if (colors.isEmpty) {
      colors = ['Unknown'];
    }
    
    // Try to find size information
    List<String> sizes = [];
    if (data['sizes'] is List) {
      sizes = List<String>.from(data['sizes'].map((s) => 
        s is String ? s : (s['name'] ?? s['value'] ?? 'Unknown')
      ));
    } else if (data['size'] is String) {
      sizes = [data['size']];
    } else if (data['available_sizes'] is List) {
      sizes = List<String>.from(data['available_sizes'].map((s) => 
        s is String ? s : (s['name'] ?? s['value'] ?? 'Unknown')
      ));
    }
    
    if (sizes.isEmpty) {
      sizes = ['One Size'];
    }
    
    // Try to find image URLs
    List<String> images = [];
    if (data['images'] is List) {
      images = List<String>.from(data['images'].map((img) => 
        img is String ? img : (img['url'] ?? img['src'] ?? '')
      ));
    } else if (data['image'] is String) {
      images = [data['image']];
    } else if (data['image_url'] is String) {
      images = [data['image_url']];
    } else if (data['image'] is Map && data['image']['url'] is String) {
      images = [data['image']['url']];
    }
    
    if (images.isEmpty) {
      images = ['https://via.placeholder.com/400?text=No+Image'];
    }
    
    // Try to find category
    String category = 'Uncategorized';
    if (data['category'] is String) {
      category = data['category'];
    } else if (data['category_name'] is String) {
      category = data['category_name'];
    } else if (data['department'] is String) {
      category = data['department'];
    }
    
    // Try to determine gender
    String gender = 'unisex';
    if (data['gender'] is String) {
      gender = data['gender'].toString().toLowerCase();
    } else {
      final searchSpace = [
        category.toLowerCase(), 
        name.toLowerCase(),
        data['department']?.toString().toLowerCase() ?? ''
      ].join(' ');
      
      if (searchSpace.contains('women') || searchSpace.contains('girl')) {
        gender = 'women';
      } else if (searchSpace.contains('men') || searchSpace.contains('boy')) {
        gender = 'men';
      }
    }
    
    // Try to find rating
    double rating = 0.0;
    if (data['rating'] is num) {
      rating = data['rating'].toDouble();
    } else if (data['average_rating'] is num) {
      rating = data['average_rating'].toDouble();
    } else if (data['rating'] is String) {
      rating = double.tryParse(data['rating']) ?? 0.0;
    }
    
    // Try to find review count
    int reviewCount = 0;
    if (data['review_count'] is num) {
      reviewCount = data['review_count'] as int;
    } else if (data['reviews_count'] is num) {
      reviewCount = data['reviews_count'] as int;
    } else if (data['number_of_reviews'] is num) {
      reviewCount = data['number_of_reviews'] as int;
    }
    
    // Try to determine stock status
    bool inStock = true;
    if (data['in_stock'] is bool) {
      inStock = data['in_stock'];
    } else if (data['is_in_stock'] is bool) {
      inStock = data['is_in_stock'];
    } else if (data['availability'] is String) {
      inStock = data['availability'].toString().toLowerCase().contains('stock');
    }
    
    // Gather additional information
    final additionalInfo = <String, dynamic>{};
    
    if (data['brand'] != null) {
      additionalInfo['brand'] = data['brand'];
    }
    
    if (data['is_on_sale'] is bool) {
      additionalInfo['isOnSale'] = data['is_on_sale'];
    } else if (data['on_sale'] is bool) {
      additionalInfo['isOnSale'] = data['on_sale'];
    }
    
    if (data['original_price'] is num) {
      additionalInfo['originalPrice'] = data['original_price'];
    } else if (data['regular_price'] is num) {
      additionalInfo['originalPrice'] = data['regular_price'];
    }
    
    if (data['discount_percentage'] is num) {
      additionalInfo['discountPercentage'] = data['discount_percentage'];
    }
    
    return Product(
      id: id,
      name: name,
      description: description,
      price: priceValue,
      currency: currency,
      colors: colors,
      sizes: sizes,
      images: images,
      category: category,
      retailer: retailer.name,
      externalUrl: retailer.generateProductUrl(id),
      gender: gender,
      rating: rating,
      reviewCount: reviewCount,
      inStock: inStock,
      additionalInfo: additionalInfo,
    );
  }
}

// Factory to create the appropriate adapter based on the retailer
class RetailerApiAdapterFactory {
  static RetailerApiAdapter create(Retailer retailer, {String? apiKey}) {
    switch (retailer.id) {
      case 'amazon':
        return AmazonApiAdapter(retailer, apiKey: apiKey);
      case 'flipkart':
        return FlipkartApiAdapter(retailer, apiKey: apiKey);
      case 'nordstrom':
        return NordstromApiAdapter(retailer, apiKey: apiKey);
      case 'macys':
        return MacysApiAdapter(retailer, apiKey: apiKey);
      case 'target':
        return TargetApiAdapter(retailer, apiKey: apiKey);
      case 'zara':
      case 'hm':
      case 'asos':
      case 'kohls':
      case 'anthropologie':
      case 'urbanoutfitters':
        // Use the generic adapter for these retailers until specific adapters are implemented
        return GenericRetailerAdapter(retailer, apiKey: apiKey);
      default:
        // For retailers without specific adapters, use the generic one
        return GenericRetailerAdapter(retailer, apiKey: apiKey);
    }
  }
}