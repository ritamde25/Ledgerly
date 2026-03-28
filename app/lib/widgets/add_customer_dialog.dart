import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/customer.dart';

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({Key? key}) : super(key: key);

  static Future<Customer?> show(BuildContext context) {
    return showDialog<Customer>(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    );
  }

  @override
  _AddCustomerDialogState createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Customer'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Customer Name',
            hintText: 'Enter full name',
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final customer = Provider.of<AppState>(context, listen: false)
                  .addCustomer(_nameController.text);
              Navigator.pop(context, customer);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
