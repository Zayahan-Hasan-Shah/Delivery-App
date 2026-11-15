import 'package:flutter/material.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (role) {
      case UserRole.customer:
        bg = AppColors.primaryLight.withAlpha(30);
        fg = AppColors.primaryLight;
        icon = Icons.person_outline;
        break;
      case UserRole.client:
        bg = AppColors.accent.withAlpha(38);
        fg = AppColors.accent;
        icon = Icons.storefront_outlined;
        break;
      case UserRole.rider:
        bg = AppColors.success.withAlpha(38);
        fg = AppColors.success;
        icon = Icons.two_wheeler_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
