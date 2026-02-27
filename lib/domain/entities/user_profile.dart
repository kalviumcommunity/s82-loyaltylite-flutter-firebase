class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.shopInfo = const {},
    this.analytics = const {},
  });

  final String uid;
  final String email;
  final String? displayName;
  final Map<String, dynamic> shopInfo;
  final Map<String, dynamic> analytics;

  UserProfile copyWith({
    String? email,
    String? displayName,
    Map<String, dynamic>? shopInfo,
    Map<String, dynamic>? analytics,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      shopInfo: shopInfo ?? this.shopInfo,
      analytics: analytics ?? this.analytics,
    );
  }
}
