import 'package:event_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_app/features/auth/data/models/login_response_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(email: email, password: password);
  }

  Future<String> refreshToken({
    required String refreshToken,
  }) {
    return remoteDataSource.refreshToken(refreshToken: refreshToken);
  }
}