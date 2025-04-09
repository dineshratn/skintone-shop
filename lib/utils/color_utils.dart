class ColorUtils {
  // Map of color families (groups of related colors)
  static final Map<String, List<String>> colorFamilies = {
    'red': ['red', 'maroon', 'burgundy', 'crimson', 'scarlet', 'ruby', 'cherry'],
    'pink': ['pink', 'rose', 'fuchsia', 'magenta', 'salmon'],
    'orange': ['orange', 'peach', 'coral', 'amber', 'terracotta', 'rust'],
    'yellow': ['yellow', 'gold', 'mustard', 'lemon', 'honey'],
    'green': ['green', 'olive', 'emerald', 'lime', 'mint', 'sage', 'forest green', 'hunter green'],
    'blue': ['blue', 'navy', 'teal', 'turquoise', 'cobalt', 'royal blue', 'sky blue', 'cyan'],
    'purple': ['purple', 'lavender', 'violet', 'plum', 'lilac', 'mauve', 'indigo', 'amethyst'],
    'brown': ['brown', 'tan', 'beige', 'camel', 'khaki', 'chestnut', 'chocolate', 'coffee'],
    'neutral': ['white', 'black', 'gray', 'grey', 'silver', 'ivory', 'cream'],
  };

  // Map of colors that are "warm" or "cool"
  static final Map<String, String> colorTones = {
    'red': 'warm',
    'burgundy': 'cool',
    'crimson': 'warm',
    'scarlet': 'warm',
    'maroon': 'cool',
    'ruby': 'cool',
    'cherry': 'cool',
    'pink': 'cool',
    'rose': 'cool',
    'salmon': 'warm',
    'fuchsia': 'cool',
    'magenta': 'cool',
    'orange': 'warm',
    'peach': 'warm',
    'coral': 'warm',
    'amber': 'warm',
    'terracotta': 'warm',
    'rust': 'warm',
    'yellow': 'warm',
    'gold': 'warm',
    'mustard': 'warm',
    'lemon': 'cool',
    'honey': 'warm',
    'green': 'neutral',
    'olive': 'warm',
    'emerald': 'cool',
    'lime': 'cool',
    'mint': 'cool',
    'sage': 'cool',
    'forest green': 'cool',
    'hunter green': 'cool',
    'blue': 'cool',
    'navy': 'cool',
    'teal': 'cool',
    'turquoise': 'cool',
    'cobalt': 'cool',
    'royal blue': 'cool',
    'sky blue': 'cool',
    'cyan': 'cool',
    'purple': 'cool',
    'lavender': 'cool',
    'violet': 'cool',
    'plum': 'cool',
    'lilac': 'cool',
    'mauve': 'cool',
    'indigo': 'cool',
    'amethyst': 'cool',
    'brown': 'warm',
    'tan': 'warm',
    'beige': 'warm',
    'camel': 'warm',
    'khaki': 'warm',
    'chestnut': 'warm',
    'chocolate': 'warm',
    'coffee': 'warm',
    'white': 'neutral',
    'black': 'neutral',
    'gray': 'neutral',
    'grey': 'neutral',
    'silver': 'cool',
    'ivory': 'warm',
    'cream': 'warm',
  };

  // Check if a color string contains any color from a family
  static bool containsColorFromFamily(String colorStr, String familyKey) {
    final normalizedColor = colorStr.toLowerCase();
    final familyColors = colorFamilies[familyKey.toLowerCase()] ?? [];
    
    for (final color in familyColors) {
      if (normalizedColor.contains(color)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Get the family that a color belongs to
  static String? getColorFamily(String colorStr) {
    final normalizedColor = colorStr.toLowerCase();
    
    for (final entry in colorFamilies.entries) {
      for (final color in entry.value) {
        if (normalizedColor.contains(color)) {
          return entry.key;
        }
      }
    }
    
    return null;
  }
  
  // Check if a color is warm, cool, or neutral
  static String getColorTone(String colorStr) {
    final normalizedColor = colorStr.toLowerCase();
    
    // Check for exact matches first
    if (colorTones.containsKey(normalizedColor)) {
      return colorTones[normalizedColor]!;
    }
    
    // Check for partial matches
    for (final entry in colorTones.entries) {
      if (normalizedColor.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return 'neutral'; // Default to neutral if no match
  }
  
  // Check if two colors are in the same color family
  static bool areColorsInSameFamily(String color1, String color2) {
    final family1 = getColorFamily(color1);
    final family2 = getColorFamily(color2);
    
    if (family1 == null || family2 == null) {
      return false;
    }
    
    return family1 == family2;
  }
  
  // Calculate if a color is likely to be compatible with an undertone
  static bool isColorCompatibleWithUndertone(String colorStr, String undertone) {
    final colorTone = getColorTone(colorStr);
    
    // Neutrals are generally compatible with all undertones
    if (colorTone == 'neutral') {
      return true;
    }
    
    // Warm colors for warm undertones, cool colors for cool undertones
    if (colorTone == undertone) {
      return true;
    }
    
    // Neutral undertones can wear both warm and cool colors
    if (undertone == 'neutral') {
      return true;
    }
    
    return false;
  }
  
  // Get base color from a compound or qualified color (e.g., "Light Blue" -> "Blue")
  static String getBaseColor(String colorStr) {
    final normalized = colorStr.toLowerCase();
    
    // Check all color families to find a match
    for (final family in colorFamilies.entries) {
      for (final color in family.value) {
        if (normalized.contains(color)) {
          return color;
        }
      }
    }
    
    return colorStr; // Return original if no match
  }
}
