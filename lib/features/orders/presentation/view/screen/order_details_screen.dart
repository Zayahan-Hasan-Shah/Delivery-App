import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/external_launcher.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:delivery_app/features/orders/presentation/view/widgets/order_item_tile.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/service/background_delivery_service.dart';
import 'package:delivery_app/shared/service/document_picker_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderEntity order;
  final Color? assignedColor;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.assignedColor,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderEntity _order;
  late final MapController _mapController;
  final _otpController = TextEditingController();
  StreamSubscription<UserLocation>? _riderLocationSub;
  LatLng? _riderCurrentLatLng;
  bool _isUpdating = false;
  String? _proofPhotoPath;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _proofPhotoPath = widget.order.proofPhotoPath;
    _mapController = MapController();
    _initRiderLiveLocation();
  }

  Future<void> _initRiderLiveLocation() async {
    final user = context.read<AuthBloc>().state.user;
    if (user?.role.isRider != true) return;

    final bgService = sl<BackgroundDeliveryService>();
    final locService = sl<LocationService>();

    final cached = bgService.currentRiderLocation ?? locService.lastKnownLocation;
    if (cached != null && mounted) {
      setState(() {
        _riderCurrentLatLng = LatLng(cached.latitude, cached.longitude);
      });
    }

    _riderLocationSub = bgService.riderLiveLocationStream.listen((loc) {
      if (mounted) {
        setState(() {
          _riderCurrentLatLng = LatLng(loc.latitude, loc.longitude);
        });
      }
    });

    // Fetch a fresh GPS fix immediately so Rider always sees their real location
    final fresh = await locService.getCurrentLocation();
    if (fresh != null && mounted) {
      setState(() {
        _riderCurrentLatLng = LatLng(fresh.latitude, fresh.longitude);
      });
    }
  }

  @override
  void dispose() {
    _riderLocationSub?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Color get _orderColor =>
      widget.assignedColor ??
      OrderColorHelper.colorForOrderId(
        _order.id,
        colorIndex: _order.colorIndex,
      );

  double _approxDistanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = (b.latitude - a.latitude) * (pi / 180.0);
    final dLng = (b.longitude - a.longitude) * (pi / 180.0);
    final s1 = sin(dLat / 2);
    final s2 = sin(dLng / 2);
    final h = s1 * s1 +
        cos(a.latitude * pi / 180.0) *
            cos(b.latitude * pi / 180.0) *
            s2 *
            s2;
    return 2 * r * atan2(sqrt(h), sqrt(1 - h));
  }

  void _fitRoute() {
    final pickup = LatLng(_order.pickup.latitude, _order.pickup.longitude);
    final dropoff = LatLng(_order.dropoff.latitude, _order.dropoff.longitude);
    final points = <LatLng>[pickup, dropoff];
    if (_riderCurrentLatLng != null &&
        _approxDistanceKm(_riderCurrentLatLng!, pickup) < 100.0) {
      points.add(_riderCurrentLatLng!);
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(34.w)),
    );
  }

  void _centerOnRider() {
    if (_riderCurrentLatLng != null) {
      _mapController.move(_riderCurrentLatLng!, 15.2);
    }
  }

  void _openInAppNavigation({required bool toPickup}) {
    context.pushNamed(
      RouteNames.inAppNavigation,
      extra: {
        'order': _order,
        'toPickup': toPickup,
        'color': _orderColor,
      },
    );
  }

  Future<void> _captureProofPhoto() async {
    final l10n = AppLocalizations.of(context);
    final picker = sl<DocumentPickerService>();

    final picked = await showModalBottomSheet<PickedDocumentImage>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${l10n.addProofPhoto} (${_order.orderNumber})',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Optional handover photo confirming parcel delivery.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14.h),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.takePhotoCamera),
                  onTap: () async {
                    final img = await picker.pickFromCamera();
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop(img);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () async {
                    final img = await picker.pickFromGallery();
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop(img);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.verified_outlined,
                    color: AppColors.success,
                  ),
                  title: Text(l10n.useSampleDocument),
                  onTap: () {
                    Navigator.of(sheetCtx).pop(
                      picker.createSampleDocument(
                        'delivery_proof_${_order.orderNumber}',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() => _proofPhotoPath = picked.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.photoAdded}: ${picked.fileName}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (picker.lastErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(picker.lastErrorMessage!),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _advanceStatus(OrderStatus nextStatus) async {
    if (nextStatus == OrderStatus.delivered) {
      final entered = _otpController.text.trim();
      if (entered.isNotEmpty && entered != _order.deliveryOtp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid Recipient OTP. Expected ${_order.deliveryOtp} (Demo).',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isUpdating = true);
    try {
      final updated = await sl<UpdateOrderStatusUseCase>()(
        orderId: _order.id,
        newStatus: nextStatus,
        proofPhotoPath: _proofPhotoPath,
      );
      if (mounted) {
        setState(() {
          _order = updated;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_order.orderNumber} updated to ${nextStatus.displayName}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.read<AuthBloc>().state.user;
    final isRider = user?.role.isRider ?? false;
    final pickupLatLng = LatLng(_order.pickup.latitude, _order.pickup.longitude);
    final dropoffLatLng =
        LatLng(_order.dropoff.latitude, _order.dropoff.longitude);
    final centerLatLng = LatLng(
      (pickupLatLng.latitude + dropoffLatLng.latitude) / 2,
      (pickupLatLng.longitude + dropoffLatLng.longitude) / 2,
    );

    final progressStep = switch (_order.status) {
      OrderStatus.placed || OrderStatus.accepted || OrderStatus.assigned => 1,
      OrderStatus.pickedUp => 2,
      OrderStatus.onTheWay => 3,
      OrderStatus.delivered => 4,
      _ => 0,
    };

    final activeLegDestination =
        (_order.status == OrderStatus.pickedUp ||
                _order.status == OrderStatus.onTheWay)
            ? dropoffLatLng
            : pickupLatLng;

    final polylines = <Polyline>[
      Polyline(
        points: [pickupLatLng, dropoffLatLng],
        color: _orderColor,
        strokeWidth: 4.5,
      ),
      if (isRider &&
          _riderCurrentLatLng != null &&
          _approxDistanceKm(_riderCurrentLatLng!, activeLegDestination) < 100.0)
        Polyline(
          points: [_riderCurrentLatLng!, activeLegDestination],
          color: AppColors.charcoal.withAlpha(180),
          strokeWidth: 3.2,
        ),
    ];

    final markers = <Marker>[
      Marker(
        point: pickupLatLng,
        width: 38.w,
        height: 38.w,
        child: _PinBadge(
          icon: Icons.storefront_rounded,
          color: _orderColor,
          isFilled: false,
        ),
      ),
      Marker(
        point: dropoffLatLng,
        width: 38.w,
        height: 38.w,
        child: _PinBadge(
          icon: Icons.flag_rounded,
          color: _orderColor,
          isFilled: true,
        ),
      ),
      if (isRider && _riderCurrentLatLng != null)
        Marker(
          point: _riderCurrentLatLng!,
          width: 84.w,
          height: 58.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  l10n.youAreHere,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(70),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.two_wheeler_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _orderColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${l10n.orderDetails} • ${_order.orderNumber}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 14.w),
            child: Center(child: StatusChip(status: _order.status)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bars
            Row(
              children: List.generate(4, (idx) {
                final filled = idx < progressStep;
                return Expanded(
                  child: Container(
                    height: 6.h,
                    margin: EdgeInsets.only(right: idx < 3 ? 6.w : 0),
                    decoration: BoxDecoration(
                      color: filled ? _orderColor : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),

            // Color-coded Route Preview Map (with Rider Live Location!)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 215.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _orderColor.withAlpha(110),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: centerLatLng,
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.shefscloud.delivery',
                        ),
                        PolylineLayer(polylines: polylines),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                    // Top-Right Map Controls: Fit Route + Rider My Location
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.white.withAlpha(240),
                            borderRadius: BorderRadius.circular(10.r),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.r),
                              onTap: _fitRoute,
                              child: Padding(
                                padding: EdgeInsets.all(7.w),
                                child: Icon(
                                  Icons.fit_screen_rounded,
                                  size: 18.sp,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ),
                          ),
                          if (isRider && _riderCurrentLatLng != null) ...[
                            SizedBox(height: 8.h),
                            Material(
                              color: Colors.white.withAlpha(240),
                              borderRadius: BorderRadius.circular(10.r),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10.r),
                                onTap: _centerOnRider,
                                child: Padding(
                                  padding: EdgeInsets.all(7.w),
                                  child: Icon(
                                    Icons.my_location_rounded,
                                    size: 18.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // PICKUP & DROP-OFF DETAILS CARD
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationDetailRow(
                      label: l10n.pickupLabel,
                      name: _order.pickup.contactName,
                      address: _order.pickup.addressText,
                      phone: _order.pickup.contactPhone,
                      dotColor: AppColors.charcoal,
                      onCall: () => ExternalLauncher.openPhoneDialer(
                        context,
                        _order.pickup.contactPhone,
                      ),
                      onNavigate: () => _openInAppNavigation(toPickup: true),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Divider(),
                    ),
                    _LocationDetailRow(
                      label: l10n.dropoffLabel,
                      name: _order.dropoff.contactName,
                      address: _order.dropoff.addressText,
                      phone: _order.dropoff.contactPhone,
                      dotColor: _orderColor,
                      onCall: () => ExternalLauncher.openPhoneDialer(
                        context,
                        _order.dropoff.contactPhone,
                      ),
                      onNavigate: () => _openInAppNavigation(toPickup: false),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.collectCashCod,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(_order.codAmountPkr),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRider ? l10n.riderShare : l10n.deliveryFee,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            isRider
                                ? _order.riderSharePkr
                                : _order.deliveryFeePkr,
                          ),
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
            ),
            SizedBox(height: 14.h),

            // ITEMS LIST CARD
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.packageItems,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ..._order.items.map((item) => OrderItemTile(item: item)),
                    if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          _order.notes!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // SENDER VIEW: Delivery OTP & Track Button
            if (!isRider) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.yourDeliveryCode,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              l10n.tellOtpToRider,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _order.deliveryOtp,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              if (_order.status.isActive)
                AppButton(
                  text: l10n.liveTracking,
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    context.pushNamed(
                      RouteNames.trackOrder,
                      queryParameters: {'orderId': _order.id},
                    );
                  },
                ),
            ],

            // RIDER VIEW: Action Controls, OTP Handover & Proof Photo
            if (isRider && _order.status.isActive) ...[
              if (_order.status == OrderStatus.onTheWay) ...[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.recipientOtp} (Demo: ${_order.deliveryOtp})',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 8,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: '• • • •',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Quick Navigate & Optional Proof of Delivery Photo Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final toPickup =
                            _order.status == OrderStatus.assigned ||
                                _order.status == OrderStatus.accepted ||
                                _order.status == OrderStatus.placed;
                        _openInAppNavigation(toPickup: toPickup);
                      },
                      icon: Icon(Icons.navigation_rounded, size: 18.sp),
                      label: Text(l10n.navigate),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _captureProofPhoto,
                      icon: Icon(
                        _proofPhotoPath != null
                            ? Icons.check_circle_rounded
                            : Icons.camera_alt_outlined,
                        size: 18.sp,
                        color: _proofPhotoPath != null
                            ? AppColors.success
                            : AppColors.charcoal,
                      ),
                      label: Text(
                        _proofPhotoPath != null
                            ? l10n.photoAdded
                            : l10n.addProofPhoto,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              if (_order.status == OrderStatus.assigned ||
                  _order.status == OrderStatus.accepted ||
                  _order.status == OrderStatus.placed)
                AppButton(
                  text: l10n.markPickedUp,
                  icon: Icons.inventory_2_outlined,
                  backgroundColor: _orderColor,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceStatus(OrderStatus.pickedUp),
                )
              else if (_order.status == OrderStatus.pickedUp)
                AppButton(
                  text: l10n.startDelivery,
                  icon: Icons.two_wheeler_rounded,
                  backgroundColor: _orderColor,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceStatus(OrderStatus.onTheWay),
                )
              else if (_order.status == OrderStatus.onTheWay)
                AppButton(
                  text: l10n.confirmDelivery,
                  icon: Icons.check_circle_outline_rounded,
                  backgroundColor: AppColors.success,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceStatus(OrderStatus.delivered),
                ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _PinBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isFilled;

  const _PinBadge({
    required this.icon,
    required this.color,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(45), blurRadius: 6),
        ],
      ),
      child: Icon(
        icon,
        size: 18.sp,
        color: isFilled ? Colors.white : color,
      ),
    );
  }
}

class _LocationDetailRow extends StatelessWidget {
  final String label;
  final String name;
  final String address;
  final String phone;
  final Color dotColor;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  const _LocationDetailRow({
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
    required this.dotColor,
    required this.onCall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4.h),
          width: 11.w,
          height: 11.w,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Call',
          onPressed: onCall,
          icon: Icon(Icons.call_rounded, color: AppColors.success, size: 20.sp),
        ),
        IconButton(
          tooltip: 'Directions',
          onPressed: onNavigate,
          icon: Icon(Icons.directions_rounded, color: AppColors.info, size: 20.sp),
        ),
      ],
    );
  }
}
