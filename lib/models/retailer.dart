class Retailer {
  final String id;
  final String name;
  final String baseUrl;
  final String logoUrl;
  final String searchUrlTemplate;
  final String productUrlTemplate;
  final bool isActive;
  final Map<String, dynamic> apiConfig;
  final RetailerCategory retailerCategory;
  
  const Retailer({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.logoUrl,
    required this.searchUrlTemplate,
    required this.productUrlTemplate,
    this.isActive = true,
    this.apiConfig = const {},
    required this.retailerCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'logoUrl': logoUrl,
      'searchUrlTemplate': searchUrlTemplate,
      'productUrlTemplate': productUrlTemplate,
      'isActive': isActive,
      'apiConfig': apiConfig,
      'retailerCategory': retailerCategory.toString(),
    };
  }

  factory Retailer.fromJson(Map<String, dynamic> json) {
    return Retailer(
      id: json['id'],
      name: json['name'],
      baseUrl: json['baseUrl'],
      logoUrl: json['logoUrl'],
      searchUrlTemplate: json['searchUrlTemplate'],
      productUrlTemplate: json['productUrlTemplate'],
      isActive: json['isActive'] ?? true,
      apiConfig: json['apiConfig'] ?? {},
      retailerCategory: RetailerCategoryExtension.fromString(json['retailerCategory']),
    );
  }

  // Generate a product URL for this retailer
  String generateProductUrl(String productId) {
    return productUrlTemplate.replaceAll('{productId}', productId);
  }

  // Generate a search URL for this retailer
  String generateSearchUrl(String query) {
    return searchUrlTemplate.replaceAll('{query}', Uri.encodeComponent(query));
  }
}

enum RetailerCategory {
  generalRetailer,
  fashionSpecialist,
  ecommercePlatform,
  departmentStore,
  luxuryBrand,
  fastFashion,
  marketplace,
  outlet,
  ethnicWear,
  sustainable
}

extension RetailerCategoryExtension on RetailerCategory {
  String get displayName {
    switch (this) {
      case RetailerCategory.generalRetailer:
        return 'General Retailer';
      case RetailerCategory.fashionSpecialist:
        return 'Fashion Specialist';
      case RetailerCategory.ecommercePlatform:
        return 'E-commerce Platform';
      case RetailerCategory.departmentStore:
        return 'Department Store';
      case RetailerCategory.luxuryBrand:
        return 'Luxury Brand';
      case RetailerCategory.fastFashion:
        return 'Fast Fashion';
      case RetailerCategory.marketplace:
        return 'Marketplace';
      case RetailerCategory.outlet:
        return 'Outlet';
      case RetailerCategory.ethnicWear:
        return 'Ethnic Wear';
      case RetailerCategory.sustainable:
        return 'Sustainable';
    }
  }

  static RetailerCategory fromString(String value) {
    switch (value) {
      case 'generalRetailer':
      case 'General Retailer':
        return RetailerCategory.generalRetailer;
      case 'fashionSpecialist':
      case 'Fashion Specialist':
        return RetailerCategory.fashionSpecialist;
      case 'ecommercePlatform':
      case 'E-commerce Platform':
        return RetailerCategory.ecommercePlatform;
      case 'departmentStore':
      case 'Department Store':
        return RetailerCategory.departmentStore;
      case 'luxuryBrand':
      case 'Luxury Brand':
        return RetailerCategory.luxuryBrand;
      case 'fastFashion':
      case 'Fast Fashion':
        return RetailerCategory.fastFashion;
      case 'marketplace':
      case 'Marketplace':
        return RetailerCategory.marketplace;
      case 'outlet':
      case 'Outlet':
        return RetailerCategory.outlet;
      case 'ethnicWear':
      case 'Ethnic Wear':
        return RetailerCategory.ethnicWear;
      case 'sustainable':
      case 'Sustainable':
        return RetailerCategory.sustainable;
      default:
        return RetailerCategory.generalRetailer;
    }
  }
}