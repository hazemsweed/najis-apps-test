import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  DateTime? _tokenExpiry;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  bool get isLoggedIn => _user != null && _token != null;
  bool get isTokenExpired =>
      _tokenExpiry == null ? true : DateTime.now().isAfter(_tokenExpiry!);

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

  void setUser(Map<String, dynamic>? u) {
    _user = u;
    notifyListeners();
  }

  void setToken(String? t, DateTime? expiry) {
    _token = t;
    _tokenExpiry = expiry;
    notifyListeners();
  }

  void logout() => setSession(user: null, token: null, expiry: null);
}
