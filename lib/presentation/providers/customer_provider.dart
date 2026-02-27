import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/debouncer.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customers/create_customer.dart';
import '../../domain/usecases/customers/delete_customer.dart';
import '../../domain/usecases/customers/stream_customers.dart';
import '../../domain/usecases/customers/update_customer_points.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider({
    required CreateCustomerUseCase createCustomer,
    required UpdateCustomerPointsUseCase updatePoints,
    required DeleteCustomerUseCase deleteCustomer,
    required StreamCustomersUseCase streamCustomers,
  })  : _createCustomer = createCustomer,
        _updatePoints = updatePoints,
        _deleteCustomer = deleteCustomer,
        _streamCustomers = streamCustomers {
    _debouncer = Debouncer(delay: AppConstants.defaultDebounce);
  }

  final CreateCustomerUseCase _createCustomer;
  final UpdateCustomerPointsUseCase _updatePoints;
  final DeleteCustomerUseCase _deleteCustomer;
  final StreamCustomersUseCase _streamCustomers;
  late final Debouncer _debouncer;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _limit = AppConstants.defaultPageSize;
  int get limit => _limit;

  String? _startAfterCustomerId;

  void setSearchQuery(String query) {
    _debouncer.run(() {
      _searchQuery = query;
      notifyListeners();
    });
  }

  void setLimit(int newLimit) {
    _limit = newLimit;
    notifyListeners();
  }

  void paginateFrom(String? customerId) {
    _startAfterCustomerId = customerId;
    notifyListeners();
  }

  Stream<Result<List<Customer>>> customersStream() {
    return _streamCustomers(StreamCustomersParams(
      limit: _limit,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      startAfterCustomerId: _startAfterCustomerId,
    ));
  }

  Future<Result<Customer>> addCustomer({required String name, String? phone, int initialPoints = 0}) {
    return _createCustomer(CreateCustomerParams(
      name: name,
      phone: phone,
      initialPoints: initialPoints,
    ));
  }

  Future<Result<Customer>> updatePoints({
    required Customer customer,
    required int delta,
  }) {
    return _updatePoints(UpdateCustomerPointsParams(
      customerId: customer.id,
      currentPoints: customer.points,
      currentTier: customer.tier,
      delta: delta,
    ));
  }

  Future<Result<void>> deleteCustomer(String id) {
    return _deleteCustomer(DeleteCustomerParams(customerId: id));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
