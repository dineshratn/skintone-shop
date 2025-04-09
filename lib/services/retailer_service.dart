import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/retailer.dart';
import '../models/product.dart';
import '../constants/app_constants.dart';

class RetailerService {
  static const String _retailersStorageKey = 'retailers';
  static const String _activeRetailersStorageKey = 'active_retailers';
  
  List<Retailer> _retailers = [];
  List<String> _activeRetailerIds = [];
  bool _isInitialized = false;
  
  // Singleton instance
  static final RetailerService _instance = RetailerService._internal();
  
  factory RetailerService() {
    return _instance;
  }
  
  RetailerService._internal();
  
  List<Retailer> get retailers => _retailers;
  List<Retailer> get activeRetailers => _retailers.where((r) => _activeRetailerIds.contains(r.id)).toList();
  
  // Initialize with default retailers and load saved settings
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadRetailers();
    
    // If no retailers were loaded, set up defaults
    if (_retailers.isEmpty) {
      _setupDefaultRetailers();
      await _saveRetailers();
    }
    
    await _loadActiveRetailers();
    
    // If no active retailers, make all retailers active by default
    if (_activeRetailerIds.isEmpty) {
      _activeRetailerIds = _retailers.map((r) => r.id).toList();
      await _saveActiveRetailers();
    }
    
