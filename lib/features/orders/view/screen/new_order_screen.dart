import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/orders/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/orders/bloc/new_order_event.dart';
import 'package:delivery_app/features/orders/bloc/new_order_state.dart';
import 'package:delivery_app/features/orders/view/widgets/location_picker_map.dart';
import 'package:delivery_app/features/orders/view/widgets/order_item_tile.dart';
import 'package:delivery_app/features/orders/view/widgets/add_item_dialog.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/input_validators.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/app_text_field.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _pickupNameController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _pickupAddressController = TextEditingController();

  final _dropoffNameController = TextEditingController();
  final _dropoffPhoneController = TextEditingController();
  final _dropoffAddressController = TextEditingController();

  final _riderNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<NewOrderBloc>().add(SetActivePinTabEvent(_tabController.index));
      }
    });

    // Prefill some helpful default mock info
    final state = context.read<NewOrderBloc>().state;
    _pickupNameController.text = state.pickupName.isNotEmpty ? state.pickupName : 'Apex Distribution Hub';
    _pickupPhoneController.text = state.pickupPhone.isNotEmpty ? state.pickupPhone : '+1 555-0101';
    _pickupAddressController.text = state.pickupAddress.isNotEmpty ? state.pickupAddress : '42 Warehouse Ave';

    _dropoffNameController.text = state.dropoffName.isNotEmpty ? state.dropoffName : 'Receiver Contact';
    _dropoffPhoneController.text = state.dropoffPhone.isNotEmpty ? state.dropoffPhone : '+1 555-0999';
    _dropoffAddressController.text = state.dropoffAddress.isNotEmpty ? state.dropoffAddress : '74 Sunset Blvd';

    _updatePickupBloc();
    _updateDropoffBloc();

    // Proactively request location permission and fetch customer's current GPS location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewOrderBloc>().add(
            const FetchCurrentCustomerLocationEvent(updatePickupCoordinates: true),
          );
    });
  }

  void _updatePickupBloc() {
    context.read<NewOrderBloc>().add(
          UpdatePickupDetailsEvent(
            name: _pickupNameController.text,
            phone: _pickupPhoneController.text,
            address: _pickupAddressController.text,
          ),
        );
  }

  void _updateDropoffBloc() {
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
    _riderNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Delivery Order'),
        elevation: 0,
      ),
      body: BlocConsumer<NewOrderBloc, NewOrderState>(
        listener: (context, state) {
          if (state.locationPermissionError != null && state.locationPermissionError!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.locationPermissionError!),
                backgroundColor: AppColors.warning,
                action: SnackBarAction(
                  label: 'Retry GPS',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<NewOrderBloc>().add(
                          const FetchCurrentCustomerLocationEvent(updatePickupCoordinates: true),
                        );
                  },
                ),
              ),
            );
          }
          if (state.status == NewOrderSubmissionStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == NewOrderSubmissionStatus.success && state.createdOrder != null) {
            final order = state.createdOrder!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order ${order.orderNumber} placed! Assigning nearest rider...'),
                backgroundColor: AppColors.success,
              ),
            );
            // Navigate to Tracking
            context.goNamed(
              RouteNames.trackOrder,
              queryParameters: {'orderId': order.id},
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MAP SECTION WITH TABS
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.location_on),
                            text: '1. Pickup Pin Point',
                          ),
                          Tab(
                            icon: Icon(Icons.flag),
                            text: '2. Drop-off Pin Point',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 240,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(), // prevent swipe conflict with map gestures
                          children: [
                            LocationPickerMap(
                              key: const ValueKey('pickup_map'),
                              latitude: state.pickupLatitude,
                              longitude: state.pickupLongitude,
                              customerLatitude: state.customerLatitude,
                              customerLongitude: state.customerLongitude,
                              isLocating: state.isLocatingCustomer,
                              isPickup: true,
                              onLocationChanged: (lat, lng) {
                                context.read<NewOrderBloc>().add(
                                      UpdatePickupCoordinatesEvent(latitude: lat, longitude: lng),
                                    );
                              },
                              onGpsPressed: () {
                                context.read<NewOrderBloc>().add(
                                      const FetchCurrentCustomerLocationEvent(updatePickupCoordinates: true),
                                    );
                              },
                            ),
                            LocationPickerMap(
                              key: const ValueKey('dropoff_map'),
                              latitude: state.dropoffLatitude,
                              longitude: state.dropoffLongitude,
                              customerLatitude: state.customerLatitude,
                              customerLongitude: state.customerLongitude,
                              isLocating: state.isLocatingCustomer,
                              isPickup: false,
                              onLocationChanged: (lat, lng) {
                                context.read<NewOrderBloc>().add(
                                      UpdateDropoffCoordinatesEvent(latitude: lat, longitude: lng),
                                    );
                              },
                              onGpsPressed: () {
                                context.read<NewOrderBloc>().add(
                                      const FetchCurrentCustomerLocationEvent(updatePickupCoordinates: false),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // PICKUP DETAILS CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.trip_origin, color: AppColors.primaryLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pickup Information',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _pickupNameController,
                          label: 'Sender Name',
                          hint: 'Contact person or business',
                          validator: (v) => InputValidators.validateRequired(v, 'Pickup sender name'),
                          onChanged: (_) => _updatePickupBloc(),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _pickupPhoneController,
                          label: 'Sender Phone',
                          hint: '+1 555-0101',
                          keyboardType: TextInputType.phone,
                          validator: InputValidators.validatePhone,
                          onChanged: (_) => _updatePickupBloc(),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _pickupAddressController,
                          label: 'Pickup Address (Optional)',
                          hint: 'Street, building, suite',
                          onChanged: (_) => _updatePickupBloc(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // DROP-OFF DETAILS CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.pin_drop, color: AppColors.success, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Drop-off Destination Details',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _dropoffNameController,
                          label: 'Recipient Name',
                          hint: 'Full name',
                          validator: (v) => InputValidators.validateRequired(v, 'Recipient name'),
                          onChanged: (_) => _updateDropoffBloc(),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _dropoffPhoneController,
                          label: 'Recipient Phone',
                          hint: '+1 555-0999',
                          keyboardType: TextInputType.phone,
                          validator: InputValidators.validatePhone,
                          onChanged: (_) => _updateDropoffBloc(),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _dropoffAddressController,
                          label: 'Drop-off Address (Optional)',
                          hint: 'Street, apartment, floor',
                          onChanged: (_) => _updateDropoffBloc(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PACKAGE ITEMS CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.inventory_2, color: AppColors.accent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Delivery Items',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AddItemDialog(
                                    onSave: (name, qty) {
                                      context.read<NewOrderBloc>().add(
                                            AddOrderItemEvent(name: name, quantity: qty),
                                          );
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Item'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (state.items.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            alignment: Alignment.center,
                            child: const Text(
                              'No items added yet. Tap "+ Add Item" above.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return OrderItemTile(
                                item: item,
                                onEdit: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddItemDialog(
                                      initialItem: item,
                                      onSave: (name, qty) {
                                        context.read<NewOrderBloc>().add(
                                              EditOrderItemEvent(itemId: item.id, name: name, quantity: qty),
                                            );
                                      },
                                    ),
                                  );
                                },
                                onDelete: () {
                                  context.read<NewOrderBloc>().add(RemoveOrderItemEvent(item.id));
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // RIDER NOTE CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note, color: AppColors.textSecondary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Note for Rider (Optional)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _riderNoteController,
                          label: '',
                          hint: 'e.g. "Please call before arriving at the gate"',
                          maxLines: 2,
                          onChanged: (val) {
                            context.read<NewOrderBloc>().add(UpdateRiderNoteEvent(val));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // SUBMIT BUTTON
                AppButton(
                  text: 'Place Order',
                  icon: Icons.check_circle_outline,
                  isLoading: state.isSubmitting,
                  onPressed: () {
                    _updatePickupBloc();
                    _updateDropoffBloc();
                    context.read<NewOrderBloc>().add(const SubmitOrderEvent());
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
