import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // Set this to true and put your computer's Wi-Fi IP if running on a real phone
  static const bool usePhysicalPhone = false;
  static const String _customLanIp = '192.168.1.100';

  // FastAPI development port
  static const String _port = '8000';

  /// Automatically picks the correct base URL depending on platform
  static String get baseUrl {
    if (usePhysicalPhone) {
      return 'http://$_customLanIp:$_port';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:$_port';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // 10.0.2.2 is Android Emulator's alias to host PC localhost
        return 'http://10.0.2.2:$_port';
      case TargetPlatform.iOS:
      default:
        return 'http://127.0.0.1:$_port';
    }
  }

  // --- API Endpoints matching FastAPI handoff ---
  static const String health = '/health';

  // Auth routes
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Reports routes
  static const String reports = '/reports';
  static String reportDetail(String id) => '/reports/$id';
  static String updateReportStatus(String id) => '/reports/$id/status';

  // Admin routes
  static const String adminPersonnel = '/admin/personnel';

  // Request timeout
  static const Duration timeout = Duration(seconds: 15);
}