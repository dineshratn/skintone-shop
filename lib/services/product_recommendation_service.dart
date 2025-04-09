import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/retailer.dart';
import '../models/skin_tone.dart';
import '../utils/color_utils.dart';
import 'retailer_service.dart';
import 'retailer_manager.dart';

class ProductRecommendationService {
  // The API URL for our ML recommendation engine
  static const String apiUrl = 'http://localhost:5000/api';
  
  // Service instances
  final RetailerService _retailerService = RetailerService();
  final RetailerManager _retailerManager = RetailerManager();
  
  // Initialize the ML recommendation engine with product data
  Future<bool> initializeMLEngine(List<Product> products) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/initialize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'products': products.map((p) => p.toJson()).toList(),
        }),
      );
      
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      print('Failed to initialize ML engine: $e');
      return false;
    }
  }
  
  // Get ML-based recommendations for a user
  Future<List<ProductCompatibility>> getMLRecommendations(
    List<Product> products,
    SkinToneInfo skinToneInfo,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'products': products.map((p) => p.toJson()).toList(),
          'userInfo': {
            'undertone': skinToneInfo.undertone,
            'depth': skinToneInfo.depth,
            'recommendedColors': skinToneInfo.recommendedColors,
            'notRecommendedColors': skinToneInfo.notRecommendedColors,
          },
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'success') {
        List<ProductCompatibility> recommendations = [];
        
        for (final item in data['recommendations']) {
          recommendations.add(ProductCompatibility(
            productId: item['productId'],
            compatibilityScore: item['compatibilityScore'],
            reason: item['reason'],
          ));
        }
        
        return recommendations;
      } else {
        // Fallback to local calculation if ML model fails
        print('ML recommendation failed: ${data['error']}');
        return calculateCompatibilities(products, skinToneInfo);
      }
    } catch (e) {
      // Fallback to local calculation on error
      print('ML recommendation error: $e');
      return calculateCompatibilities(products, skinToneInfo);
    }
  }
  
  // Get ML-based compatibility for a single product
  Future<ProductCompatibility> getMLCompatibility(
    Product product,
    SkinToneInfo skinToneInfo,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/compatibility'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product': product.toJson(),
          'userInfo': {
            'undertone': skinToneInfo.undertone,
            'depth': skinToneInfo.depth,
            'recommendedColors': skinToneInfo.recommendedColors,
            'notRecommendedColors': skinToneInfo.notRecommendedColors,
          },
        }),
      );
      
      final data = jsonDecode(response.body);
      
      return ProductCompatibility(
        productId: data['productId'],
        compatibilityScore: data['compatibilityScore'],
        reason: data['reason'],
      );
    } catch (e) {
      // Fallback to local calculation on error
      print('ML compatibility error: $e');
      return getProductCompatibility(product, skinToneInfo);
    }
  }
  
  // Calculate compatibility scores for all products (local fallback)
  List<ProductCompatibility> calculateCompatibilities(
    List<Product> products,
    SkinToneInfo skinToneInfo,
  ) {
    final List<ProductCompatibility> compatibilities = [];
    
    for (final product in products) {
      final compatibility = getProductCompatibility(product, skinToneInfo);
      compatibilities.add(compatibility);
    }
    
    return compatibilities;
  }
  
  // Calculate compatibility for a single product (local fallback)
  ProductCompatibility getProductCompatibility(
    Product product,
    SkinToneInfo skinToneInfo,
  ) {
    // Default for incomplete skin tone info
    if (!skinToneInfo.isComplete) {
      return ProductCompatibility(
        productId: product.id,
        compatibilityScore: 50, // Neutral score
        reason: 'Complete your skin tone profile for personalized recommendations.',
      );
    }
    
    // Calculate score based on product colors and skin tone
    int score = 50; // Default neutral score
    String reason = '';
    
    final recommendedColors = skinToneInfo.recommendedColors;
    final notRecommendedColors = skinToneInfo.notRecommendedColors;
    
    // Check if product has any compatible colors
    final List<String> compatibleColors = [];
    final List<String> incompatibleColors = [];
    
    for (final color in product.colors) {
      if (_isColorInList(color, recommendedColors)) {
        compatibleColors.add(color);
        score += 10; // Increase score for each compatible color
      }
      
      if (_isColorInList(color, notRecommendedColors)) {
        incompatibleColors.add(color);
        score -= 10; // Decrease score for each incompatible color
      }
    }
    
    // Adjust for other factors
    
    // Boost score for clothing categories that tend to be more impactful for skin tone
    if (product.category == 'Tops' || product.category == 'Dresses') {
      score += 5; // These items are close to the face, so color matters more
    }
    
    // Adjust score for lack of color variety
    if (product.colors.length == 1) {
      score -= 5; // Single color products have no alternatives
    }
    
    // Ensure score is within bounds
    if (score > 100) score = 100;
    if (score < 0) score = 0;
    
    // Generate explanation
    if (compatibleColors.isNotEmpty) {
      reason = 'This ${product.category.toLowerCase()} comes in ${_formatColorList(compatibleColors)}, '
          'which complement your ${skinToneInfo.undertone} ${skinToneInfo.depth} skin tone.';
    } else if (incompatibleColors.isNotEmpty) {
      reason = '${_formatColorList(incompatibleColors)} may not be the most flattering colors '
          'for your ${skinToneInfo.undertone} ${skinToneInfo.depth} skin tone.';
    } else {
      reason = 'This product has neutral compatibility with your skin tone.';
    }
    
    return ProductCompatibility(
      productId: product.id,
      compatibilityScore: score,
      reason: reason,
    );
  }
  
  // Helper to format list of colors for display
  String _formatColorList(List<String> colors) {
    if (colors.isEmpty) return '';
    if (colors.length == 1) return colors[0];
    if (colors.length == 2) return '${colors[0]} and ${colors[1]}';
    
    return colors.sublist(0, colors.length - 1).join(', ') + ', and ${colors.last}';
  }
  
  // Helper to check if a color is in a list (with fuzzy matching)
  bool _isColorInList(String productColor, List<String> colorList) {
    final normalizedProductColor = productColor.toLowerCase();
    
    for (final listedColor in colorList) {
      final normalizedListedColor = listedColor.toLowerCase();
      
      // Exact match
      if (normalizedProductColor == normalizedListedColor) {
        return true;
      }
      
      // Partial match for compound colors (e.g., "Navy Blue" contains "Navy")
      if (normalizedProductColor.contains(normalizedListedColor) || 
          normalizedListedColor.contains(normalizedProductColor)) {
        return true;
      }
      
      // Match color families
      if (ColorUtils.areColorsInSameFamily(normalizedProductColor, normalizedListedColor)) {
        return true;
      }
    }
    
    return false;
  }
  
  // ======== RETAILER-SPECIFIC METHODS ========
  
  // Initialize retailer services
  Future<void> initializeRetailerServices() async {
    await _retailerManager.initialize();
  }
  
  // Get products from active and configured retailers
  Future<List<Product>> getProductsFromActiveRetailers({
    String? query,
    String? category,
  }) async {
    await _retailerManager.initialize();
    
    final configuredRetailers = _retailerManager.getConfiguredRetailers();
    if (configuredRetailers.isEmpty) {
      // If no retailers are configured, use all active retailers
      return _retailerService.fetchProductsFromRetailers(
        query: query,
        category: category,
      );
    }
    
    // Use specific retailers that are configured
    final retailerIds = configuredRetailers.map((r) => r.id).toList();
    return _retailerService.fetchProductsFromRetailers(
      specificRetailerIds: retailerIds,
      query: query,
      category: category,
    );
  }
  
  // Get products from a specific retailer
  Future<List<Product>> getProductsFromRetailer(
    String retailerId, {
    String? query,
    String? category,
  }) async {
    await _retailerManager.initialize();
    
    return _retailerService.fetchProductsFromRetailers(
      specificRetailerIds: [retailerId],
      query: query,
      category: category,
    );
  }
  
  // Get top recommendations across all retailers for a user's skin tone
  Future<List<ProductWithCompatibility>> getTopRecommendationsForUser(
    SkinToneInfo skinToneInfo, {
    String? category,
    int limit = 10,
  }) async {
    // 1. Initialize retailer services
    await initializeRetailerServices();
    
    // 2. Get products from active retailers
    final products = await getProductsFromActiveRetailers(
      category: category,
    );
    
    // 3. Try to get ML-based recommendations
    List<ProductCompatibility> compatibilities;
    try {
      compatibilities = await getMLRecommendations(products, skinToneInfo);
    } catch (e) {
      // Fallback to local compatibilities if ML fails
      compatibilities = calculateCompatibilities(products, skinToneInfo);
    }
    
    // 4. Match products with their compatibilities
    final List<ProductWithCompatibility> productsWithCompatibility = [];
    for (final product in products) {
      final compatibility = compatibilities.firstWhere(
        (c) => c.productId == product.id,
        orElse: () => ProductCompatibility(
          productId: product.id, 
          compatibilityScore: 50,
          reason: 'No compatibility information available.'
        ),
      );
      
      productsWithCompatibility.add(ProductWithCompatibility(
        product: product,
        compatibilityScore: compatibility.compatibilityScore,
        reason: compatibility.reason,
      ));
    }
    
    // 5. Sort by compatibility score (highest first)
    productsWithCompatibility.sort((a, b) => 
      b.compatibilityScore.compareTo(a.compatibilityScore)
    );
    
    // 6. Return top N results, or all if less than the limit
    final int resultCount = limit > productsWithCompatibility.length 
        ? productsWithCompatibility.length 
        : limit;
    
    return productsWithCompatibility.take(resultCount).toList();
  }
  
  // Get available retailers
  Future<List<Retailer>> getAvailableRetailers() async {
    await _retailerManager.initialize();
    return _retailerManager.getAllRetailers();
  }
  
  // Get active retailers
  Future<List<Retailer>> getActiveRetailers() async {
    await _retailerManager.initialize();
    return _retailerManager.getActiveRetailers();
  }
  
  // Get configured retailers (with API keys if needed)
  Future<List<Retailer>> getConfiguredRetailers() async {
    await _retailerManager.initialize();
    return _retailerManager.getConfiguredRetailers();
  }
  
  // Check if a retailer is properly configured
  Future<bool> isRetailerConfigured(String retailerId) async {
    await _retailerManager.initialize();
    
    try {
      final retailer = _retailerManager.getAllRetailers().firstWhere(
        (r) => r.id == retailerId,
      );
      
      return _retailerManager.isRetailerConfigured(retailer);
    } catch (e) {
      // If retailer is not found
      return false;
    }
  }
}

// Class to combine a product with its compatibility score
class ProductWithCompatibility {
  final Product product;
  final int compatibilityScore;
  final String reason;
  
  ProductWithCompatibility({
    required this.product,
    required this.compatibilityScore,
    required this.reason,
  });
}
