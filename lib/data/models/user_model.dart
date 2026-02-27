import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class UserModel extends UserProfile {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.shopInfo = const {},
    super.analytics = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'shopInfo': shopInfo,
      'analytics': analytics,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      shopInfo: Map<String, dynamic>.from(data['shopInfo'] ?? {}),
      analytics: Map<String, dynamic>.from(data['analytics'] ?? {}),
    );
  }
}
