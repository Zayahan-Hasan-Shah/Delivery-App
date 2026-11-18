import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class RoleContactPanel extends StatelessWidget {
  final UserRole currentUserRole;
  final OrderModel order;

  const RoleContactPanel({
    super.key,
    required this.currentUserRole,
    required this.order,
  });

  Future<void> _makePhoneCall(BuildContext context, String phone, String contactTitle) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling $contactTitle at $phone'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    // Customer contact button
    if (currentUserRole != UserRole.customer) {
      final phone = order.customer?.phone ?? order.dropoff.contactPhone;
      final name = order.customer?.name ?? order.dropoff.contactName;
      if (phone.isNotEmpty) {
        actions.add(
          _ContactButton(
            label: 'Call Customer',
            subtitle: name,
            phone: phone,
            icon: Icons.person_outline,
            color: AppColors.primaryLight,
            onPressed: () => _makePhoneCall(context, phone, 'Customer ($name)'),
          ),
        );
      }
    }

    // Rider contact button
    if (currentUserRole != UserRole.rider && order.rider != null) {
      final phone = order.rider!.phone;
      final name = order.rider!.name;
      actions.add(
        _ContactButton(
          label: 'Call Rider',
          subtitle: name,
          phone: phone,
          icon: Icons.two_wheeler_outlined,
          color: AppColors.success,
          onPressed: () => _makePhoneCall(context, phone, 'Rider ($name)'),
        ),
      );
    }

    // Client/Merchant contact button
    if (currentUserRole != UserRole.client) {
      final phone = order.client?.phone ?? order.pickup.contactPhone;
      final name = order.client?.name ?? order.pickup.contactName;
      if (phone.isNotEmpty) {
        actions.add(
          _ContactButton(
            label: 'Call Client/Store',
            subtitle: name,
            phone: phone,
            icon: Icons.storefront_outlined,
            color: AppColors.accent,
            onPressed: () => _makePhoneCall(context, phone, 'Client ($name)'),
          ),
        );
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Involved Parties',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        Row(
          children: actions
              .map(
                (btn) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: btn,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.label,
    required this.subtitle,
    required this.phone,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
