import 'dart:convert';
import 'dart:math'; // For demo data only

import '../models/product.dart';
import '../constants/app_constants.dart';

class ApiService {
  // In a real app, these would be actual API calls to backend services
  // For the MVP, we're using in-memory data
  
  // Fetch products with optional category or search query filter
  Future<List<Product>> fetchProducts({String? category, String? query}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Generate mock product data
      final List<Product> allProducts = _generateProducts();
      
      // Apply filters if provided
      if (category != null && category.isNotEmpty) {
        return allProducts.where((product) => 
          product.category.toLowerCase() == category.toLowerCase()
        ).toList();
      }
      
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        return allProducts.where((product) => 
          product.name.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery) ||
          product.category.toLowerCase().contains(lowercaseQuery) ||
          product.colors.any((color) => color.toLowerCase().contains(lowercaseQuery))
        ).toList();
      }
      
      return allProducts;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  // Get a single product by ID
  Future<Product?> getProductById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final List<Product> allProducts = _generateProducts();
      return allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }
  
  // Implementation detail: Generate product dataset for the MVP
  // In a real application, this would be replaced with actual API calls
  List<Product> _generateProducts() {
    final List<String> retailerSources = [
      AppConstants.amazonSource,
      AppConstants.flipkartSource,
      'Zara',
      'H&M',
      'ASOS',
    ];
    
    final List<Map<String, dynamic>> productTemplates = [
      {
        'id': '1',
        'name': 'Classic Cotton T-shirt',
        'description': 'A comfortable cotton t-shirt for everyday wear. Perfect for casual outings and relaxed settings.',
        'price': 19.99,
        'currency': 'USD',
        'colors': ['White', 'Black', 'Navy', 'Red', 'Olive Green'],
        'sizes': ['S', 'M', 'L', 'XL'],
        'category': 'Tops',
        'gender': 'unisex',
      },
      {
        'id': '2',
        'name': 'Summer Floral Dress',
        'description': 'A beautiful floral print dress perfect for summer days. Light and airy fabric keeps you cool.',
        'price': 49.99,
        'currency': 'USD',
        'colors': ['Blue Floral', 'Pink Floral', 'Yellow Floral'],
        'sizes': ['XS', 'S', 'M', 'L'],
        'category': 'Dresses',
        'gender': 'women',
      },
      {
        'id': '3',
        'name': 'Slim Fit Oxford Shirt',
        'description': 'A classic Oxford shirt with a modern slim fit. Versatile for both casual and formal occasions.',
        'price': 35.99,
        'currency': 'USD',
        'colors': ['White', 'Light Blue', 'Pink', 'Gray', 'Black'],
        'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
        'category': 'Shirts',
        'gender': 'men',
      },
      {
        'id': '4',
        'name': 'Stretch Skinny Jeans',
        'description': 'Comfortable stretch skinny jeans with a flattering fit. Modern design with classic appeal.',
        'price': 45.99,
        'currency': 'USD',
        'colors': ['Dark Blue', 'Black', 'Gray', 'Light Blue'],
        'sizes': ['26', '28', '30', '32', '34'],
        'category': 'Pants',
        'gender': 'women',
      },
      {
        'id': '5',
        'name': 'Pleated A-Line Skirt',
        'description': 'An elegant pleated A-line skirt that transitions easily from office to evening.',
        'price': 39.99,
        'currency': 'USD',
        'colors': ['Black', 'Navy', 'Beige', 'Burgundy'],
        'sizes': ['XS', 'S', 'M', 'L'],
        'category': 'Skirts',
        'gender': 'women',
      },
      {
        'id': '6',
        'name': 'Lightweight Puffer Jacket',
        'description': 'A lightweight, packable puffer jacket providing warmth without bulk. Water-resistant exterior.',
        'price': 79.99,
        'currency': 'USD',
        'colors': ['Navy', 'Olive', 'Black', 'Red', 'Copper'],
        'sizes': ['S', 'M', 'L', 'XL'],
        'category': 'Outerwear',
        'gender': 'unisex',
      },
      {
        'id': '7',
        'name': 'Knit Beanie Hat',
        'description': 'Soft knit beanie hat to keep you warm during colder days. Stylish and comfortable fit.',
        'price': 15.99,
        'currency': 'USD',
        'colors': ['Gray', 'Black', 'Navy', 'Burgundy', 'Olive Green'],
        'sizes': ['One Size'],
        'category': 'Accessories',
        'gender': 'unisex',
      },
      {
        'id': '8',
        'name': 'Chino Pants',
        'description': 'Classic chino pants with a straight fit. Versatile style that works for casual or semi-formal occasions.',
        'price': 42.99,
        'currency': 'USD',
        'colors': ['Khaki', 'Navy', 'Olive', 'Gray', 'Black'],
        'sizes': ['28', '30', '32', '34', '36', '38'],
        'category': 'Pants',
        'gender': 'men',
      },
      {
        'id': '9',
        'name': 'V-Neck Sweater',
        'description': 'Soft, lightweight V-neck sweater perfect for layering. Classic style with a comfortable fit.',
        'price': 34.99,
        'currency': 'USD',
        'colors': ['Navy', 'Gray', 'Black', 'Burgundy', 'Forest Green'],
        'sizes': ['S', 'M', 'L', 'XL'],
        'category': 'Tops',
        'gender': 'unisex',
      },
      {
        'id': '10',
        'name': 'Silk Scarf',
        'description': 'Elegant silk scarf with a beautiful print. Adds a touch of sophistication to any outfit.',
        'price': 29.99,
        'currency': 'USD',
        'colors': ['Blue Pattern', 'Red Pattern', 'Floral', 'Geometric'],
        'sizes': ['One Size'],
        'category': 'Accessories',
        'gender': 'women',
      },
      {
        'id': '11',
        'name': 'Flowy Maxi Dress',
        'description': 'Beautiful flowy maxi dress perfect for summer days or beach vacations. Light and comfortable fabric.',
        'price': 59.99,
        'currency': 'USD',
        'colors': ['White', 'Black', 'Navy', 'Coral', 'Sage Green'],
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'category': 'Dresses',
        'gender': 'women',
      },
      {
        'id': '12',
        'name': 'Button-Up Flannel Shirt',
        'description': 'Cozy flannel shirt with classic plaid pattern. Soft brushed fabric for warmth and comfort.',
        'price': 32.99,
        'currency': 'USD',
        'colors': ['Red Plaid', 'Blue Plaid', 'Green Plaid', 'Gray Plaid'],
        'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
        'category': 'Shirts',
        'gender': 'unisex',
      },
      {
        'id': '13',
        'name': 'Leather Belt',
        'description': 'Classic leather belt with a simple buckle. Versatile accessory for any outfit.',
        'price': 25.99,
        'currency': 'USD',
        'colors': ['Black', 'Brown', 'Tan'],
        'sizes': ['S', 'M', 'L', 'XL'],
        'category': 'Accessories',
        'gender': 'unisex',
      },
      {
        'id': '14',
        'name': 'Cargo Shorts',
        'description': 'Durable cargo shorts with multiple pockets. Perfect for outdoor activities and casual wear.',
        'price': 38.99,
        'currency': 'USD',
        'colors': ['Khaki', 'Olive', 'Gray', 'Black', 'Navy'],
        'sizes': ['28', '30', '32', '34', '36', '38'],
        'category': 'Pants',
        'gender': 'men',
      },
      {
        'id': '15',
        'name': 'Wrap Midi Skirt',
        'description': 'Elegant wrap midi skirt with a flattering silhouette. Perfect for both work and casual settings.',
        'price': 44.99,
        'currency': 'USD',
        'colors': ['Black', 'Navy', 'Burgundy', 'Olive Green'],
        'sizes': ['XS', 'S', 'M', 'L'],
        'category': 'Skirts',
        'gender': 'women',
      },
      {
        'id': '16',
        'name': 'Wool Peacoat',
        'description': 'Classic wool peacoat for cold weather. Timeless style with warm insulation.',
        'price': 129.99,
        'currency': 'USD',
        'colors': ['Black', 'Navy', 'Camel', 'Gray'],
        'sizes': ['S', 'M', 'L', 'XL'],
        'category': 'Outerwear',
        'gender': 'unisex',
      },
      {
        'id': '17',
        'name': 'Graphic Print T-shirt',
        'description': 'Cool graphic print t-shirt made from soft cotton. Express your style with unique designs.',
        'price': 24.99,
        'currency': 'USD',
        'colors': ['White', 'Black', 'Gray', 'Navy'],
        'sizes': ['S', 'M', 'L', 'XL'],
        'category': 'Tops',
        'gender': 'unisex',
      },
      {
        'id': '18',
        'name': 'Satin Blouse',
        'description': 'Elegant satin blouse with a smooth finish. Perfect for both professional and evening settings.',
        'price': 47.99,
        'currency': 'USD',
        'colors': ['White', 'Black', 'Navy', 'Burgundy', 'Emerald'],
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'category': 'Tops',
        'gender': 'women',
      },
      {
        'id': '19',
        'name': 'Straight Leg Jeans',
        'description': 'Classic straight leg jeans with a comfortable fit. Versatile denim for everyday wear.',
        'price': 49.99,
        'currency': 'USD',
        'colors': ['Dark Blue', 'Medium Blue', 'Light Blue', 'Black'],
        'sizes': ['28', '30', '32', '34', '36', '38'],
        'category': 'Pants',
        'gender': 'men',
      },
      {
        'id': '20',
        'name': 'Winter Gloves',
        'description': 'Warm winter gloves with touch screen capability. Keep your hands warm while using your devices.',
        'price': 19.99,
        'currency': 'USD',
        'colors': ['Black', 'Gray', 'Navy'],
        'sizes': ['S/M', 'L/XL'],
        'category': 'Accessories',
        'gender': 'unisex',
      },
    ];
    
    // Create product list with unique combinations of data
    final List<Product> products = [];
    final random = Random();
    
    for (final template in productTemplates) {
      // Choose a random retailer
      final retailer = retailerSources[random.nextInt(retailerSources.length)];
      
      // Generate random images (in real app, these would be actual product images)
      final List<String> images = [];
      for (int i = 0; i < 3; i++) {
        images.add('https://example.com/products/${template['id']}_$i.jpg');
      }
      
      // Create a product with the template data
      final product = Product(
        id: template['id'],
        name: template['name'],
        description: template['description'],
        price: template['price'],
        currency: template['currency'],
        colors: List<String>.from(template['colors']),
        sizes: List<String>.from(template['sizes']),
        images: images,
        category: template['category'],
        retailer: retailer,
        externalUrl: 'https://www.${retailer.toLowerCase()}.com/product/${template['id']}',
        rating: 3.0 + random.nextDouble() * 2.0, // Random rating between 3.0 and 5.0
        reviewCount: random.nextInt(500) + 10, // Random number of reviews
        inStock: random.nextBool() || random.nextBool(), // More likely to be in stock
        gender: template['gender'],
        additionalInfo: {},
      );
      
      products.add(product);
    }
    
    return products;
  }
}
