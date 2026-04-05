class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;

  Future<void> init() async {
    // No-op for now
  }

  Future<bool> login() async {
    // Directly bypass authentication for now
    _isAuthenticated = true;
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => "dummy_token";
}
