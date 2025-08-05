import 'package:flutter/material.dart';
import 'screens/photo_resize_home_page.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen_launcher.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Print to console for debugging
    print('[GlobalError] ${details.exceptionAsString()}');
    if (details.stack != null) {
      print(details.stack);
    }
  };
  runApp(const PhotoResizeApp());
}

class PhotoResizeApp extends StatelessWidget {
  const PhotoResizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use centralized color palette from app_colors.dart
    const red = Color(0xFFF20505); // #F20505
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: kPrimaryGreen,
      onPrimary: kCream,
      secondary: red,
      onSecondary: Colors.white,
      error: red,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    );
    return MaterialApp(
      title: 'Photo Resize App',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bannerGold,
          elevation: 0,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Color(0x22000000),
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(AppColors.primaryGreen),
            foregroundColor: WidgetStatePropertyAll(AppColors.cream),
            overlayColor: WidgetStatePropertyAll(Color(0x338BB174)),
            textStyle: WidgetStatePropertyAll(
              TextStyle(color: AppColors.cream),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            foregroundColor: WidgetStatePropertyAll(Colors.black),
            side: WidgetStatePropertyAll(
              BorderSide(color: AppColors.primaryGreen),
            ),
            overlayColor: WidgetStatePropertyAll(Color(0x338BB174)),
            textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black)),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryGreen),
          ),
          border: OutlineInputBorder(),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryGreen,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.primaryGreen,
          contentTextStyle: TextStyle(color: AppColors.cream),
        ),
      ),
      home: SplashScreenLauncher(),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF49A6E9), // Light blue at top
            Colors.white, // White at bottom
          ],
        ),
      ),
      child: child,
    );
  }
}
