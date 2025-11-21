// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ravera/core/supabase_config.dart';
import 'package:ravera/features/auth/bloc/auth_bloc.dart';
import 'package:ravera/features/auth/service/auth_service.dart';
import 'package:ravera/features/auth/views/login_screen.dart';
import 'package:ravera/features/home/bloc/user_bloc.dart';
import 'package:ravera/features/home/repository/user_profile_repository.dart';
import 'package:ravera/features/home/views/home_screen_navigation.dart';
import 'package:ravera/features/portfolio/bloc/investment_bloc.dart';
import 'package:ravera/features/portfolio/service/coin_dcx_repository.dart';
import 'package:ravera/features/usage/bloc/usage_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(AuthService())..add(AuthInitialize()),
        ),
        BlocProvider<UsageBloc>(create: (_) => UsageBloc()),
        BlocProvider<UserProfileBloc>(
          create: (_) => UserProfileBloc(
            repository: UserProfileRepository(
              supabase: Supabase.instance.client,
            ),
          ),
        ),
        BlocProvider<InvestmentBloc>(
          create: (_) => InvestmentBloc(repository: CoinDCXRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.black,
          onSecondary: Colors.white,
          tertiary: Colors.black,
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.openSansTextTheme(
          ThemeData.light().textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.openSans(fontWeight: FontWeight.bold),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.openSans(color: Colors.black),
          hintStyle: GoogleFonts.openSans(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthSuccess) {
          return const HomeScreenNavigation(); // <-- NOW USING NAVIGATION
        } else if (state is AuthOtpSent || state is RegistrationSuccess) {
          return const LoginScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
