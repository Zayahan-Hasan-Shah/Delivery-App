import 'package:delivery_app/features/tracking/domain/entities/tracking_data_entity.dart';

class TrackingDataModel extends TrackingDataEntity {
  const TrackingDataModel({
    required super.order,
    super.riderLocation,
    super.etaMinutes,
  });
}
