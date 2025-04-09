class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> colors;
  final List<String> sizes;
  final List<String> images;
  final String category;
  final String retailer;
  final String externalUrl;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final String gender; // 'men', 'women', 'unisex'
  final Map<String, dynamic> additionalInfo;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.colors,
    required this.sizes,
    required this.images,
    required this.category,
    required this.retailer,
    required this.externalUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    required this.gender,
    this.additionalInfo = const {},
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    List<String>? colors,
    List<String>? sizes,
    List<String>? images,
    String? category,
    String? retailer,
    String? externalUrl,
    double? rating,
    int? reviewCount,
    bool? inStock,
    String? gender,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      images: images ?? this.images,
      category: category ?? this.category,
      retailer: retailer ?? this.retailer,
      externalUrl: externalUrl ?? this.externalUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      gender: gender ?? this.gender,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'colors': colors,
      'sizes': sizes,
      'images': images,
      'category': category,
      'retailer': retailer,
      'externalUrl': externalUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'gender': gender,
      'additionalInfo': additionalInfo,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      colors: List<String>.from(json['colors']),
      sizes: List<String>.from(json['sizes']),
      images: List<String>.from(json['images']),
      category: json['category'],
      retailer: json['retailer'],
      externalUrl: json['externalUrl'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      inStock: json['inStock'] ?? true,
      gender: json['gender'],
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }

  String get formattedPrice {
    String symbol = '\$';
    if (currency == 'EUR') symbol = '€';
    else if (currency == 'GBP') symbol = '£';
    else if (currency == 'INR') symbol = '₹';
    
    return '$symbol${price.toStringAsFixed(2)}';
  }
}

class ProductCompatibility {
  final String productId;
  final int compatibilityScore; // 0-100
  final String reason;
  
  const ProductCompatibility({
    required this.productId,
    required this.compatibilityScore,
    required this.reason,
  });
  
  String get compatibilityLevel {
    if (compatibilityScore >= 80) {
      return 'High';
    } else if (compatibilityScore >= 50) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'compatibilityScore': compatibilityScore,
      'reason': reason,
    };
  }
  
  factory ProductCompatibility.fromJson(Map<String, dynamic> json) {
    return ProductCompatibility(
      productId: json['productId'],
      compatibilityScore: json['compatibilityScore'],
      reason: json['reason'],
    );
  }
}
