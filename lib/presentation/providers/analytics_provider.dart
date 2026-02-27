import 'package:flutter/foundation.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/usecases/analytics/get_analytics.dart';

enum AnalyticsStatus { idle, loading, loaded, error }

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider(this._getAnalytics);

  final GetAnalyticsUseCase _getAnalytics;

  AnalyticsStatus _status = AnalyticsStatus.idle;
  AnalyticsStatus get status => _status;

  Analytics? _data;
  Analytics? get data => _data;

  AppException? _error;
  AppException? get error => _error;

  Future<void> refresh() async {
    _status = AnalyticsStatus.loading;
    notifyListeners();
    final result = await _getAnalytics();
    result.fold((value) {
      _data = value;
      _status = AnalyticsStatus.loaded;
      _error = null;
    }, (err) {
      _status = AnalyticsStatus.error;
      _error = err;
    });
    notifyListeners();
  }
}
