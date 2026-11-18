import 'package:material_ui/material_ui.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class StatusTimelineWidget extends StatelessWidget {
  final OrderStatus currentStatus;

  const StatusTimelineWidget({super.key, required this.currentStatus});

  static const List<OrderStatus> _steps = [
    OrderStatus.placed,
    OrderStatus.assigned,
    OrderStatus.pickedUp,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                currentStatus.displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: currentStatus.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connecting line
                final stepBefore = index ~/ 2;
                final isPassed = currentIndex != -1 && stepBefore < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? AppColors.primary : AppColors.cardBorder,
                  ),
                );
              }

              // Step indicator
              final stepIndex = index ~/ 2;
              final isCompleted = currentIndex != -1 && stepIndex <= currentIndex;
              final isCurrent = stepIndex == currentIndex;

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? AppColors.primary
                      : isCompleted
                          ? AppColors.primaryLight
                          : AppColors.surfaceVariant,
                  border: Border.all(
                    color: isCompleted ? AppColors.primary : AppColors.cardBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_steps.first.displayName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(_steps.last.displayName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
