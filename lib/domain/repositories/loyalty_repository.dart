import '../../core/utils/result.dart';
import '../entities/analytics.dart';
import '../entities/customer.dart';

abstract class LoyaltyRepository {
  Future<Result<Customer>> createCustomer({
    required String name,
    String? phone,
    int initialPoints = 0,
    String initialTier = 'Bronze',
  });

  Future<Result<Customer>> updateCustomerPoints({
    required String customerId,
    required int points,
    required String tier,
    required bool triggerNotification,
  });

  Future<Result<void>> deleteCustomer({
    required String customerId,
  });

  Stream<Result<List<Customer>>> streamCustomers({
    int limit,
    String? searchQuery,
    String? startAfterCustomerId,
  });

  Future<Result<Analytics>> getAnalytics();
}
