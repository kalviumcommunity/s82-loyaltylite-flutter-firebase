import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/tier_constants.dart';
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    super.phone,
    required super.points,
    required super.tier,
    required super.createdAt,
    required super.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameLower': name.toLowerCase(),
      'phone': phone,
      'points': points,
      'tier': tier,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> updatePointsMap(int newPoints, String newTier) {
    return {
      'points': newPoints,
      'tier': newTier,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CustomerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return CustomerModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'],
      points: (data['points'] as num?)?.toInt() ?? 0,
      tier: data['tier'] ?? TierConstants.tierForPoints(0),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
