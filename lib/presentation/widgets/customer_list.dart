import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/result.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import 'customer_tile.dart';

class CustomerList extends StatelessWidget {
  const CustomerList({
    super.key,
    required this.stream,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.onEndReached,
  });

  final Stream<Result<List<Customer>>> stream;
  final void Function(Customer) onIncrement;
  final void Function(Customer) onDecrement;
  final Future<Result<void>> Function(String id) onDelete;
  final VoidCallback onEndReached;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Result<List<Customer>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final result = snapshot.data!;
        return result.fold((customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 48) {
                onEndReached();
              }
              return false;
            },
            child: ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ChangeNotifierProvider.value(
                  value: context.read<CustomerProvider>(),
                  child: CustomerTile(
                    customer: customer,
                    onIncrement: () => onIncrement(customer),
                    onDecrement: () => onDecrement(customer),
                    onDelete: () => onDelete(customer.id),
                  ),
                );
              },
            ),
          );
        }, (err) {
          return Center(child: Text(err.message));
        });
      },
    );
  }
}
