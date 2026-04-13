import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/database/database_helper.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/pos/providers/pos_provider.dart';
import 'features/closing/providers/closing_provider.dart'; 
import 'features/auth/screens/login_screen.dart';
import 'features/main_wrapper.dart'; // Diganti ke Wrapper Mobile

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi awal database lokal (Lewati jika di web)
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => ClosingProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkInitSession();
  }

  Future<void> _checkInitSession() async {
    // Mengecek apakah sudah login (ada token)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkSession();
    
    if (mounted) {
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'UMKM POS Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Logic Redirection (Memaksa ke LoginScreen jika token tidak ada)
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainWrapper();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
