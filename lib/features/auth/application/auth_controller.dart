import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/datasources/auth_api.dart';
import '../data/models/login_request_dto.dart';
import '../data/models/register_request_dto.dart';
import '../data/models/refresh_request_dto.dart';
import '../data/models/logout_request_dto.dart';
import '../domain/entities/user.dart';
import '../domain/entities/tokens.dart';
import 'package:frontend/core/storage/token_storage.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final Tokens? tokens;
  final String? error;

  const AuthState({this.isLoading = false, this.user, this.tokens, this.error});

  AuthState copyWith({
    bool? isLoading,
    User? user,
    Tokens? tokens,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      // важно: если передаём error, он перезаписывает старый (в том числе в null)
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthApi _api;
  final TokenStorage _storage;

  AuthController(this._api, this._storage) : super(const AuthState());

  // ---------- helper для извлечения сообщения с бэка ----------
  String _mapDioError(DioException e, {required bool isLogin}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? backendMessage;
    if (data is Map<String, dynamic>) {
      // сначала message, если нет - error
      backendMessage = data['message'] as String?;
      backendMessage ??= data['error'] as String?;
    }

    // если это именно наш кейс 409 с телефоном
    if (!isLogin && status == 409) {
      // если хочешь, можно использовать backendMessage в тултипах/логах,
      // но пользователю лучше показать короткий текст:
      return 'Пользователь с таким номером уже существует';
    }

    // если бэк прислал какое-то сообщение - покажем его
    if (backendMessage != null && backendMessage.isNotEmpty) {
      return backendMessage;
    }

    // fallback по статусам
    if (isLogin) {
      if (status == 401 || status == 403) {
        return 'Неверный номер телефона или пароль';
      }
      if (status == 404) {
        return 'Пользователь с таким номером не найден';
      }
      return 'Не удалось войти. Попробуйте ещё раз';
    } else {
      if (status == 400) {
        return 'Некорректные данные регистрации';
      }
      return 'Не удалось зарегистрироваться. Попробуйте ещё раз';
    }
  }

  // ---------- ВХОД ----------
  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final dto = await _api.login(
        LoginRequestDto(phoneNumber: phoneNumber, password: password),
      );

      final user = User(
        id: dto.user.id,
        phoneNumber: dto.user.phoneNumber,
        email: dto.user.email,
        firstName: dto.user.firstName,
        lastName: dto.user.lastName,
        roles: dto.user.roles,
        phoneVerified: dto.user.phoneVerified,
      );

      final tokens = Tokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        tokenType: dto.tokenType,
        expiresIn: dto.expiresIn,
      );

      state = AuthState(isLoading: false, user: user, tokens: tokens);

      await _storage.saveTokens(tokens);
    } on DioException catch (e) {
      final message = _mapDioError(e, isLogin: true);
      state = state.copyWith(isLoading: false, error: message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось войти. Проверьте подключение к интернету',
      );
    }
  }

  // ---------- РЕГИСТРАЦИЯ ----------
  Future<void> register({
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    required String farmName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final dto = await _api.register(
        RegisterRequestDto(
          phoneNumber: phoneNumber,
          password: password,
          firstName: firstName,
          lastName: lastName,
          farmName: farmName,
        ),
      );

      final user = User(
        id: dto.user.id,
        phoneNumber: dto.user.phoneNumber,
        email: dto.user.email,
        firstName: dto.user.firstName,
        lastName: dto.user.lastName,
        roles: dto.user.roles,
        phoneVerified: dto.user.phoneVerified,
      );

      final tokens = Tokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        tokenType: dto.tokenType,
        expiresIn: dto.expiresIn,
      );

      state = AuthState(isLoading: false, user: user, tokens: tokens);

      await _storage.saveTokens(tokens);
    } on DioException catch (e) {
      final message = _mapDioError(e, isLogin: false);
      state = state.copyWith(isLoading: false, error: message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось зарегистрироваться. Проверьте интернет',
      );
    }
  }

  // ---------- REFRESH ----------
  Future<void> refreshToken() async {
    final currentTokens = state.tokens ?? await _storage.loadTokens();
    if (currentTokens == null) return;

    try {
      final dto = await _api.refresh(
        RefreshRequestDto(refreshToken: currentTokens.refreshToken),
      );

      final tokens = Tokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        tokenType: dto.tokenType,
        expiresIn: dto.expiresIn,
      );

      state = state.copyWith(tokens: tokens);
      await _storage.saveTokens(tokens);
    } catch (_) {
      // можно добавить: state = state.copyWith(error: 'Сессия истекла');
    }
  }

  // ---------- LOGOUT ----------
  Future<void> logout() async {
    final currentTokens = state.tokens ?? await _storage.loadTokens();
    if (currentTokens == null) {
      await _storage.clearTokens();
      state = const AuthState();
      return;
    }

    try {
      await _api.logout(
        LogoutRequestDto(refreshToken: currentTokens.refreshToken),
      );
    } catch (_) {
      // даже если logout на бэке упал - всё равно очистим локально
    }

    await _storage.clearTokens();
    state = const AuthState();
  }
}
