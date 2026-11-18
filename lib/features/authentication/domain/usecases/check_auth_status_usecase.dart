import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  const CheckAuthStatusUseCase(this.repository);

  Future<UserEntity?> call() => repository.getStoredSession();
}
