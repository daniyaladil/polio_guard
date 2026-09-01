import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'core/routes/app_routes.dart';
import 'features/auth/controller/auth_controller.dart';
import 'splash/splash_screen.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PolioGuardApp());
}

class PolioGuardApp extends StatelessWidget {
  const PolioGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Polio Guard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const SplashScreen(),
              transition: Transition.fadeIn,
            ),
            ...AppRoutes.routes,
          ],
          initialBinding: AppBinding(),
        );
      },
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}