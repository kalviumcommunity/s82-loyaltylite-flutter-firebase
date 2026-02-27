import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/customer.dart';
import '../providers/customer_provider.dart';

class CustomerTile extends StatelessWidget {
  const CustomerTile({
    super.key,
    required this.customer,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final Customer customer;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(customer.name),
      subtitle: Text('Tier: ${customer.tier} • Points: ${customer.points}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onDecrement,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onIncrement,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
