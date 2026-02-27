import '../../../core/utils/result.dart';
import '../../entities/analytics.dart';
import '../../repositories/loyalty_repository.dart';

class GetAnalyticsUseCase {
  GetAnalyticsUseCase(this._repository);
  final LoyaltyRepository _repository;

  Future<Result<Analytics>> call() {
    return _repository.getAnalytics();
  }
}
