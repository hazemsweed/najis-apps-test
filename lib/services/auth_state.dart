import 'package:flutter/foundation.dart';

/// Global singleton that holds the signed-in user (or null).
/// Any widget can call AuthState().user or add a listener.
class AuthState extends ChangeNotifier {
  static final AuthState _i = AuthState._internal();
  factory AuthState() => _i;
  AuthState._internal();

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(Map<String, dynamic>? u) {
    _user = u;
    notifyListeners();
  }

  void logout() => setUser(null);
}
