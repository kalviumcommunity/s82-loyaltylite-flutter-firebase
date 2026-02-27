import '../../../core/constants/tier_constants.dart';
import '../../../core/utils/result.dart';
import '../../entities/customer.dart';
import '../../repositories/loyalty_repository.dart';

class CreateCustomerParams {
  const CreateCustomerParams({
    required this.name,
    this.phone,
    this.initialPoints = 0,
  });

  final String name;
  final String? phone;
  final int initialPoints;
}

class CreateCustomerUseCase {
  CreateCustomerUseCase(this._repository);
  final LoyaltyRepository _repository;

  Future<Result<Customer>> call(CreateCustomerParams params) {
    final tier = TierConstants.tierForPoints(params.initialPoints);
    return _repository.createCustomer(
      name: params.name,
      phone: params.phone,
      initialPoints: params.initialPoints,
      initialTier: tier,
    );
  }
}
