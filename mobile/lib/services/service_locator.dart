import 'api_client.dart';
import 'auth_service.dart';

/// Minimal global service locator to avoid a larger refactor now.
/// Replace with Provider/GetIt/Riverpod later as needed.
class ServiceLocator {
  static late ApiClient apiClient;
  static late AuthService authService;
}
