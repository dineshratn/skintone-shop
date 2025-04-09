import '../models/skin_tone.dart';
import '../models/user_profile.dart';

class SkinToneService {
  // Get all predefined skin tones
  List<SkinTone> getAllSkinTones() {
    return SkinTone.getPredefinedSkinTones();
  }
  
  // Get skin tones filtered by undertone and/or depth
  List<SkinTone> getFilteredSkinTones({String? undertone, String? depth}) {
    final allSkinTones = getAllSkinTones();
    
    return allSkinTones.where((skinTone) {
      if (undertone != null && undertone.isNotEmpty && skinTone.undertone != undertone) {
        return false;
      }
      
      if (depth != null && depth.isNotEmpty && skinTone.depth != depth) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // Get skin tone by ID
  SkinTone? getSkinToneById(String id) {
    final allSkinTones = getAllSkinTones();
    
    try {
      return allSkinTones.firstWhere((skinTone) => skinTone.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Find the best matching skin tone based on user's selection
  SkinTone? findMatchingSkinTone(String undertone, String depth) {
    if (undertone.isEmpty || depth.isEmpty) {
      return null;
    }
    
    final filteredTones = getFilteredSkinTones(
      undertone: undertone,
      depth: depth,
    );
    
    return filteredTones.isNotEmpty ? filteredTones.first : null;
  }
  
  // Generate recommended colors based on skin tone info
  List<String> getRecommendedColors(SkinToneInfo skinToneInfo) {
    final matchingSkinTone = findMatchingSkinTone(
      skinToneInfo.undertone,
      skinToneInfo.depth,
    );
    
    if (matchingSkinTone != null) {
      return matchingSkinTone.recommendedColors;
    }
    
    // Default recommendations based on undertone if no exact match
    if (skinToneInfo.undertone == 'warm') {
      return [
        'Gold', 'Coral', 'Peach', 'Orange', 'Warm Red',
        'Olive Green', 'Terracotta', 'Amber', 'Bronze'
      ];
    } else if (skinToneInfo.undertone == 'cool') {
      return [
        'Silver', 'Rose Pink', 'Blue Red', 'Emerald',
        'Royal Blue', 'Lavender', 'Raspberry', 'Purple'
      ];
    } else {
      // Neutral undertone
      return [
        'Navy', 'Teal', 'Soft White', 'Medium Blue',
        'Sage Green', 'Medium Purple', 'Burgundy'
      ];
    }
  }
  
  // Generate colors to avoid based on skin tone info
  List<String> getColorsToAvoid(SkinToneInfo skinToneInfo) {
    final matchingSkinTone = findMatchingSkinTone(
      skinToneInfo.undertone,
      skinToneInfo.depth,
    );
    
    if (matchingSkinTone != null) {
      return matchingSkinTone.notRecommendedColors;
    }
    
    // Default colors to avoid based on undertone if no exact match
    if (skinToneInfo.undertone == 'warm') {
      return [
        'Silver', 'Blue-based Pink', 'Cold Blue',
        'Icy Pastels', 'Magenta', 'Deep Purple'
      ];
    } else if (skinToneInfo.undertone == 'cool') {
      return [
        'Orange', 'Warm Yellow', 'Gold', 'Peach',
        'Coral', 'Camel', 'Rust', 'Olive'
      ];
    } else {
      // Neutral undertone
      return [
        'Neon Colors', 'Very Bright Colors'
      ];
    }
  }
}
