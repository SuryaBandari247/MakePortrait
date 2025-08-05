import 'package:flutter/material.dart';
import 'screens/photo_resize_home_page.dart';

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
    const lightBlue = Color(0xFF49A6E9); // #49A6E9
    const blueOverlay = Color(0x3349A6E9); // 20% opacity for overlays
    const red = Color(0xFFF20505); // #F20505
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightBlue,
      onPrimary: Colors.white,
      secondary: red,
      onSecondary: Colors.white,
      error: red,
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
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
          backgroundColor: lightBlue,
          elevation: 0,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Color(0x2249A6E9),
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(lightBlue),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            overlayColor: MaterialStatePropertyAll(blueOverlay),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(lightBlue),
            side: MaterialStatePropertyAll(BorderSide(color: lightBlue)),
            overlayColor: MaterialStatePropertyAll(blueOverlay),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: lightBlue),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightBlue),
          ),
          border: OutlineInputBorder(),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: lightBlue,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: lightBlue,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const GradientBackground(child: PhotoResizeHomePage()),
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
