import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class UpdateRiderOnlineStatusUseCase {
  final AuthRepository repository;

  const UpdateRiderOnlineStatusUseCase(this.repository);

  Future<UserEntity> call(bool isOnline) {
    return repository.updateRiderOnlineStatus(isOnline);
  }
}
