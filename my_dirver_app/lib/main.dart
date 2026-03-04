import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_driver_app/screens/login_screen.dart';
import 'package:my_driver_app/screens/shared/signup_screen.dart';
import 'package:my_driver_app/screens/rider/rider_home_screen.dart';
import 'package:my_driver_app/screens/rider/trip_completed_screen.dart';
import 'package:my_driver_app/screens/shared/profile_screen.dart';
import 'package:my_driver_app/screens/rider/wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(child: EliteApp()),
  );
}

class EliteApp extends ConsumerWidget {
  const EliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff007AFF),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const RiderHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/trip_completed': (context) => const TripCompletedScreen(),
      },
    );
  }
}
