import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  static final AuthState _singleton = AuthState._internal();
  factory AuthState() => _singleton;
  AuthState._internal();

  Map<String, dynamic>? _user; // whatever your backend returns

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(Map<String, dynamic>? u) {
    _user = u;
    notifyListeners();
  }

  void logout() => setUser(null);
}
