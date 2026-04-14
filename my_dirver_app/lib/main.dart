import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استيراد البروفايدر اللي عملناه
import 'package:my_driver_app/providers/auth_provider.dart';

import 'package:my_driver_app/screens/login_screen.dart';
import 'package:my_driver_app/screens/shared/signup_screen.dart';
import 'package:my_driver_app/screens/rider/rider_home_screen.dart';
import 'package:my_driver_app/screens/rider/trip_completed_screen.dart';
import 'package:my_driver_app/screens/shared/profile_screen.dart';
import 'package:my_driver_app/screens/rider/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://njsxgrexdgekelxwgang.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qc3hncmV4ZGdla2VseHdnYW5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTg2MDAsImV4cCI6MjA5MTY3NDYwMH0.KWCjNDh0PKkc6s-4obLr6TRSW9Lm33zz_PDearf6XBU',
  );

  runApp(
    const ProviderScope(child: EliteApp()),
  );
}

class EliteApp extends ConsumerWidget {
  const EliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة حالة المصادقة من الـ authProvider
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Elite Rider',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xff007AFF),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff007AFF),
          primary: const Color(0xff007AFF),
          secondary: const Color(0xff1C2541),
          surface: Colors.white,
        ),
      ),
      // هنا الـ Logic الاحترافي لتحديد أول شاشة تظهر
      home: authState.when(
        data: (session) {
          if (session != null) {
            return const RiderHomeScreen(); // لو مسجل دخول يفتح الهوم
          } else {
            return const SignupScreen(); // لو مش مسجل يفتح الساين أب
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text("حدث خطأ في الاتصال: $err")),
        ),
      ),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const RiderHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/trip_completed': (context) => const TripCompletedScreen(),
      },
    );
  }
}