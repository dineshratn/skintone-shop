import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/product_recommendation_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ProductRecommendationService _recommendationService = ProductRecommendationService();
  
  List<Product> _products = [];
  List<Product> _recommendedProducts = [];
  List<Product> _wishlistProducts = [];
  bool _isLoading = false;
  String _error = '';
  
  List<Product> get products => _products;
  List<Product> get recommendedProducts => _recommendedProducts;
  List<Product> get wishlistProducts => _wishlistProducts;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Fetch products from multiple sources
  Future<void> fetchProducts({String? category, String? query}) async {
    _setLoading(true);
    try {
      _products = await _apiService.fetchProducts(category: category, query: query);
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch products: $e');
    }
  }
  
  // Get product details by ID
  Future<Product?> getProductById(String id) async {
    _setLoading(true);
    try {
      final product = await _apiService.getProductById(id);
      _setLoading(false);
      return product;
    } catch (e) {
      _setError('Failed to get product details: $e');
      return null;
    }
  }
  
  // Generate product recommendations based on user's skin tone
  Future<void> generateRecommendations(SkinToneInfo skinToneInfo) async {
    _setLoading(true);
    try {
      if (!skinToneInfo.isComplete) {
        _setError('Skin tone information is incomplete');
        return;
      }
      
      // First, ensure we have products
      if (_products.isEmpty) {
        await fetchProducts();
      }
      
      // Calculate compatibility scores for all products
      final productCompatibilities = _recommendationService.calculateCompatibilities(
        _products,
        skinToneInfo,
      );
      
      // Sort products by compatibility score
      final sortedProducts = _products.where((product) {
        final compatibility = productCompatibilities.firstWhere(
          (c) => c.productId == product.id,
          orElse: () => ProductCompatibility(
            productId: product.id,
            compatibilityScore: 0,
            reason: 'No compatibility data',
          ),
        );
        
        // Only include products with medium or high compatibility
        return compatibility.compatibilityScore >= 50;
      }).toList();
      
      sortedProducts.sort((a, b) {
        final aCompatibility = productCompatibilities.firstWhere(
          (c) => c.productId == a.id,
          orElse: () => ProductCompatibility(
            productId: a.id,
            compatibilityScore: 0,
            reason: 'No compatibility data',
          ),
        );
        
        final bCompatibility = productCompatibilities.firstWhere(
          (c) => c.productId == b.id,
          orElse: () => ProductCompatibility(
            productId: b.id,
            compatibilityScore: 0,
            reason: 'No compatibility data',
          ),
        );
        
        return bCompatibility.compatibilityScore - aCompatibility.compatibilityScore;
      });
      
      _recommendedProducts = sortedProducts;
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to generate recommendations: $e');
    }
  }
  
  // Fetch products in user's wishlist
  Future<void> fetchWishlistProducts(List<String> wishlistIds) async {
    if (wishlistIds.isEmpty) {
      _wishlistProducts = [];
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    try {
      final List<Product> wishlistItems = [];
      for (final id in wishlistIds) {
        final product = await _apiService.getProductById(id);
        if (product != null) {
          wishlistItems.add(product);
        }
      }
      
      _wishlistProducts = wishlistItems;
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch wishlist products: $e');
    }
  }
  
  // Search products across multiple sources
  Future<void> searchProducts(String query) async {
    _setLoading(true);
    try {
      _products = await _apiService.fetchProducts(query: query);
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to search products: $e');
    }
  }
  
  // Get compatibility score for a specific product
  ProductCompatibility getProductCompatibility(
    Product product,
    SkinToneInfo skinToneInfo,
  ) {
    return _recommendationService.getProductCompatibility(product, skinToneInfo);
  }
  
  // Helper methods for loading and error states
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = '';
    }
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    print('ProductProvider Error: $errorMessage');
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
