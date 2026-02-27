import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/analytics.dart';

class AnalyticsModel extends Analytics {
  const AnalyticsModel({
    required super.totalCustomers,
    required super.totalPoints,
    required super.goldOrAbove,
    required super.updatedAt,
  });

  factory AnalyticsModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return AnalyticsModel(
      totalCustomers: (data['totalCustomers'] as num?)?.toInt() ?? 0,
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      goldOrAbove: (data['goldOrAbove'] as num?)?.toInt() ?? 0,
      updatedAt: updatedAt,
    );
  }
}