    _isInitialized = true;
  }
  
  Future<void> _loadRetailers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final retailersJson = prefs.getString(_retailersStorageKey);
      
      if (retailersJson != null) {
        final List<dynamic> decodedList = jsonDecode(retailersJson);
        _retailers = decodedList.map((map) => Retailer.fromJson(map)).toList();
      }
    } catch (e) {
      print('Error loading retailers: $e');
      _retailers = [];
    }
  }
  
  Future<void> _saveRetailers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final retailersJson = jsonEncode(_retailers.map((r) => r.toJson()).toList());
      await prefs.setString(_retailersStorageKey, retailersJson);
    } catch (e) {
      print('Error saving retailers: $e');
    }
  }
  
  Future<void> _loadActiveRetailers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeRetailers = prefs.getStringList(_activeRetailersStorageKey);
      
      if (activeRetailers != null) {
        _activeRetailerIds = activeRetailers;
      }
    } catch (e) {
      print('Error loading active retailers: $e');
      _activeRetailerIds = [];
    }
  }
  
  Future<void> _saveActiveRetailers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_activeRetailersStorageKey, _activeRetailerIds);
    } catch (e) {
      print('Error saving active retailers: $e');
    }
  }
  
  void _setupDefaultRetailers() {
    _retailers = [
      // Amazon
      Retailer(
        id: 'amazon',
        name: AppConstants.amazonSource,
        baseUrl: 'https://www.amazon.com',
        logoUrl: 'https://logo.clearbit.com/amazon.com',
        searchUrlTemplate: 'https://www.amazon.com/s?k={query}',
        productUrlTemplate: 'https://www.amazon.com/dp/{productId}',
        retailerCategory: RetailerCategory.ecommercePlatform,
        apiConfig: AppConstants.amazonApiConfig,
      ),
      
      // Flipkart
      Retailer(
        id: 'flipkart',
        name: AppConstants.flipkartSource,
        baseUrl: 'https://www.flipkart.com',
        logoUrl: 'https://logo.clearbit.com/flipkart.com',
        searchUrlTemplate: 'https://www.flipkart.com/search?q={query}',
        productUrlTemplate: 'https://www.flipkart.com/product/{productId}',
        retailerCategory: RetailerCategory.ecommercePlatform,
        apiConfig: AppConstants.flipkartApiConfig,
      ),
      
      // Zara
      Retailer(
        id: 'zara',
        name: AppConstants.zaraSource,
        baseUrl: 'https://www.zara.com',
        logoUrl: 'https://logo.clearbit.com/zara.com',
        searchUrlTemplate: 'https://www.zara.com/search?searchTerm={query}',
        productUrlTemplate: 'https://www.zara.com/product/{productId}',
        retailerCategory: RetailerCategory.fastFashion,
        apiConfig: AppConstants.zaraApiConfig,
      ),
      
      // H&M
      Retailer(
        id: 'hm',
        name: AppConstants.hmSource,
        baseUrl: 'https://www2.hm.com',
        logoUrl: 'https://logo.clearbit.com/hm.com',
        searchUrlTemplate: 'https://www2.hm.com/en_us/search-results.html?q={query}',
        productUrlTemplate: 'https://www2.hm.com/en_us/productpage.{productId}.html',
        retailerCategory: RetailerCategory.fastFashion,
        apiConfig: AppConstants.hmApiConfig,
      ),
      
      // ASOS
      Retailer(
        id: 'asos',
        name: AppConstants.asosSource,
        baseUrl: 'https://www.asos.com',
        logoUrl: 'https://logo.clearbit.com/asos.com',
        searchUrlTemplate: 'https://www.asos.com/search/?q={query}',
        productUrlTemplate: 'https://www.asos.com/product/{productId}',
        retailerCategory: RetailerCategory.fashionSpecialist,
        apiConfig: AppConstants.asosApiConfig,
      ),
      
      // Nordstrom
      Retailer(
        id: 'nordstrom',
        name: AppConstants.nordstromSource,
        baseUrl: 'https://www.nordstrom.com',
        logoUrl: 'https://logo.clearbit.com/nordstrom.com',
        searchUrlTemplate: 'https://www.nordstrom.com/sr?keyword={query}',
        productUrlTemplate: 'https://www.nordstrom.com/s/{productId}',
        retailerCategory: RetailerCategory.departmentStore,
        apiConfig: {
          'requiresApiKey': true,
          'endpoint': 'https://api.nordstrom.com/products',
          'country_codes': ['US'],
        },
      ),
      
      // Macy's
      Retailer(
        id: 'macys',
        name: AppConstants.macysSource,
        baseUrl: 'https://www.macys.com',
        logoUrl: 'https://logo.clearbit.com/macys.com',
        searchUrlTemplate: 'https://www.macys.com/shop/search?keyword={query}',
        productUrlTemplate: 'https://www.macys.com/shop/product/{productId}',
        retailerCategory: RetailerCategory.departmentStore,
        apiConfig: {
          'requiresApiKey': true,
          'endpoint': 'https://api.macys.com/v4/catalog/search',
          'country_codes': ['US'],
        },
      ),
      
      // Kohl's
      Retailer(
        id: 'kohls',
        name: AppConstants.kohlsSource,
        baseUrl: 'https://www.kohls.com',
        logoUrl: 'https://logo.clearbit.com/kohls.com',
        searchUrlTemplate: 'https://www.kohls.com/search.jsp?search={query}',
        productUrlTemplate: 'https://www.kohls.com/product/prd-{productId}',
        retailerCategory: RetailerCategory.departmentStore,
        apiConfig: {
          'requiresApiKey': true,
          'endpoint': 'https://api.kohls.com/products',
          'country_codes': ['US'],
        },
      ),
      
      // Target
      Retailer(
        id: 'target',
        name: AppConstants.targetSource,
        baseUrl: 'https://www.target.com',
        logoUrl: 'https://logo.clearbit.com/target.com',
        searchUrlTemplate: 'https://www.target.com/s?searchTerm={query}',
        productUrlTemplate: 'https://www.target.com/p/-/{productId}',
        retailerCategory: RetailerCategory.generalRetailer,
        apiConfig: {
          'requiresApiKey': true,
          'endpoint': 'https://api.target.com/products/v3',
          'country_codes': ['US'],
        },
      ),
      
      // Anthropologie
      Retailer(
        id: 'anthropologie',
        name: AppConstants.anthropologieSource,
        baseUrl: 'https://www.anthropologie.com',
        logoUrl: 'https://logo.clearbit.com/anthropologie.com',
        searchUrlTemplate: 'https://www.anthropologie.com/search?q={query}',
        productUrlTemplate: 'https://www.anthropologie.com/shop/{productId}',
        retailerCategory: RetailerCategory.fashionSpecialist,
        apiConfig: {
          'requiresApiKey': true,
          'endpoint': 'https://api.anthropologie.com/products',
          'country_codes': ['US', 'UK'],
        },
      ),
      
      // Urban Outfitters
      Retailer(
        id: 'urbanoutfitters',
        name: AppConstants.urbanOutfittersSource,
        baseUrl: 'https://www.urbanoutfitters.com',
        logoUrl: 'https://logo.clearbit.com/urbanoutfitters.com',
        searchUrlTemplate: 'https://www.urbanoutfitters.com/search?q={query}',
        productUrlTemplate: 'https://www.urbanoutfitters.com/shop/{productId}',
        retailerCategory: RetailerCategory.fashionSpecialist,
        apiConfig: {
          'requiresApiKey': true,
          'endpoint': 'https://api.urbanoutfitters.com/products',
          'country_codes': ['US', 'UK'],
        },
      ),
    ];
  }
  
  // Add a new retailer
  Future<void> addRetailer(Retailer retailer) async {
    if (!_isInitialized) await initialize();
    
    // Check if retailer with same ID already exists
    if (_retailers.any((r) => r.id == retailer.id)) {
      throw Exception('Retailer with ID ${retailer.id} already exists');
    }
    
    _retailers.add(retailer);
    _activeRetailerIds.add(retailer.id);
    
    await _saveRetailers();
    await _saveActiveRetailers();
  }
  
  // Update an existing retailer
  Future<void> updateRetailer(Retailer retailer) async {
    if (!_isInitialized) await initialize();
    
    final index = _retailers.indexWhere((r) => r.id == retailer.id);
    if (index == -1) {
      throw Exception('Retailer with ID ${retailer.id} not found');
    }
    
    _retailers[index] = retailer;
    await _saveRetailers();
  }
  
  // Delete a retailer
  Future<void> deleteRetailer(String retailerId) async {
    if (!_isInitialized) await initialize();
    
    _retailers.removeWhere((r) => r.id == retailerId);
    _activeRetailerIds.remove(retailerId);
    
    await _saveRetailers();
    await _saveActiveRetailers();
  }
  
  // Toggle retailer active status
  Future<void> toggleRetailerActive(String retailerId, bool isActive) async {
    if (!_isInitialized) await initialize();
    
    if (isActive && !_activeRetailerIds.contains(retailerId)) {
      _activeRetailerIds.add(retailerId);
    } else if (!isActive) {
      _activeRetailerIds.remove(retailerId);
    }
    
    await _saveActiveRetailers();
  }
  
  // Get retailer by ID
  Retailer? getRetailerById(String id) {
    if (!_isInitialized) initialize();
    
    try {
      return _retailers.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Fetch products from active retailers (mock implementation)
  Future<List<Product>> fetchProductsFromRetailers({
    String? query,
    String? category,
    List<String>? specificRetailerIds,
  }) async {
    if (!_isInitialized) await initialize();
    
    // Determine which retailers to use
    List<Retailer> retailersToUse;
    if (specificRetailerIds != null && specificRetailerIds.isNotEmpty) {
      retailersToUse = _retailers.where((r) => specificRetailerIds.contains(r.id)).toList();
    } else {
      retailersToUse = activeRetailers;
    }
    
    if (retailersToUse.isEmpty) {
      throw Exception('No active retailers available');
    }
    
    // For now, we'll return mock data
    // In a real implementation, this would make API calls to each retailer
    
    // In a production app, you would:
    // 1. Make parallel API calls to each retailer's API
    // 2. Process and normalize the responses
    // 3. Combine the results into a unified product list
    
    final List<Product> allProducts = [];
    
    // Simulate a delay for fetching from multiple sources
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Placeholder for real API calls
    for (final retailer in retailersToUse) {
      try {
        // This is where you would make the real API call 
        // For now, generate mock products for this retailer
        final retailerProducts = _generateMockProductsForRetailer(
          retailer,
          query: query,
          category: category,
        );
        
        allProducts.addAll(retailerProducts);
      } catch (e) {
        print('Error fetching products from ${retailer.name}: $e');
        // Continue with other retailers even if one fails
      }
    }
    
    return allProducts;
  }
  
  // This is just a placeholder for real API integration
  List<Product> _generateMockProductsForRetailer(
    Retailer retailer, {
    String? query,
    String? category,
  }) {
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    final productCount = 5 + random; // Between 5-15 products per retailer
    
    final products = <Product>[];
    
    for (var i = 0; i < productCount; i++) {
      final id = '${retailer.id}_${DateTime.now().millisecondsSinceEpoch}_$i';
      
      // Categories based on retailer type
      String productCategory;
      if (category != null) {
        productCategory = category;
      } else {
        final categories = AppConstants.productCategories;
        productCategory = categories[i % categories.length];
      }
      
      // Generate product name
      String name;
      if (query != null) {
        name = '${query.toUpperCase()} ${productCategory}';
      } else {
        name = '${retailer.name} ${productCategory}';
      }
      
      // Colors based on retailer
      List<String> colors;
      switch (retailer.id) {
        case 'amazon':
          colors = ['Black', 'Gray', 'Navy', 'White', 'Brown'];
          break;
        case 'flipkart':
          colors = ['Red', 'Blue', 'Green', 'Yellow', 'Orange'];
          break;
        case 'zara':
          colors = ['Black', 'White', 'Beige', 'Gray', 'Navy'];
          break;
        case 'hm':
          colors = ['Black', 'White', 'Pink', 'Blue', 'Green'];
          break;
        case 'asos':
          colors = ['Black', 'White', 'Multi', 'Red', 'Blue'];
          break;
        case 'nordstrom':
          colors = ['Black', 'Cream', 'Brown', 'Navy', 'Burgundy'];
          break;
        case 'macys':
          colors = ['Black', 'Red', 'Blue', 'Tan', 'Gray'];
          break;
        case 'kohls':
          colors = ['Black', 'White', 'Navy', 'Red', 'Green'];
          break;
        case 'target':
          colors = ['Black', 'Red', 'White', 'Blue', 'Gray'];
          break;
        case 'anthropologie':
          colors = ['Cream', 'Sage', 'Mauve', 'Indigo', 'Bronze'];
          break;
        case 'urbanoutfitters':
          colors = ['Black', 'Purple', 'Blue', 'Olive', 'Orange'];
          break;
        default:
          colors = ['Black', 'White', 'Blue', 'Red', 'Green'];
      }
      
      // Create the product
      final product = Product(
        id: id,
        name: '$name ${i + 1}',
        description: 'A quality ${productCategory.toLowerCase()} from ${retailer.name}',
        price: (19.99 + (i * 10)).roundToDouble(),
        currency: 'USD',
        colors: [colors[i % colors.length]],
        sizes: ['S', 'M', 'L', 'XL'],
        images: [
          'https://via.placeholder.com/400/FFFFFF?text=${retailer.name}',
          'https://via.placeholder.com/400/000000?text=${productCategory}',
        ],
        category: productCategory,
        retailer: retailer.name,
        externalUrl: retailer.generateProductUrl(id),
        gender: i % 3 == 0 ? 'men' : (i % 3 == 1 ? 'women' : 'unisex'),
      );
      
      products.add(product);
    }
    
    // Apply filters
    if (query != null) {
      return products.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        p.description.toLowerCase().contains(query.toLowerCase()) ||
        p.category.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    if (category != null) {
      return products.where((p) => 
        p.category.toLowerCase() == category.toLowerCase()
      ).toList();
    }
    
    return products;
  }
}