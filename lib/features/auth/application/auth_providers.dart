import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/core/storage/storage_providers.dart';
import '../data/datasources/auth_api.dart';
import 'auth_controller.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthApi(dioClient);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final api = ref.read(authApiProvider);
  final storage = ref.read(tokenStorageProvider);
  return AuthController(api, storage);
});
