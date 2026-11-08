import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/resident/resident_dashboard_screen.dart';
import '../../features/personnel/personnel_dashboard_screen.dart';
import '../../features/administrator/admin_dashboard_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String residentDashboard = '/resident';
  static const String personnelDashboard = '/personnel';
  static const String adminDashboard = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case residentDashboard:
        final user = settings.arguments as User?;
        return MaterialPageRoute(builder: (_) => ResidentDashboardScreen(user: user));

      case personnelDashboard:
        final user = settings.arguments as User?;
        return MaterialPageRoute(builder: (_) => PersonnelDashboardScreen(user: user));

      case adminDashboard:
        final adminEmail = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => AdminDashboardScreen(adminEmail: adminEmail));

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  /// Helper to route based on UserRole
  static void navigateByRole(BuildContext context, User user) {
    switch (user.role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, adminDashboard, arguments: user.email);
        break;
      case UserRole.personnel:
        Navigator.pushReplacementNamed(context, personnelDashboard, arguments: user);
        break;
      case UserRole.resident:
        Navigator.pushReplacementNamed(context, residentDashboard, arguments: user);
        break;
    }
  }
}
