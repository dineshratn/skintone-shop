class SkinToneInfo {
  final String undertone; // warm, cool, neutral
  final String depth; // light, medium, deep
  final List<String> recommendedColors;
  final List<String> notRecommendedColors;
  final String description; // Human-readable description from AI analysis
  final String gender; // male, female, unspecified
  final String ageGroup; // child, teen, adult, senior

  SkinToneInfo({
    required this.undertone,
    required this.depth,
    this.recommendedColors = const [],
    this.notRecommendedColors = const [],
    this.description = '',
    this.gender = 'unspecified',
    this.ageGroup = 'adult',
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'undertone': undertone,
      'depth': depth,
      'recommendedColors': recommendedColors,
      'notRecommendedColors': notRecommendedColors,
      'description': description,
      'gender': gender,
      'ageGroup': ageGroup,
    };
  }

  // Create from JSON
  factory SkinToneInfo.fromJson(Map<String, dynamic> json) {
    return SkinToneInfo(
      undertone: json['undertone'] ?? '',
      depth: json['depth'] ?? '',
      recommendedColors: List<String>.from(json['recommendedColors'] ?? []),
      notRecommendedColors: List<String>.from(json['notRecommendedColors'] ?? []),
      description: json['description'] ?? '',
      gender: json['gender'] ?? 'unspecified',
      ageGroup: json['age_group'] ?? json['ageGroup'] ?? 'adult',
    );
  }

  // Create from SkinTone
  factory SkinToneInfo.fromSkinTone(SkinTone skinTone) {
    return SkinToneInfo(
      undertone: skinTone.undertone,
      depth: skinTone.depth,
      recommendedColors: List<String>.from(skinTone.recommendedColors),
      notRecommendedColors: List<String>.from(skinTone.notRecommendedColors),
      description: skinTone.description,
    );
  }

  // Check if the skin tone info is complete
  bool get isComplete {
    return undertone.isNotEmpty && depth.isNotEmpty;
  }

  // Create an empty skin tone info object
  factory SkinToneInfo.empty() {
    return SkinToneInfo(
      undertone: '',
      depth: '',
      recommendedColors: [],
      notRecommendedColors: [],
      description: '',
      gender: 'unspecified',
      ageGroup: 'adult',
    );
  }
}

class SkinTone {
  final String id;
  final String name;
  final String description;
  final String undertone; // warm, cool, neutral
  final String depth; // light, medium, deep
  final List<String> recommendedColors;
  final List<String> notRecommendedColors;
  final String imageUrl;

  SkinTone({
    required this.id,
    required this.name,
    required this.description,
    required this.undertone,
    required this.depth,
    required this.recommendedColors,
    required this.notRecommendedColors,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'undertone': undertone,
      'depth': depth,
      'recommendedColors': recommendedColors,
      'notRecommendedColors': notRecommendedColors,
      'imageUrl': imageUrl,
    };
  }

  factory SkinTone.fromJson(Map<String, dynamic> json) {
    return SkinTone(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      undertone: json['undertone'],
      depth: json['depth'],
      recommendedColors: List<String>.from(json['recommendedColors']),
      notRecommendedColors: List<String>.from(json['notRecommendedColors']),
      imageUrl: json['imageUrl'],
    );
  }

