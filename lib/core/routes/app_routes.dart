import 'package:get/get.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/worker/screens/worker_screen.dart';
class AppRoutes {
  static const String login = '/login';
  static const String adminDashboard = '/admin-dashboard';
  static const String workerDashboard = '/worker-dashboard';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboard(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: workerDashboard,
      page: () => const WorkerDashboard(),
      transition: Transition.fadeIn,
    ),
  ];
}