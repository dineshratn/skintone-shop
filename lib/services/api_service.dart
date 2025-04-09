import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/retailer.dart';
import '../constants/app_constants.dart';
import 'retailer_manager.dart';
import 'retailer_service.dart';

class ApiService {
  final RetailerManager _retailerManager = RetailerManager();
  final RetailerService _retailerService = RetailerService();
  
  // Flag to track initialization status
  bool _isInitialized = false;
  
  // Initialize API service
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _retailerManager.initialize();
      _isInitialized = true;
    }
  }
  
  // Fetch products with optional category or search query filter
  Future<List<Product>> fetchProducts({String? category, String? query}) async {
    await _ensureInitialized();
    
    try {
      // Get active and configured retailers
      final configuredRetailers = _retailerManager.getConfiguredRetailers();
      
      if (configuredRetailers.isEmpty) {
        // Fallback to mock data if no retailers are configured
        return await _retailerService.fetchProductsFromRetailers(
          category: category,
          query: query,
        );
      }
      
      // Determine retailer IDs to use
      final retailerIds = configuredRetailers.map((r) => r.id).toList();
      
      // Fetch products from the retailers
      return await _retailerService.fetchProductsFromRetailers(
        specificRetailerIds: retailerIds,
        category: category,
        query: query,
      );
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  // Get a single product by ID
  Future<Product?> getProductById(String id) async {
    await _ensureInitialized();
    
    try {
      // Extract retailer ID from product ID if available
      // Format expected: retailer_id_timestamp_index
      final parts = id.split('_');
      if (parts.length >= 1) {
        final retailerId = parts[0];
        
        // Try to get the retailer adapter for this retailer
        final adapter = await _retailerManager.getApiAdapter(retailerId);
        
        if (adapter != null) {
          // Use the adapter to get the product
          return await adapter.getProductDetails(id);
        }
      }
      
      // Fallback to searching in all available products
      final allProducts = await fetchProducts();
      return allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }
  
  // Fetch products by retailer
  Future<List<Product>> fetchProductsByRetailer(
    String retailerId, {
    String? category,
    String? query,
  }) async {
    await _ensureInitialized();
    
    try {
      return await _retailerService.fetchProductsFromRetailers(
        specificRetailerIds: [retailerId],
        category: category,
        query: query,
      );
    } catch (e) {
      throw Exception('Failed to fetch products from $retailerId: $e');
    }
  }
  
  // Get retailers for the UI
  Future<List<Retailer>> getAvailableRetailers() async {
    await _ensureInitialized();
    return _retailerManager.getAllRetailers();
  }
  
  // Get active retailers for the UI
  Future<List<Retailer>> getActiveRetailers() async {
    await _ensureInitialized();
    return _retailerManager.getActiveRetailers();
  }
  
  // Fetch products from multiple specific retailers
  Future<List<Product>> fetchProductsFromMultipleRetailers({
    required List<String> retailerIds,
    String? category,
    String? query,
  }) async {
    await _ensureInitialized();
    
    try {
      return await _retailerService.fetchProductsFromRetailers(
        specificRetailerIds: retailerIds,
        category: category,
        query: query,
      );
    } catch (e) {
      throw Exception('Failed to fetch products from selected retailers: $e');
    }
  }
  
  // Add a new retailer with API key
  Future<void> addRetailer(Retailer retailer, {String? apiKey}) async {
    await _ensureInitialized();
    await _retailerManager.addRetailer(retailer, apiKey: apiKey);
  }
  
  // Update an existing retailer
  Future<void> updateRetailer(Retailer retailer, {String? apiKey}) async {
    await _ensureInitialized();
    await _retailerManager.updateRetailer(retailer, apiKey: apiKey);
  }
  
  // Remove a retailer
  Future<void> removeRetailer(String retailerId) async {
    await _ensureInitialized();
    await _retailerManager.deleteRetailer(retailerId);
  }
  
  // Toggle a retailer's active status
  Future<void> toggleRetailerActive(String retailerId, bool isActive) async {
    await _ensureInitialized();
    await _retailerManager.toggleRetailerActive(retailerId, isActive);
  }
  
  // Set an API key for a retailer
  Future<void> setRetailerApiKey(String retailerId, String apiKey) async {
    await _ensureInitialized();
    await _retailerManager.setApiKey(retailerId, apiKey);
  }
}
