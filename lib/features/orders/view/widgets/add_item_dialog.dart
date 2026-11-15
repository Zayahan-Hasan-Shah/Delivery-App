import 'package:flutter/material.dart';
import 'package:delivery_app/features/orders/model/order_item_model.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/app_text_field.dart';
import 'package:delivery_app/core/utils/input_validators.dart';

class AddItemDialog extends StatefulWidget {
  final OrderItemModel? initialItem;
  final void Function(String name, int quantity) onSave;

  const AddItemDialog({super.key, this.initialItem, required this.onSave});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialItem?.name ?? '');
    _quantityController = TextEditingController(text: widget.initialItem?.quantity.toString() ?? '1');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final quantity = int.parse(_quantityController.text.trim());
      widget.onSave(name, quantity);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? 'Edit Package Item' : 'Add Package Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Item Description',
              hint: 'e.g. Important Documents, Laptop, Shoes',
              validator: (val) => InputValidators.validateRequired(val, 'Item description'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _quantityController,
              label: 'Quantity',
              hint: '1',
              keyboardType: TextInputType.number,
              validator: (val) => InputValidators.validatePositiveInteger(val, 'Quantity'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 110,
          child: AppButton(
            text: isEditing ? 'Update' : 'Add',
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
