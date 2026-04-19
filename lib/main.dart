import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/user/book_service_screen.dart';
import 'screens/user/my_bookings_screen.dart';
import 'screens/user/provider_details_screen.dart';
import 'screens/user/provider_list_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/provider/provider_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LocalServiceFinderApp());
}

class LocalServiceFinderApp extends StatelessWidget {
  const LocalServiceFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: Consumer<ThemeController>(
        builder: (_, themeCtrl, __) {
          return MaterialApp(
            title: 'LocalService Finder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(themeCtrl.primaryColor),
            darkTheme: AppTheme.darkTheme(themeCtrl.primaryColor),
            themeMode: themeCtrl.themeMode,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.signup: (_) => const SignupScreen(),
              AppRoutes.userHome: (_) => const UserHomeScreen(),
              AppRoutes.providerList: (_) => const ProviderListScreen(),
              AppRoutes.providerDetails: (_) => const ProviderDetailsScreen(),
              AppRoutes.bookService: (_) => const BookServiceScreen(),
              AppRoutes.myBookings: (_) => const MyBookingsScreen(),
              AppRoutes.providerDashboard: (_) =>
                  const ProviderDashboardScreen(),
              AppRoutes.settings: (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