  static List<SkinTone> getPredefinedSkinTones() {
    return [
      SkinTone(
        id: 'warm_light',
        name: 'Light Warm',
        description: 'Light skin with warm/golden/peachy undertones',
        undertone: 'warm',
        depth: 'light',
        recommendedColors: [
          'Peach', 'Coral', 'Warm orange', 'Golden yellow', 'Olive green',
          'Warm red', 'Terracotta', 'Ivory', 'Cream', 'Bronze'
        ],
        notRecommendedColors: [
          'Blue-based pink', 'Cold blue', 'Silver', 'Icy pastels', 'Deep purple'
        ],
        imageUrl: 'https://example.com/skintone/warm_light.jpg',
      ),
      SkinTone(
        id: 'warm_medium',
        name: 'Medium Warm',
        description: 'Medium skin with warm/golden/yellow undertones',
        undertone: 'warm',
        depth: 'medium',
        recommendedColors: [
          'Amber', 'Warm brown', 'Orange red', 'Teal', 'Forest green',
          'Warm coral', 'Camel', 'Honey', 'Mustard', 'Bronze'
        ],
        notRecommendedColors: [
          'Pastel blue', 'Cool gray', 'Magenta', 'Baby pink', 'Icy white'
        ],
        imageUrl: 'https://example.com/skintone/warm_medium.jpg',
      ),
      SkinTone(
        id: 'warm_deep',
        name: 'Deep Warm',
        description: 'Deep skin with warm/golden/red undertones',
        undertone: 'warm',
        depth: 'deep',
        recommendedColors: [
          'Bright orange', 'Warm red', 'Gold', 'Copper', 'Hunter green',
          'Tangerine', 'Bright yellow', 'Magenta', 'Purple', 'Fuchsia'
        ],
        notRecommendedColors: [
          'Pale pastels', 'Light beige', 'Muted colors', 'Olive', 'Dusty rose'
        ],
        imageUrl: 'https://example.com/skintone/warm_deep.jpg',
      ),
      SkinTone(
        id: 'cool_light',
        name: 'Light Cool',
        description: 'Light skin with cool/pink/blue undertones',
        undertone: 'cool',
        depth: 'light',
        recommendedColors: [
          'Rose pink', 'Blue-red', 'Lavender', 'Navy', 'Emerald',
          'Raspberry', 'Blue-toned purple', 'Silver', 'Soft white', 'Gray'
        ],
        notRecommendedColors: [
          'Orange', 'Warm yellows', 'Peach', 'Coral', 'Camel'
        ],
        imageUrl: 'https://example.com/skintone/cool_light.jpg',
      ),
      SkinTone(
        id: 'cool_medium',
        name: 'Medium Cool',
        description: 'Medium skin with cool/pink/blue undertones',
        undertone: 'cool',
        depth: 'medium',
        recommendedColors: [
          'Fuchsia', 'Plum', 'Ruby', 'Royal blue', 'Pine green',
          'True red', 'Cool pink', 'Cool mint', 'Deep purple', 'Burgundy'
        ],
        notRecommendedColors: [
          'Rust', 'Warm brown', 'Yellow', 'Orange', 'Olive'
        ],
        imageUrl: 'https://example.com/skintone/cool_medium.jpg',
      ),
      SkinTone(
        id: 'cool_deep',
        name: 'Deep Cool',
        description: 'Deep skin with cool/blue/red undertones',
        undertone: 'cool',
        depth: 'deep',
        recommendedColors: [
          'Royal purple', 'True red', 'Hot pink', 'Cobalt blue', 'Emerald green',
          'Pure white', 'Bright berry tones', 'True blue', 'Electric blue', 'Wine red'
        ],
        notRecommendedColors: [
          'Orange', 'Khaki', 'Muted browns', 'Light pastels', 'Warm yellows'
        ],
        imageUrl: 'https://example.com/skintone/cool_deep.jpg',
      ),
      SkinTone(
        id: 'neutral_light',
        name: 'Light Neutral',
        description: 'Light skin with balanced undertones',
        undertone: 'neutral',
        depth: 'light',
        recommendedColors: [
          'Soft pink', 'Light blue', 'Camel', 'Medium gray', 'Sage green',
          'Periwinkle', 'Soft white', 'Navy', 'Medium purple', 'Teal'
        ],
        notRecommendedColors: [
          'Very bright colors', 'Neon colors', 'Very dark colors'
        ],
        imageUrl: 'https://example.com/skintone/neutral_light.jpg',
      ),
      SkinTone(
        id: 'neutral_medium',
        name: 'Medium Neutral',
        description: 'Medium skin with balanced undertones',
        undertone: 'neutral',
        depth: 'medium',
        recommendedColors: [
          'Teal', 'Medium blue', 'Coral', 'Burgundy', 'Olive green',
          'Medium purple', 'Camel', 'Forest green', 'Russet', 'Navy'
        ],
        notRecommendedColors: [
          'Neon colors', 'Very pale pastels'
        ],
        imageUrl: 'https://example.com/skintone/neutral_medium.jpg',
      ),
      SkinTone(
        id: 'neutral_deep',
        name: 'Deep Neutral',
        description: 'Deep skin with balanced undertones',
        undertone: 'neutral',
        depth: 'deep',
        recommendedColors: [
          'Emerald green', 'Royal blue', 'Bright red', 'Pure white', 'Orange',
          'Fuchsia', 'Cobalt blue', 'Gold', 'Bright yellow', 'Purple'
        ],
        notRecommendedColors: [
          'Beige', 'Pale yellow', 'Light pastels', 'Muted tones'
        ],
        imageUrl: 'https://example.com/skintone/neutral_deep.jpg',
      ),
    ];
  }
}
