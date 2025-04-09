import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/retailer.dart';
import 'retailer_service.dart';
import 'retailer_api_adapters.dart';

class RetailerManager {
  final RetailerService _retailerService = RetailerService();
  
  static const String _apiKeysStorageKey = 'retailer_api_keys';
  static const String _retailerSettingsKey = 'retailer_settings';
  
  Map<String, String> _apiKeys = {};
  Map<String, dynamic> _retailerSettings = {};
  
  // Singleton instance
  static final RetailerManager _instance = RetailerManager._internal();
  
  factory RetailerManager() {
    return _instance;
  }
  
  RetailerManager._internal();
  
  Future<void> initialize() async {
    await _retailerService.initialize();
    await _loadApiKeys();
    await _loadRetailerSettings();
  }
  
  // API Key Management
  
  Future<void> _loadApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? apiKeysJson = prefs.getString(_apiKeysStorageKey);
      if (apiKeysJson != null) {
        _apiKeys = Map<String, String>.from(jsonDecode(apiKeysJson));
      }
    } catch (e) {
      print('Error loading API keys: $e');
      _apiKeys = {};
    }
  }
  
  Future<void> _saveApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeysStorageKey, jsonEncode(_apiKeys));
    } catch (e) {
      print('Error saving API keys: $e');
    }
  }
  
  Future<String?> getApiKey(String retailerId) async {
    return _apiKeys[retailerId];
  }
  
  Future<void> setApiKey(String retailerId, String apiKey) async {
    _apiKeys[retailerId] = apiKey;
    await _saveApiKeys();
  }
  
  Future<void> removeApiKey(String retailerId) async {
    _apiKeys.remove(retailerId);
    await _saveApiKeys();
  }
  
  // Retailer Settings Management
  
  Future<void> _loadRetailerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_retailerSettingsKey);
      if (settingsJson != null) {
        _retailerSettings = jsonDecode(settingsJson);
      }
    } catch (e) {
      print('Error loading retailer settings: $e');
      _retailerSettings = {};
    }
  }
  
  Future<void> _saveRetailerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_retailerSettingsKey, jsonEncode(_retailerSettings));
    } catch (e) {
      print('Error saving retailer settings: $e');
    }
  }
  
  // Get settings for a specific retailer
  dynamic getRetailerSetting(String retailerId, String key) {
    final retailerSettings = _retailerSettings[retailerId] ?? {};
    return retailerSettings[key];
  }
  
  // Set a setting for a specific retailer
  Future<void> setRetailerSetting(String retailerId, String key, dynamic value) async {
    if (_retailerSettings[retailerId] == null) {
      _retailerSettings[retailerId] = {};
    }
    
    _retailerSettings[retailerId][key] = value;
    await _saveRetailerSettings();
  }
  
  // Check if retailer is configured correctly (has necessary API keys if required)
  bool isRetailerConfigured(Retailer retailer) {
    final requiresApiKey = retailer.apiConfig['requiresApiKey'] == true;
    if (requiresApiKey) {
      return _apiKeys.containsKey(retailer.id) && _apiKeys[retailer.id]!.isNotEmpty;
    }
    return true;
  }
  
  // Get a list of all retailers
  List<Retailer> getAllRetailers() {
    return _retailerService.retailers;
  }
  
  // Get active retailers
  List<Retailer> getActiveRetailers() {
    return _retailerService.activeRetailers;
  }
  
  // Get configured retailers (active and with proper API keys if needed)
  List<Retailer> getConfiguredRetailers() {
    return _retailerService.activeRetailers
        .where((retailer) => isRetailerConfigured(retailer))
        .toList();
  }
  
  // Add a new retailer
  Future<void> addRetailer(Retailer retailer, {String? apiKey}) async {
    await _retailerService.addRetailer(retailer);
    
    if (apiKey != null) {
      await setApiKey(retailer.id, apiKey);
    }
  }
  
  // Update a retailer
  Future<void> updateRetailer(Retailer retailer, {String? apiKey}) async {
    await _retailerService.updateRetailer(retailer);
    
    if (apiKey != null) {
      await setApiKey(retailer.id, apiKey);
    }
  }
  
  // Delete a retailer
  Future<void> deleteRetailer(String retailerId) async {
    await _retailerService.deleteRetailer(retailerId);
    await removeApiKey(retailerId);
    
    // Also clean up settings
    if (_retailerSettings.containsKey(retailerId)) {
      _retailerSettings.remove(retailerId);
      await _saveRetailerSettings();
    }
  }
  
  // Toggle retailer active status
  Future<void> toggleRetailerActive(String retailerId, bool isActive) async {
    await _retailerService.toggleRetailerActive(retailerId, isActive);
  }
  
  // Get an appropriate API adapter for the retailer
  Future<RetailerApiAdapter?> getApiAdapter(String retailerId) async {
    final retailer = _retailerService.getRetailerById(retailerId);
    if (retailer == null) return null;
    
    final apiKey = await getApiKey(retailerId);
    
    try {
      return RetailerApiAdapterFactory.create(retailer, apiKey: apiKey);
    } catch (e) {
      print('Could not create API adapter for ${retailer.name}: $e');
      return null;
    }
  }
}