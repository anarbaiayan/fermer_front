import 'dart:async';

/// Serializes token updates and retries transient failures while the app is active.
class PushTokenSync {
  PushTokenSync({
    required this.isReady,
    required this.getToken,
    required this.storeToken,
    required this.hasSession,
    required this.registerToken,
    this.shouldRetry,
    this.onError,
  });

  final Future<bool> Function() isReady;
  final Future<String?> Function() getToken;
  final Future<void> Function(String) storeToken;
  final Future<bool> Function() hasSession;
  final Future<void> Function(String) registerToken;
  final bool Function(Object)? shouldRetry;
  final void Function(Object)? onError;

  static const _delays = [2, 4, 8, 16, 32, 60];
  Timer? _retry;
  Future<void>? _running;
  String? _latestToken;
  bool _enabled = false;
  bool _paused = false;
  bool _disposed = false;
  bool _requested = false;
  int _generation = 0;
  int _attempt = 0;

  bool _isCurrent(int generation) =>
      !_disposed && _enabled && generation == _generation;

  Future<void> start() {
    if (_disposed) return Future.value();
    _enabled = true;
    return synchronize();
  }

  Future<void> synchronize({String? token}) {
    if (_disposed || !_enabled) return Future.value();
    if (token != null && token.isNotEmpty) _latestToken = token;
    if (_paused) return Future.value();
    _retry?.cancel();
    _retry = null;
    if (_running != null) {
      _requested = true;
      return _running!;
    }
    final generation = _generation;
    return _running = _synchronize(generation).whenComplete(() {
      _running = null;
      if (_requested && _enabled && !_paused && !_disposed) {
        _requested = false;
        unawaited(synchronize());
      }
    });
  }

  Future<void> _synchronize(int generation) async {
    try {
      final ready = await isReady();
      if (!_isCurrent(generation)) return;
      if (!ready) {
        _scheduleRetry(generation);
        return;
      }

      final token = _latestToken ?? await getToken();
      if (!_isCurrent(generation)) return;
      if (token == null || token.isEmpty) {
        _scheduleRetry(generation);
        return;
      }
      await storeToken(token);
      if (!_isCurrent(generation)) return;
      final authenticated = await hasSession();
      if (!_isCurrent(generation)) return;
      if (authenticated) await registerToken(token);
      if (!_isCurrent(generation)) return;
      _attempt = 0;
    } catch (error) {
      if (!_isCurrent(generation)) return;
      onError?.call(error);
      if (shouldRetry?.call(error) ?? true) _scheduleRetry(generation);
    }
  }

  void _scheduleRetry(int generation) {
    if (!_isCurrent(generation) || _paused || _retry != null) return;
    final seconds = _delays[_attempt];
    if (_attempt < _delays.length - 1) _attempt++;
    _retry = Timer(Duration(seconds: seconds), () {
      _retry = null;
      if (_isCurrent(generation)) unawaited(synchronize());
    });
  }

  void pause() {
    _paused = true;
    _retry?.cancel();
    _retry = null;
  }

  Future<void> resume() {
    _paused = false;
    _attempt = 0;
    return synchronize();
  }

  void stop() {
    _enabled = false;
    _generation++;
    _requested = false;
    _latestToken = null;
    _attempt = 0;
    _retry?.cancel();
    _retry = null;
  }

  void dispose() {
    stop();
    _disposed = true;
  }
}
