class AppConstants {
  // App name
  static const String appName = "SkinTone Shop";
  
  // API endpoints
  static const String baseApiUrl = "https://api.example.com";
  static const String productsEndpoint = "/products";
  static const String categoriesEndpoint = "/categories";
  
  // Local storage keys
  static const String userProfileKey = "user_profile";
  static const String wishlistKey = "wishlist";
  
  // Onboarding constants
  static const int onboardingStepsCount = 3;
  
  // Retailer sources
  static const String amazonSource = "Amazon";
  static const String flipkartSource = "Flipkart";
  
  // Skin tone compatibility levels
  static const String highCompatibility = "Highly Compatible";
  static const String mediumCompatibility = "Good Match";
  static const String lowCompatibility = "Less Ideal";
  
  // Product categories
  static const List<String> productCategories = [
    "Tops",
    "Dresses",
    "Shirts",
    "Pants",
    "Skirts",
    "Outerwear",
    "Accessories"
  ];
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
