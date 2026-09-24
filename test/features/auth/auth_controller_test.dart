import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/token_repository.dart';
import 'package:frontend/core/notifications/push_notification_service.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/features/auth/data/datasources/auth_api.dart';
import 'package:frontend/features/auth/data/models/auth_response_dto.dart';
import 'package:frontend/features/auth/data/models/refresh_request_dto.dart';
import 'package:frontend/features/auth/data/models/user_profile_update_request_dto.dart';

UserDto _userDto({String? farmName}) => UserDto(
  id: 5,
  phoneNumber: '+77777777777',
  email: null,
  firstName: 'Иван',
  lastName: 'Иванов',
  farmName: farmName,
  city: null,
  region: null,
  roles: const ['ROLE_USER'],
  phoneVerified: false,
);

class _Api extends Fake implements AuthApi {
  String? requestedFarmName;
  Object? updateError;
  // The backend has no GET /users/profile yet.
  Object profileError = DioException(
    requestOptions: RequestOptions(path: '/users/profile'),
    response: Response<dynamic>(
      requestOptions: RequestOptions(path: '/users/profile'),
      statusCode: 405,
    ),
  );

  @override
  Future<UserDto> updateProfile(UserProfileUpdateRequestDto body) async {
    requestedFarmName = body.farmName;
    if (updateError != null) throw updateError!;
    return _userDto(farmName: body.farmName);
  }

  @override
  Future<UserDto> getProfile() async => throw profileError;

  @override
  Future<AuthResponseDto> refresh(RefreshRequestDto body) async =>
      AuthResponseDto(
        accessToken: 'access',
        refreshToken: 'refresh',
        tokenType: 'Bearer',
        expiresIn: 900,
        user: _userDto(),
      );
}

class _Tokens extends Fake implements TokenRepository {
  @override
  Future<String?> get accessToken async => 'stored-access';

  @override
  Future<String?> get refreshToken async => 'stored-refresh';

  @override
  Future<String?> get tokenType async => 'Bearer';

  @override
  Future<void> save({
    required String access,
    required String refresh,
    required String type,
  }) async {}
}

class _Push extends Fake implements PushNotificationService {
  int registrations = 0;

  @override
  Future<void> registerCurrentToken() async => registrations++;
}

void main() {
  late _Api api;
  late _Push push;
  late AuthController controller;

  setUp(() {
    api = _Api();
    push = _Push();
    controller = AuthController(api, _Tokens(), push);
  });

  tearDown(() => controller.dispose());

  test('renames the farm without a loaded profile', () async {
    expect(controller.state.user, isNull);

    await controller.updateFarmName('Ромашка');

    expect(api.requestedFarmName, 'Ромашка');
    expect(controller.state.user?.farmName, 'Ромашка');
    expect(controller.state.error, isNull);
    expect(controller.state.isLoading, isFalse);
  });

  test('keeps the backend message when renaming fails', () async {
    api.updateError = DioException(
      requestOptions: RequestOptions(path: '/users/profile'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/users/profile'),
        statusCode: 400,
        data: {'message': 'Название занято'},
      ),
    );

    await controller.updateFarmName('Ромашка');

    expect(controller.state.error, 'Название занято');
    expect(controller.state.isLoading, isFalse);
  });

  test('a failing profile request still restores the session', () async {
    await controller.refreshToken();

    expect(controller.state.tokens?.accessToken, 'access');
    expect(controller.state.user, isNull);
    expect(push.registrations, 1);
  });
}
