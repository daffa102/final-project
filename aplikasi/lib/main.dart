import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Consumer, Provider, ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/database/app_database.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/pos/providers/pos_provider.dart';
import 'features/closing/providers/closing_provider.dart'; 
import 'features/finance/providers/finance_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/api/sync_provider.dart';
import 'core/services/notification_service.dart';
import 'core/navigation/navigation_provider.dart';
import 'core/widgets/splash_screen.dart';
import 'core/widgets/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  final database = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('firstLaunch') ?? true;

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          Provider<AppDatabase>(create: (_) => database),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => PosProvider(database: context.read<AppDatabase>())),
          ChangeNotifierProvider(create: (context) => ClosingProvider(database: context.read<AppDatabase>())),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => SyncProvider(database: context.read<AppDatabase>())),
          ChangeNotifierProvider(create: (context) => FinanceProvider(database: context.read<AppDatabase>())),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: MyApp(isFirstLaunch: isFirstLaunch),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isFirstLaunch});
  final bool isFirstLaunch;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Kash POS',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              // Home ditentukan oleh status launch pertama
              home: isFirstLaunch ? const OnboardingScreen() : const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
