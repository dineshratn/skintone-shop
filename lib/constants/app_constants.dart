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
  
  // Additional retailer sources
  static const String zaraSource = "Zara";
  static const String hmSource = "H&M";
  static const String asosSource = "ASOS";
  static const String nordstromSource = "Nordstrom";
  static const String macysSource = "Macy's";
  static const String kohlsSource = "Kohl's";
  static const String targetSource = "Target";
  static const String anthropologieSource = "Anthropologie";
  static const String urbanOutfittersSource = "Urban Outfitters";
  
  // Retailer Categories
  static const String generalRetailerCategory = "General Retailer";
  static const String fashionSpecialistCategory = "Fashion Specialist";
  static const String ecommercePlatformCategory = "E-commerce Platform";
  static const String departmentStoreCategory = "Department Store";
  static const String luxuryBrandCategory = "Luxury Brand";
  static const String fastFashionCategory = "Fast Fashion";
  static const String marketplaceCategory = "Marketplace";
  static const String outletCategory = "Outlet";
  static const String ethnicWearCategory = "Ethnic Wear";
  static const String sustainableCategory = "Sustainable";
  
  // Retailer API configuration
  static const Map<String, dynamic> amazonApiConfig = {
    'requiresApiKey': true,
    'endpoint': 'https://api.amazon.com/products',
    'country_codes': ['US', 'UK', 'CA', 'DE', 'FR', 'JP', 'IN'],
  };
  
  static const Map<String, dynamic> flipkartApiConfig = {
    'requiresApiKey': true,
    'endpoint': 'https://api.flipkart.com/products',
    'country_codes': ['IN'],
  };
  
  static const Map<String, dynamic> zaraApiConfig = {
    'requiresApiKey': false,
    'endpoint': 'https://www.zara.com/api/products',
    'country_codes': ['US', 'UK', 'ES', 'DE', 'FR', 'IT'],
  };
  
  static const Map<String, dynamic> hmApiConfig = {
    'requiresApiKey': false,
    'endpoint': 'https://api2.hm.com/v1/products',
    'country_codes': ['US', 'UK', 'DE', 'FR', 'SE'],
  };
  
  static const Map<String, dynamic> asosApiConfig = {
    'requiresApiKey': true,
    'endpoint': 'https://api.asos.com/products',
    'country_codes': ['US', 'UK', 'DE', 'FR', 'AU'],
  };
  
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
  
  // Product availability status
  static const String inStock = "In Stock";
  static const String outOfStock = "Out of Stock";
  static const String limitedStock = "Limited Stock";
  static const String preOrder = "Pre-order";
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Product API request limits
  static const int defaultProductLimit = 20;
  static const int maxProductsPerRequest = 50;
  
  // Retailer logo placeholder
  static const String defaultRetailerLogoUrl = 'https://via.placeholder.com/60';
}
