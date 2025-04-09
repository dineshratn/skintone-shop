import 'skin_tone.dart';

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
