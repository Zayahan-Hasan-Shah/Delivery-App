import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_event.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_state.dart';
import 'package:delivery_app/features/rider/service/rider_service.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class RiderOrdersBloc extends Bloc<RiderOrdersEvent, RiderOrdersState> {
  final RiderService riderService;

  RiderOrdersBloc({required this.riderService}) : super(const RiderOrdersState()) {
    on<LoadRiderOrdersEvent>(_onLoadOrders);
    on<FilterRiderOrdersEvent>(_onFilterOrders);
    on<UpdateRiderOrderStatusEvent>(_onUpdateStatus);
  }

  Future<void> _onLoadOrders(
    LoadRiderOrdersEvent event,
    Emitter<RiderOrdersState> emit,
  ) async {
    emit(state.copyWith(status: RiderOrdersStatus.loading));
    try {
      final orders = await riderService.getAssignedOrders();
      final earnings = await riderService.getEarnings();
      final filtered = _applyFilter(orders, state.activeFilter);

      emit(state.copyWith(
        status: RiderOrdersStatus.success,
        allOrders: orders,
        filteredOrders: filtered,
        earnings: earnings,
      ));
    } catch (e, st) {
      AppLogger.error('Failed to load rider orders', error: e, stackTrace: st, tag: 'RiderOrdersBloc');
      emit(state.copyWith(
        status: RiderOrdersStatus.error,
        errorMessage: 'Unable to load assigned orders.',
      ));
    }
  }

  void _onFilterOrders(
    FilterRiderOrdersEvent event,
    Emitter<RiderOrdersState> emit,
  ) {
    final filtered = _applyFilter(state.allOrders, event.statusFilter);
    emit(state.copyWith(
      activeFilter: event.statusFilter,
      filteredOrders: filtered,
    ));
  }

  Future<void> _onUpdateStatus(
    UpdateRiderOrderStatusEvent event,
    Emitter<RiderOrdersState> emit,
  ) async {
    try {
      await riderService.updateDeliveryStatus(event.orderId, event.newStatus);
      add(const LoadRiderOrdersEvent());
    } catch (e, st) {
      AppLogger.error('Status update failed', error: e, stackTrace: st, tag: 'RiderOrdersBloc');
    }
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders, String filter) {
    if (filter == 'All') return orders;
    return orders.where((order) {
      switch (filter) {
        case 'Waiting':
          return order.status == OrderStatus.placed || order.status == OrderStatus.accepted;
        case 'Assigned':
          return order.status == OrderStatus.assigned;
        case 'Picked Up':
          return order.status == OrderStatus.pickedUp;
        case 'On Road':
          return order.status == OrderStatus.onTheWay;
        case 'Delivered':
          return order.status == OrderStatus.delivered;
        default:
          return true;
      }
    }).toList();
  }
}
