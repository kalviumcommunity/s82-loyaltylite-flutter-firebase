import '../../../core/utils/result.dart';
import '../../repositories/loyalty_repository.dart';

class DeleteCustomerParams {
  const DeleteCustomerParams({
    required this.customerId,
  });

  final String customerId;
}

class DeleteCustomerUseCase {
  DeleteCustomerUseCase(this._repository);
  final LoyaltyRepository _repository;

  Future<Result<void>> call(DeleteCustomerParams params) {
    return _repository.deleteCustomer(customerId: params.customerId);
  }
}
