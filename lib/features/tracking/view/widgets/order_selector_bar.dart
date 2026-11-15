import 'package:flutter/material.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class OrderSelectorBar extends StatelessWidget {
  final List<OrderModel> orders;
  final String selectedOrderId;
  final ValueChanged<String> onOrderSelected;

  const OrderSelectorBar({
    super.key,
    required this.orders,
    required this.selectedOrderId,
    required this.onOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final order = orders[index];
          final isSelected = order.id == selectedOrderId;

          return ChoiceChip(
            label: Text(
              order.orderNumber,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: 1,
            ),
            onSelected: (selected) {
              if (selected) {
                onOrderSelected(order.id);
              }
            },
          );
        },
      ),
    );
  }
}
