import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/skin_tone.dart';
import '../constants/app_constants.dart';

class UserProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile.empty();
  bool _isLoading = false;
  String _error = '';
  bool _isOnboardingComplete = false;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get hasCompletedSkinToneSelection => _userProfile.skinToneInfo.isComplete;

  // Initialize user from local storage
  Future<void> initUser() async {
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if onboarding is complete
      final isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;
      
      // Check if user profile exists
      final userProfileJson = prefs.getString(AppConstants.userProfileKey);
      UserProfile userProfile = UserProfile.empty();
      if (userProfileJson != null) {
        userProfile = UserProfile.fromJson(json.decode(userProfileJson));
      }
      
      // Update state without calling notifyListeners during init
      _isOnboardingComplete = isOnboardingComplete;
      _userProfile = userProfile;
      _isLoading = false;
      
      // Now notify listeners after everything is updated
      // This avoids setState during build issues
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _error = 'Failed to initialize user: $e';
      _isLoading = false;
      print('UserProvider Error: $_error');
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Set onboarding as complete
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOnboardingComplete', true);
      _isOnboardingComplete = true;
      // Use microtask to avoid setState during build issues
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _setError('Failed to save onboarding status: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    try {
      _userProfile = updatedProfile;
      await _saveUserProfile();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update user profile: $e');
    }
  }

  // Update just the skin tone info
  Future<void> updateSkinToneInfo(SkinToneInfo skinToneInfo) async {
    _setLoading(true);
    try {
      _userProfile = _userProfile.copyWith(skinToneInfo: skinToneInfo);
      await _saveUserProfile();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update skin tone info: $e');
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    if (_userProfile.wishlistIds.contains(productId)) {
      return;
    }
    
    _setLoading(true);
    try {
      final updatedWishlist = List<String>.from(_userProfile.wishlistIds)..add(productId);
      _userProfile = _userProfile.copyWith(wishlistIds: updatedWishlist);
      await _saveUserProfile();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to add to wishlist: $e');
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _setLoading(true);
    try {
      final updatedWishlist = List<String>.from(_userProfile.wishlistIds)..remove(productId);
      _userProfile = _userProfile.copyWith(wishlistIds: updatedWishlist);
      await _saveUserProfile();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to remove from wishlist: $e');
    }
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _userProfile.wishlistIds.contains(productId);
  }

  // Create a new user
  Future<void> createUser(String name, String email) async {
    _setLoading(true);
    try {
      // In a real app, you would make an API call to create a user
      // For the MVP, we'll just create a local user
      final newUser = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        skinToneInfo: SkinToneInfo.empty(),
      );
      
      _userProfile = newUser;
      await _saveUserProfile();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to create user: $e');
    }
  }

  // Sign out user
  Future<void> signOut() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userProfileKey);
      await prefs.remove('isOnboardingComplete');
      _userProfile = UserProfile.empty();
      _isOnboardingComplete = false;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out: $e');
    }
  }

  // Helper method to save user profile to SharedPreferences
  Future<void> _saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userProfileKey,
        json.encode(_userProfile.toJson()),
      );
      // Use microtask to avoid setState during build issues
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _error = 'Failed to save user profile: $e';
      _isLoading = false;
      print('UserProvider Error: $_error');
      Future.microtask(() => notifyListeners());
    }
  }

  // Helper methods for loading and error states
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = '';
    }
    // Use microtask to avoid setState during build issues
    Future.microtask(() => notifyListeners());
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    print('UserProvider Error: $errorMessage');
    // Use microtask to avoid setState during build issues
    Future.microtask(() => notifyListeners());
  }

  void clearError() {
    _error = '';
    // Use microtask to avoid setState during build issues
    Future.microtask(() => notifyListeners());
  }
}
