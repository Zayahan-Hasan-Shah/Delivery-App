import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/rider/domain/entities/earnings_entity.dart';
import 'package:delivery_app/l10n/app_localizations.dart';

class RiderEarningsView extends StatefulWidget {
  final EarningsEntity? earnings;
  final List<OrderEntity> completedOrders;

  const RiderEarningsView({
    super.key,
    required this.earnings,
    required this.completedOrders,
  });

  @override
  State<RiderEarningsView> createState() => _RiderEarningsViewState();
}

class _RiderEarningsViewState extends State<RiderEarningsView> {
  int _selectedPeriod = 0; // 0: Today, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final e = widget.earnings;
    final amount = switch (_selectedPeriod) {
      0 => e?.todayEarningsPkr ?? 0,
      1 => e?.weekEarningsPkr ?? 0,
      _ => e?.monthEarningsPkr ?? 0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Period Pills (Today / Week / Month)
        Row(
          children: [
            _PeriodChip(
              label: 'Today',
              selected: _selectedPeriod == 0,
              onTap: () => setState(() => _selectedPeriod = 0),
            ),
            SizedBox(width: 8.w),
            _PeriodChip(
              label: 'Week',
              selected: _selectedPeriod == 1,
              onTap: () => setState(() => _selectedPeriod = 1),
            ),
            SizedBox(width: 8.w),
            _PeriodChip(
              label: 'Month',
              selected: _selectedPeriod == 2,
              onTap: () => setState(() => _selectedPeriod = 2),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Dark Charcoal Hero Card (Reference Design)
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.payableEarnings,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withAlpha(190),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                Formatters.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${e?.deliveriesToday ?? 0} ${l10n.deliveriesToday}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Cash Breakdown Card
        Card(
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CashCol(
                  label: 'Collected',
                  value: Formatters.formatCurrency(e?.cashCollectedPkr ?? 0),
                ),
                _CashCol(
                  label: 'Deposited',
                  value: Formatters.formatCurrency(e?.cashDepositedPkr ?? 0),
                ),
                _CashCol(
                  label: l10n.cashInHand,
                  value: Formatters.formatCurrency(e?.cashInHandPkr ?? 0),
                  alignEnd: true,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        Text(
          l10n.recentOrders,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),

        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.completedOrders.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final o = widget.completedOrders[index];
              return ListTile(
                title: Text(
                  o.orderNumber,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${Formatters.formatDate(o.updatedAt)} • COD: ${Formatters.formatCurrency(o.codAmountPkr)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(o.riderSharePkr),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      l10n.riderShare,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.charcoal : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.charcoal : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CashCol extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _CashCol({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
