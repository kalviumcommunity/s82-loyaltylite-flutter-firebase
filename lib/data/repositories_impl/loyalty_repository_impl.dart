import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/exceptions/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/loyalty_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  LoyaltyRepositoryImpl(
    this._authService,
    this._firestoreService,
    this._notificationService,
  );

  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  String? _currentUid() => _authService.currentUser?.uid;

  @override
  Future<Result<Customer>> createCustomer({
    required String name,
    String? phone,
    int initialPoints = 0,
    String initialTier = 'Bronze',
  }) async {
    final uid = _currentUid();
    if (uid == null) {
      return Failure(AuthFailure('Not authenticated'));
    }
    try {
      final customer = await _firestoreService.createCustomer(
        userId: uid,
        name: name,
        phone: phone,
        initialPoints: initialPoints,
        initialTier: initialTier,
      );
      return Success(customer);
    } on FirebaseException catch (e, st) {
      return Failure(FirestoreFailure(e.message ?? 'Firestore error', cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure(FirestoreFailure('Create customer failed', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<Customer>> updateCustomerPoints({
    required String customerId,
    required int points,
    required String tier,
    required bool triggerNotification,
  }) async {
    final uid = _currentUid();
    if (uid == null) {
      return Failure(AuthFailure('Not authenticated'));
    }
    try {
      final customer = await _firestoreService.updateCustomerPoints(
        userId: uid,
        customerId: customerId,
        points: points,
        tier: tier,
      );
      if (triggerNotification) {
        try {
          await _notificationService.notifyTierUpgrade(
            userId: uid,
            customerId: customerId,
            newTier: tier,
          );
        } catch (_) {
          // Swallow notification errors to not break primary flow.
        }
      }
      return Success(customer);
    } on FirebaseException catch (e, st) {
      return Failure(FirestoreFailure(e.message ?? 'Firestore error', cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure(FirestoreFailure('Update points failed', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> deleteCustomer({
    required String customerId,
  }) async {
    final uid = _currentUid();
    if (uid == null) {
      return Failure(AuthFailure('Not authenticated'));
    }
    try {
      await _firestoreService.deleteCustomer(userId: uid, customerId: customerId);
      return const Success(null);
    } on FirebaseException catch (e, st) {
      return Failure(FirestoreFailure(e.message ?? 'Firestore error', cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure(FirestoreFailure('Delete customer failed', cause: e, stackTrace: st));
    }
  }

  @override
  Stream<Result<List<Customer>>> streamCustomers({
    int limit = 20,
    String? searchQuery,
    String? startAfterCustomerId,
  }) {
    final uid = _currentUid();
    if (uid == null) {
      return Stream.value(Failure<List<Customer>>(AuthFailure('Not authenticated')));
    }

    Future<Query<Map<String, dynamic>>> buildQuery() async {
      var query = _firestoreService.customersQuery(
        userId: uid,
        limit: limit,
        searchQuery: searchQuery,
      );
      if (startAfterCustomerId != null) {
        final doc = await _firestoreService.fetchCustomerDoc(
          userId: uid,
          customerId: startAfterCustomerId,
        );
        if (doc != null) {
          query = query.startAfterDocument(doc);
        }
      }
      return query;
    }

    Stream<Result<List<Customer>>> transformer(Query<Map<String, dynamic>> query) async* {
      try {
        await for (final customers in _firestoreService.streamCustomers(userId: uid, query: query)) {
          yield Success<List<Customer>>(customers);
        }
      } catch (e, st) {
        yield Failure<List<Customer>>(FirestoreFailure('Stream customers failed', cause: e, stackTrace: st));
      }
    }

    return Stream.fromFuture(buildQuery()).asyncExpand(transformer);
  }

  @override
  Future<Result<Analytics>> getAnalytics() async {
    final uid = _currentUid();
    if (uid == null) {
      return Failure(AuthFailure('Not authenticated'));
    }
    try {
      final analytics = await _firestoreService.getAnalytics(userId: uid);
      return Success<Analytics>(analytics);
    } on FirebaseException catch (e, st) {
      return Failure(FirestoreFailure(e.message ?? 'Firestore error', cause: e, stackTrace: st));
    } catch (e, st) {
      return Failure(FirestoreFailure('Get analytics failed', cause: e, stackTrace: st));
    }
  }
}
