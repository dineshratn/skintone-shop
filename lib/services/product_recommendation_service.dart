import '../models/product.dart';
import '../models/user_profile.dart';
import '../utils/color_utils.dart';

class ProductRecommendationService {
  // Calculate compatibility scores for all products
  List<ProductCompatibility> calculateCompatibilities(
    List<Product> products,
    SkinToneInfo skinToneInfo,
  ) {
    final List<ProductCompatibility> compatibilities = [];
    
    for (final product in products) {
      final compatibility = getProductCompatibility(product, skinToneInfo);
      compatibilities.add(compatibility);
    }
    
    return compatibilities;
  }
  
  // Calculate compatibility for a single product
  ProductCompatibility getProductCompatibility(
    Product product,
    SkinToneInfo skinToneInfo,
  ) {
    // Default for incomplete skin tone info
    if (!skinToneInfo.isComplete) {
      return ProductCompatibility(
        productId: product.id,
        compatibilityScore: 50, // Neutral score
        reason: 'Complete your skin tone profile for personalized recommendations.',
      );
    }
    
    // Calculate score based on product colors and skin tone
    int score = 50; // Default neutral score
    String reason = '';
    
    final recommendedColors = skinToneInfo.recommendedColors;
    final notRecommendedColors = skinToneInfo.notRecommendedColors;
    
    // Check if product has any compatible colors
    final List<String> compatibleColors = [];
    final List<String> incompatibleColors = [];
    
    for (final color in product.colors) {
      if (_isColorInList(color, recommendedColors)) {
        compatibleColors.add(color);
        score += 10; // Increase score for each compatible color
      }
      
      if (_isColorInList(color, notRecommendedColors)) {
        incompatibleColors.add(color);
        score -= 10; // Decrease score for each incompatible color
      }
    }
    
    // Adjust for other factors
    
    // Boost score for clothing categories that tend to be more impactful for skin tone
    if (product.category == 'Tops' || product.category == 'Dresses') {
      score += 5; // These items are close to the face, so color matters more
    }
    
    // Adjust score for lack of color variety
    if (product.colors.length == 1) {
      score -= 5; // Single color products have no alternatives
    }
    
    // Ensure score is within bounds
    if (score > 100) score = 100;
    if (score < 0) score = 0;
    
    // Generate explanation
    if (compatibleColors.isNotEmpty) {
      reason = 'This ${product.category.toLowerCase()} comes in ${_formatColorList(compatibleColors)}, '
          'which complement your ${skinToneInfo.undertone} ${skinToneInfo.depth} skin tone.';
    } else if (incompatibleColors.isNotEmpty) {
      reason = '${_formatColorList(incompatibleColors)} may not be the most flattering colors '
          'for your ${skinToneInfo.undertone} ${skinToneInfo.depth} skin tone.';
    } else {
      reason = 'This product has neutral compatibility with your skin tone.';
    }
    
    return ProductCompatibility(
      productId: product.id,
      compatibilityScore: score,
      reason: reason,
    );
  }
  
  // Helper to format list of colors for display
  String _formatColorList(List<String> colors) {
    if (colors.isEmpty) return '';
    if (colors.length == 1) return colors[0];
    if (colors.length == 2) return '${colors[0]} and ${colors[1]}';
    
    return colors.sublist(0, colors.length - 1).join(', ') + ', and ${colors.last}';
  }
  
  // Helper to check if a color is in a list (with fuzzy matching)
  bool _isColorInList(String productColor, List<String> colorList) {
    final normalizedProductColor = productColor.toLowerCase();
    
    for (final listedColor in colorList) {
      final normalizedListedColor = listedColor.toLowerCase();
      
      // Exact match
      if (normalizedProductColor == normalizedListedColor) {
        return true;
      }
      
      // Partial match for compound colors (e.g., "Navy Blue" contains "Navy")
      if (normalizedProductColor.contains(normalizedListedColor) || 
          normalizedListedColor.contains(normalizedProductColor)) {
        return true;
      }
      
      // Match color families
      if (ColorUtils.areColorsInSameFamily(normalizedProductColor, normalizedListedColor)) {
        return true;
      }
    }
    
    return false;
  }
}
