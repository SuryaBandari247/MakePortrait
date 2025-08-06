import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'photo_resize_home_page.dart';
import '../main.dart';

class SplashScreenLauncher extends StatefulWidget {
  const SplashScreenLauncher({super.key});
  @override
  State<SplashScreenLauncher> createState() => _SplashScreenLauncherState();
}

class _SplashScreenLauncherState extends State<SplashScreenLauncher> {
  bool _showSplash = true;

  // Called when splash animation finishes
  void _onSplashFinish() => setState(() => _showSplash = false);

  @override
  Widget build(BuildContext context) => _showSplash
      ? SplashScreen(onFinish: _onSplashFinish)
      : const GradientBackground(child: PhotoResizeHomePage());
}
