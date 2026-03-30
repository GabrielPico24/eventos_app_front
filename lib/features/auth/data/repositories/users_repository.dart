import 'package:event_app/features/auth/data/datasource/users_remote_datasource.dart';
import 'package:event_app/features/auth/data/models/user_model.dart';

class UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepository({required this.remoteDataSource});

  Future<List<UserModel>> getUsers({
    required String token,
  }) {
    return remoteDataSource.getUsers(token: token);
  }

  Future<UserModel> createUser({
    required String token,
    required String name,
    required String email,
    required String password,
    required String role,
    required bool isActive,
  }) {
    return remoteDataSource.createUser(
      token: token,
      name: name,
      email: email,
      password: password,
      role: role,
      isActive: isActive,
    );
  }

  Future<UserModel> updateUser({
    required String token,
    required String id,
    required String name,
    required String email,
    required String password,
    required String role,
    required bool isActive,
  }) {
    return remoteDataSource.updateUser(
      token: token,
      id: id,
      name: name,
      email: email,
      password: password,
      role: role,
      isActive: isActive,
    );
  }
  Future<void> deleteUser({
  required String token,
  required String id,
}) {
  return remoteDataSource.deleteUser(
    token: token,
    id: id,
  );
}
}