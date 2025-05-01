// Add these to pubspec.yaml (latest stable versions as of May 2025)
// dependencies:
//   provider: ^6.1.1
//   jwt_decoder: ^2.0.1
//   shared_preferences: ^2.2.2

import 'package:flutter/foundation.dart';

/// Global singleton that holds the signed-in user _and_ the current JWT.
/// Any widget / service can read AuthState().user / token or add a listener.
class AuthState extends ChangeNotifier {
  /* ───────────────────────── singleton ───────────────────────── */
  static final AuthState _i = AuthState._internal();
  factory AuthState() => _i;
  AuthState._internal();

  /* ───────────────────────── data ───────────────────────── */
  Map<String, dynamic>? _user;
  String? _token;
  DateTime? _tokenExpiry;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  bool get isLoggedIn => _user != null && _token != null;
  bool get isTokenExpired =>
      _tokenExpiry == null ? true : DateTime.now().isAfter(_tokenExpiry!);

  /* ───────────────────────── setters ───────────────────────── */

  /// Call once after login / refresh so everything is in-sync.
  void setSession({
    required Map<String, dynamic>? user,
    required String? token,
    required DateTime? expiry,
  }) {
    _user = user;
    _token = token;
    _tokenExpiry = expiry;
    notifyListeners();
  }

  /// Update only the user (e.g. profile edit).
  void setUser(Map<String, dynamic>? u) {
    _user = u;
    notifyListeners();
  }

  /// Refresh just the token without touching the user.
  void setToken(String? t, DateTime? expiry) {
    _token = t;
    _tokenExpiry = expiry;
    notifyListeners();
  }

  void logout() => setSession(user: null, token: null, expiry: null);
}
