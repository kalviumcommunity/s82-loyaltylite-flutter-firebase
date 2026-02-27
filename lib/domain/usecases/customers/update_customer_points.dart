import '../../../core/constants/tier_constants.dart';
import '../../../core/utils/result.dart';
import '../../entities/customer.dart';
import '../../repositories/loyalty_repository.dart';

class UpdateCustomerPointsParams {
  const UpdateCustomerPointsParams({
    required this.customerId,
    required this.currentPoints,
    required this.currentTier,
    required this.delta,
  });

  final String customerId;
  final int currentPoints;
  final String currentTier;
  final int delta;
}

class UpdateCustomerPointsUseCase {
  UpdateCustomerPointsUseCase(this._repository);
  final LoyaltyRepository _repository;

  Future<Result<Customer>> call(UpdateCustomerPointsParams params) {
    final newPoints = (params.currentPoints + params.delta).clamp(0, 1000000);
    final newTier = TierConstants.tierForPoints(newPoints);
    final upgraded = _isUpgrade(params.currentTier, newTier);
    final triggerNotification = upgraded && (newTier == 'Gold' || newTier == 'Platinum');

    return _repository.updateCustomerPoints(
      customerId: params.customerId,
      points: newPoints,
      tier: newTier,
      triggerNotification: triggerNotification,
    );
  }

  bool _isUpgrade(String currentTier, String newTier) {
    int rank(String tier) {
      switch (tier) {
        case 'Bronze':
          return 1;
        case 'Silver':
          return 2;
        case 'Gold':
          return 3;
        case 'Platinum':
          return 4;
        default:
          return 0;
      }
    }

    return rank(newTier) > rank(currentTier);
  }
}
