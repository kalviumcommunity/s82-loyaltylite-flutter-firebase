import '../../../core/constants/app_constants.dart';
import '../../../core/utils/result.dart';
import '../../entities/customer.dart';
import '../../repositories/loyalty_repository.dart';

class StreamCustomersParams {
  const StreamCustomersParams({
    this.limit = AppConstants.defaultPageSize,
    this.searchQuery,
    this.startAfterCustomerId,
  });

  final int limit;
  final String? searchQuery;
  final String? startAfterCustomerId;
}

class StreamCustomersUseCase {
  StreamCustomersUseCase(this._repository);
  final LoyaltyRepository _repository;

  Stream<Result<List<Customer>>> call(StreamCustomersParams params) {
    return _repository.streamCustomers(
      limit: params.limit,
      searchQuery: params.searchQuery,
      startAfterCustomerId: params.startAfterCustomerId,
    );
  }
}
