import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PhotoTypeSelectionScreen extends StatelessWidget {
  final void Function(bool isCollage) onSelection;
  const PhotoTypeSelectionScreen({required this.onSelection, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/make_portrait_logo.png', width: 32, height: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Select Photo Type',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: kBannerGold,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: kCream,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Text(
              'What do you want to create?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => onSelection(false),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/single_passport.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => onSelection(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Single Passport Photo',
                      style: TextStyle(color: kCream, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => onSelection(true),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/collage_passport.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => onSelection(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Collage of Passport Photos',
                      style: TextStyle(color: kCream, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
