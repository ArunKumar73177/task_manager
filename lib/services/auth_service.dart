import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// auth_service.dart
//
// Single-responsibility service that owns all auth token operations.
// The UI and providers never touch FlutterSecureStorage directly — they
// only call methods on this class, so swapping to a real token issuer
// later requires changes here only.
//
// Security notes:
//   • flutter_secure_storage writes to:
//       iOS/macOS  → Keychain
//       Android    → EncryptedSharedPreferences (AES-256 via Jetpack Security)
//       Windows    → DPAPI
//       Linux      → libsecret / keyring
//   • The token is never logged or exposed in plain text.
//   • All methods are async — never blocks the UI thread.
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  // ── Storage instance ───────────────────────────────────────────────────────

  /// Android options: encryptedSharedPreferences = true enforces AES-256
  /// encryption on top of the OS keystore — the most secure Android option.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Storage key ────────────────────────────────────────────────────────────

  /// Namespaced key avoids collisions if other secure values are stored later.
  static const _kAuthTokenKey = 'task_manager.auth_token';

  // ── Dummy token ────────────────────────────────────────────────────────────

  /// In a real app this would be a JWT or session token returned by your API.
  /// The format mimics a Bearer token so the shape is realistic.
  static const _kDummyToken = 'tm_dummy_token_v1_do_not_use_in_production';

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Simulates a successful login by persisting a dummy auth token.
  ///
  /// In production: call your API, receive a real token, then call
  /// [_storage.write] with the server-issued value.
  Future<void> saveToken() async {
    await _storage.write(key: _kAuthTokenKey, value: _kDummyToken);
  }

  /// Returns the stored token, or `null` if the user is not logged in.
  Future<String?> getToken() async {
    return _storage.read(key: _kAuthTokenKey);
  }

  /// Returns `true` if a valid token is present in secure storage.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Deletes the stored token, effectively logging the user out.
  Future<void> clearToken() async {
    await _storage.delete(key: _kAuthTokenKey);
  }
}