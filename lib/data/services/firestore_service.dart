import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/user_model.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _users() =>
      _firestore.collection(AppConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> _customers(String userId) =>
      _users().doc(userId).collection(AppConstants.customersSubcollection);

  Future<void> createUserProfile({
    required User user,
    String? displayName,
  }) async {
    final docRef = _users().doc(user.uid);
    final data = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName,
      shopInfo: {
        'name': displayName ?? user.displayName ?? 'My Shop',
        'createdAt': FieldValue.serverTimestamp(),
      },
      analytics: {
        'totalCustomers': 0,
        'totalPoints': 0,
        'goldOrAbove': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ).toMap();
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<UserModel> fetchUserProfile(String uid) async {
    final snapshot = await _users().doc(uid).get();
    return UserModel.fromDoc(snapshot);
  }

  Future<CustomerModel> createCustomer({
    required String userId,
    required String name,
    String? phone,
    required int initialPoints,
    required String initialTier,
  }) async {
    final docRef = await _customers(userId).add({
      'name': name,
      'nameLower': name.toLowerCase(),
      'phone': phone,
      'points': initialPoints,
      'tier': initialTier,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snapshot = await docRef.get();
    return CustomerModel.fromDoc(snapshot);
  }

  Future<CustomerModel> updateCustomerPoints({
    required String userId,
    required String customerId,
    required int points,
    required String tier,
  }) async {
    final docRef = _customers(userId).doc(customerId);
    await docRef.update({
      'points': points,
      'tier': tier,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snapshot = await docRef.get();
    return CustomerModel.fromDoc(snapshot);
  }

  Future<void> deleteCustomer({
    required String userId,
    required String customerId,
  }) {
    return _customers(userId).doc(customerId).delete();
  }

  Query<Map<String, dynamic>> customersQuery({
    required String userId,
    required int limit,
    String? searchQuery,
  }) {
    var query = _customers(userId).orderBy('nameLower').limit(limit);
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      query = query
          .startAt([lower])
          .endAt(['$lower\uf8ff']);
    }
    return query;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchCustomerDoc({
    required String userId,
    required String customerId,
  }) async {
    final doc = await _customers(userId).doc(customerId).get();
    return doc.exists ? doc : null;
  }

  Stream<List<CustomerModel>> streamCustomers({
    required String userId,
    required Query<Map<String, dynamic>> query,
  }) {
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map(CustomerModel.fromDoc).toList();
    });
  }

  Future<AnalyticsModel> getAnalytics({required String userId}) async {
    final doc = await _users().doc(userId).get();
    return AnalyticsModel.fromDoc(doc);
  }
}
