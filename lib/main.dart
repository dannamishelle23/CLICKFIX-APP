import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_screen.dart';
import 'auth/reset_password_screen.dart';
import 'core/app_colors.dart';
import 'splash/splash_screen.dart';

bool isManualLogin = false;
String? pendingConfirmationMessage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    debug: false,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
        ),
      ),
      home: SplashScreen(nextScreen: const AuthGate()),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showResetPassword = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() => _showResetPassword = true);
        return;
      }

      if (event == AuthChangeEvent.signedIn) {
        if (!isManualLogin) {
          pendingConfirmationMessage =
              'Cuenta confirmada. Por favor inicia sesion.';
          await Future.delayed(const Duration(seconds: 2));
          await Supabase.instance.client.auth.signOut();
        }
        isManualLogin = false;
        if (mounted) setState(() {});
      }

      if (event == AuthChangeEvent.signedOut) {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResetPassword) {
      return const ResetPasswordScreen();
    }

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      final msg = pendingConfirmationMessage;
      pendingConfirmationMessage = null;
      return LoginScreen(confirmationMessage: msg);
    }

    return const _HomeScreen();
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final rol = metadata?['rol'] ?? 'cliente';
    final nombre = metadata?['nombre_completo'] ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClickFix'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenido, $nombre!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Rol: ${rol.toString().toUpperCase()}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Text(
                  'El dashboard completo se implementara en la siguiente fase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
