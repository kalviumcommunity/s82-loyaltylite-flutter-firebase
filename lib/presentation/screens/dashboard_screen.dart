import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/customer.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/analytics_summary.dart';
import '../widgets/customer_form_modal.dart';
import '../widgets/customer_list.dart';
import '../widgets/search_bar.dart' as widgets;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().refresh();
    });
  }

  void _openAddCustomer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CustomerFormModal(),
    );
  }

  void _increment(Customer customer) {
    context.read<CustomerProvider>().updatePoints(customer: customer, delta: 10);
  }

  void _decrement(Customer customer) {
    context.read<CustomerProvider>().updatePoints(customer: customer, delta: -10);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customerProvider = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LoyaltyLite Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AnalyticsProvider>().refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hello, ${auth.user?.displayName ?? auth.user?.email ?? 'Merchant'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                const AnalyticsSummary(),
                const SizedBox(height: 12),
                widgets.SearchBar(
                  onChanged: customerProvider.setSearchQuery,
                  hintText: 'Search customers',
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomerList(
              stream: customerProvider.customersStream(),
              onIncrement: _increment,
              onDecrement: _decrement,
              onDelete: (id) => customerProvider.deleteCustomer(id),
              onEndReached: () {
                // Simple pagination trigger: increase limit.
                customerProvider.setLimit(customerProvider.limit + AppConstants.defaultPageSize);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomer,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
    );
  }
}
