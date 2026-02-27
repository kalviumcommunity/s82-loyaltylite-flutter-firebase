import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/result.dart';
import '../providers/customer_provider.dart';

class CustomerFormModal extends StatefulWidget {
  const CustomerFormModal({super.key});

  @override
  State<CustomerFormModal> createState() => _CustomerFormModalState();
}

class _CustomerFormModalState extends State<CustomerFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CustomerProvider>();
    final initialPoints = int.tryParse(_pointsController.text) ?? 0;
    final result = await provider.addCustomer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      initialPoints: initialPoints,
    );
    result.fold(
      (_) => Navigator.of(context).pop(),
      (error) => _showError(error.message),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: inset.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Customer', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Name required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Initial Points'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
