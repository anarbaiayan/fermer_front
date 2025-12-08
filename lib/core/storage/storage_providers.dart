import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
