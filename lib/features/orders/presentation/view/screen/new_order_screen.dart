import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/core/utils/input_validators.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/orders/presentation/bloc/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/orders/presentation/bloc/event/new_order_event.dart';
import 'package:delivery_app/features/orders/presentation/bloc/state/new_order_state.dart';
import 'package:delivery_app/features/orders/presentation/view/widgets/add_item_dialog.dart';
import 'package:delivery_app/features/orders/presentation/view/widgets/location_picker_map.dart';
import 'package:delivery_app/features/orders/presentation/view/widgets/order_item_tile.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/app_text_field.dart';
import 'package:delivery_app/shared/widgets/language_toggle_pill.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _pickupNameController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _pickupAddressController = TextEditingController();

  final _dropoffNameController = TextEditingController();
  final _dropoffPhoneController = TextEditingController();
  final _dropoffAddressController = TextEditingController();

  final _codController = TextEditingController(text: '0');
  final _riderNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<NewOrderBloc>()
            .add(SetActivePinTabEvent(_tabController.index));
      }
    });

    final user = context.read<AuthBloc>().state.user;
    context.read<NewOrderBloc>().add(const ResetNewOrderEvent());

    _pickupNameController.text =
        (user?.restaurantName?.isNotEmpty == true)
            ? user!.restaurantName!
            : (user?.name ?? 'Spice Cloud Kitchen');
    _pickupPhoneController.text = user?.phone ?? '03001234567';
    _pickupAddressController.text =
        user?.restaurantAddress ?? 'Plot 14, F-7 Markaz, Islamabad';

    _dropoffNameController.text = '';
    _dropoffPhoneController.text = '';
    _dropoffAddressController.text = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncPickup();
      _syncDropoff();
      context.read<NewOrderBloc>().add(
            const FetchCurrentSenderLocationEvent(
              updatePickupCoordinates: true,
            ),
          );
    });
  }

  void _syncPickup() {
    context.read<NewOrderBloc>().add(
          UpdatePickupDetailsEvent(
            name: _pickupNameController.text,
            phone: _pickupPhoneController.text,
            address: _pickupAddressController.text,
          ),
        );
  }

  void _syncDropoff() {
    context.read<NewOrderBloc>().add(
          UpdateDropoffDetailsEvent(
            name: _dropoffNameController.text,
            phone: _dropoffPhoneController.text,
            address: _dropoffAddressController.text,
          ),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pickupNameController.dispose();
    _pickupPhoneController.dispose();
    _pickupAddressController.dispose();
    _dropoffNameController.dispose();
    _dropoffPhoneController.dispose();
    _dropoffAddressController.dispose();
    _codController.dispose();
    _riderNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final senderId = context.read<AuthBloc>().state.user?.id ?? 'sender_01';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.newDelivery,
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16.w),
            child: const Center(child: LanguageTogglePill()),
          ),
        ],
      ),
      body: BlocConsumer<NewOrderBloc, NewOrderState>(
        listener: (context, state) {
          if (state.locationPermissionError != null &&
              state.locationPermissionError!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.locationPermissionError!),
                backgroundColor: AppColors.warning,
                action: SnackBarAction(
                  label: l10n.retry,
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<NewOrderBloc>().add(
                          const FetchCurrentSenderLocationEvent(
                            updatePickupCoordinates: true,
                          ),
                        );
                  },
                ),
              ),
            );
          }

          if (state.status == NewOrderSubmissionStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == NewOrderSubmissionStatus.success &&
              state.createdOrder != null) {
            final order = state.createdOrder!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${order.orderNumber} — ${l10n.findingNearestRider}',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.goNamed(
              RouteNames.trackOrder,
              queryParameters: {'orderId': order.id},
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MAP SECTION WITH PICKUP & DROP-OFF PIN TABS
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.location_on, size: 18.sp),
                            text: l10n.pickupPinTab,
                          ),
                          Tab(
                            icon: Icon(Icons.flag, size: 18.sp),
                            text: l10n.dropoffPinTab,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 230.h,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            LocationPickerMap(
                              key: const ValueKey('sender_pickup_map'),
                              latitude: state.pickupLatitude,
                              longitude: state.pickupLongitude,
                              senderLatitude: state.senderLatitude,
                              senderLongitude: state.senderLongitude,
                              isLocating: state.isLocatingSender,
                              isPickup: true,
                              onLocationChanged: (lat, lng) {
                                context.read<NewOrderBloc>().add(
                                      UpdatePickupCoordinatesEvent(
                                        latitude: lat,
                                        longitude: lng,
                                      ),
                                    );
                              },
                              onGpsPressed: () {
                                context.read<NewOrderBloc>().add(
                                      const FetchCurrentSenderLocationEvent(
                                        updatePickupCoordinates: true,
                                      ),
                                    );
                              },
                            ),
                            LocationPickerMap(
                              key: const ValueKey('sender_dropoff_map'),
                              latitude: state.dropoffLatitude,
                              longitude: state.dropoffLongitude,
                              senderLatitude: state.senderLatitude,
                              senderLongitude: state.senderLongitude,
                              isLocating: state.isLocatingSender,
                              isPickup: false,
                              onLocationChanged: (lat, lng) {
                                context.read<NewOrderBloc>().add(
                                      UpdateDropoffCoordinatesEvent(
                                        latitude: lat,
                                        longitude: lng,
                                      ),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // PICKUP CARD
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trip_origin,
                              color: AppColors.charcoal,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.pickupInfo,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          controller: _pickupNameController,
                          label: l10n.senderNameLabel,
                          hint: l10n.restaurantNameHint,
                          onChanged: (_) => _syncPickup(),
                        ),
                        SizedBox(height: 10.h),
                        AppTextField(
                          controller: _pickupPhoneController,
                          label: l10n.senderPhoneLabel,
                          hint: l10n.phoneNumberHint,
                          keyboardType: TextInputType.phone,
                          validator: InputValidators.validatePhone,
                          onChanged: (_) => _syncPickup(),
                        ),
                        SizedBox(height: 10.h),
                        AppTextField(
                          controller: _pickupAddressController,
                          label: l10n.pickupAddressLabel,
                          hint: l10n.restaurantAddressHint,
                          onChanged: (_) => _syncPickup(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // DROP-OFF CARD
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              color: AppColors.primary,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.dropoffInfo,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          controller: _dropoffNameController,
                          label: l10n.receiverNameLabel,
                          hint: 'e.g. Ayesha Siddiqui',
                          onChanged: (_) => _syncDropoff(),
                        ),
                        SizedBox(height: 10.h),
                        AppTextField(
                          controller: _dropoffPhoneController,
                          label: l10n.receiverPhoneLabel,
                          hint: l10n.phoneNumberHint,
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => _syncDropoff(),
                        ),
                        SizedBox(height: 10.h),
                        AppTextField(
                          controller: _dropoffAddressController,
                          label: l10n.dropoffAddressLabel,
                          hint: 'House / Apt, Street, Sector',
                          onChanged: (_) => _syncDropoff(),
                        ),
                        SizedBox(height: 10.h),
                        AppTextField(
                          controller: _codController,
                          label: l10n.codAmountLabel,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.payments_outlined,
                          onChanged: (v) {
                            final parsed = double.tryParse(v.trim()) ?? 0;
                            context
                                .read<NewOrderBloc>()
                                .add(UpdateCodAmountEvent(parsed));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // PACKAGE ITEMS CARD
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.packageItems,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => AddItemDialog(
                                    onAdd: (name, qty, notes) {
                                      context.read<NewOrderBloc>().add(
                                            AddOrderItemEvent(
                                              name: name,
                                              quantity: qty,
                                              notes: notes,
                                            ),
                                          );
                                    },
                                  ),
                                );
                              },
                              icon: Icon(Icons.add_circle_outline, size: 18.sp),
                              label: Text(l10n.addItem),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (state.items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              l10n.addItem,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          ...state.items.map(
                            (item) => OrderItemTile(
                              item: item,
                              onDelete: () => context
                                  .read<NewOrderBloc>()
                                  .add(RemoveOrderItemEvent(item.id)),
                            ),
                          ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          controller: _riderNoteController,
                          label: l10n.riderNotesLabel,
                          hint: l10n.riderNotesHint,
                          maxLines: 2,
                          onChanged: (v) => context
                              .read<NewOrderBloc>()
                              .add(UpdateOrderNotesEvent(v)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // ESTIMATED FEE SUMMARY CARD (Matching Reference Design)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.deliveryFeeLabel,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            Formatters.formatCurrency(state.estimatedFeePkr),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (state.codAmountPkr > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.collectCashCod,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(state.codAmountPkr),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                AppButton(
                  text: l10n.confirmDeliveryRequest,
                  isLoading: state.status == NewOrderSubmissionStatus.submitting,
                  onPressed: () {
                    context
                        .read<NewOrderBloc>()
                        .add(SubmitOrderEvent(senderId: senderId));
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
