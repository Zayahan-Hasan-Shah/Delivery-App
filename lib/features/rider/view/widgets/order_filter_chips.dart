import 'package:material_ui/material_ui.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class OrderFilterChips extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const OrderFilterChips({
    super.key,
    this.filters = const ['All', 'Waiting', 'Assigned', 'Picked Up', 'On Road', 'Delivered'],
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == activeFilter;

          return FilterChip(
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
            ),
            onSelected: (_) => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}
