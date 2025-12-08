import 'package:frontend/core/network/dio_client.dart';
import '../models/login_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/refresh_request_dto.dart';
import '../models/logout_request_dto.dart';
import '../models/auth_response_dto.dart';

class AuthApi {
  final DioClient _client;

  AuthApi(this._client);

  Future<AuthResponseDto> login(LoginRequestDto body) async {
    final res = await _client.post(
      '/auth/login',
      data: body.toJson(),
    );
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponseDto> register(RegisterRequestDto body) async {
    final res = await _client.post(
      '/auth/register',
      data: body.toJson(),
    );
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponseDto> refresh(RefreshRequestDto body) async {
    final res = await _client.post(
      '/auth/refresh',
      data: body.toJson(),
    );
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout(LogoutRequestDto body) async {
    await _client.post(
      '/auth/logout',
      data: body.toJson(),
    );
  }
}
