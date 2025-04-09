class UserProfile {
  final String id;
  final String name;
  final String email;
  final SkinToneInfo skinToneInfo;
  final List<String> wishlistIds;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.skinToneInfo,
    this.wishlistIds = const [],
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    SkinToneInfo? skinToneInfo,
    List<String>? wishlistIds,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      skinToneInfo: skinToneInfo ?? this.skinToneInfo,
      wishlistIds: wishlistIds ?? this.wishlistIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'skinToneInfo': skinToneInfo.toJson(),
      'wishlistIds': wishlistIds,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      skinToneInfo: SkinToneInfo.fromJson(json['skinToneInfo']),
      wishlistIds: List<String>.from(json['wishlistIds'] ?? []),
    );
  }

  // Create empty user profile
  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      name: '',
      email: '',
      skinToneInfo: SkinToneInfo.empty(),
      wishlistIds: [],
    );
  }

  bool get isComplete {
    return id.isNotEmpty && 
           name.isNotEmpty && 
           email.isNotEmpty && 
           skinToneInfo.isComplete;
  }
}

class SkinToneInfo {
  final String undertone; // warm, cool, neutral
  final String depth; // light, medium, deep
  final List<String> recommendedColors;
  final List<String> notRecommendedColors;

  SkinToneInfo({
    required this.undertone,
    required this.depth,
    this.recommendedColors = const [],
    this.notRecommendedColors = const [],
  });

  SkinToneInfo copyWith({
    String? undertone,
    String? depth,
    List<String>? recommendedColors,
    List<String>? notRecommendedColors,
  }) {
    return SkinToneInfo(
      undertone: undertone ?? this.undertone,
      depth: depth ?? this.depth,
      recommendedColors: recommendedColors ?? this.recommendedColors,
      notRecommendedColors: notRecommendedColors ?? this.notRecommendedColors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'undertone': undertone,
      'depth': depth,
      'recommendedColors': recommendedColors,
      'notRecommendedColors': notRecommendedColors,
    };
  }

  factory SkinToneInfo.fromJson(Map<String, dynamic> json) {
    return SkinToneInfo(
      undertone: json['undertone'] ?? '',
      depth: json['depth'] ?? '',
      recommendedColors: List<String>.from(json['recommendedColors'] ?? []),
      notRecommendedColors: List<String>.from(json['notRecommendedColors'] ?? []),
    );
  }

  // Create empty skin tone info
  factory SkinToneInfo.empty() {
    return SkinToneInfo(
      undertone: '',
      depth: '',
      recommendedColors: [],
      notRecommendedColors: [],
    );
  }

  bool get isComplete {
    return undertone.isNotEmpty && depth.isNotEmpty;
  }
}
