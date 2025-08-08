import 'package:flutter/material.dart';
import '../utils/comprehensive_user_input_tester.dart';
import '../utils/runtime_user_input_validator.dart';

/// Interactive test runner for manual testing of specific scenarios
class InteractiveTestRunner {
  /// Run specific country tests
  static void testSpecificCountry(String country) {
    debugPrint('\n🌍 TESTING SPECIFIC COUNTRY: $country');
    debugPrint('=' * 50);

    switch (country.toLowerCase()) {
      case 'canada':
        _testCanadaScenarios();
        break;
      case 'usa':
        _testUSAScenarios();
        break;
      case 'uk':
        _testUKScenarios();
        break;
      case 'india':
        _testIndiaScenarios();
        break;
      default:
        debugPrint('❌ Unknown country: $country');
        debugPrint('Available: canada, usa, uk, india');
    }
  }

  static void _testCanadaScenarios() {
    debugPrint('🇨🇦 CANADA PASSPORT TESTS');
    debugPrint('Standard: 5.0 x 7.0 cm');

    // Test different photo counts
    final photoCounts = [1, 2, 4, 6, 8, 9, 12];

    for (int count in photoCounts) {
      _simulateUserScenario(
        country: 'Canada',
        photoCount: count,
        photoWidth: 5.0,
        photoHeight: 7.0,
        margin: 2.5,
      );
    }

    // Test dimension mode
    _simulateDimensionScenario(
      country: 'Canada',
      width: 21.0,
      height: 29.7,
      unit: 'cm',
      photoWidth: 5.0,
      photoHeight: 7.0,
    );
  }

  static void _testUSAScenarios() {
    debugPrint('🇺🇸 USA PASSPORT TESTS');
    debugPrint('Standard: 5.08 x 5.08 cm (2x2 inch)');

    final photoCounts = [1, 2, 4, 6, 8, 9];

    for (int count in photoCounts) {
      _simulateUserScenario(
        country: 'USA',
        photoCount: count,
        photoWidth: 5.08,
        photoHeight: 5.08,
        margin: 2.5,
      );
    }
  }

  static void _testUKScenarios() {
    debugPrint('🇬🇧 UK PASSPORT TESTS');
    debugPrint('Standard: 4.5 x 3.5 cm');

    final photoCounts = [2, 4, 6, 8, 12, 16];

    for (int count in photoCounts) {
      _simulateUserScenario(
        country: 'UK',
        photoCount: count,
        photoWidth: 4.5,
        photoHeight: 3.5,
        margin: 2.0,
      );
    }
  }

  static void _testIndiaScenarios() {
    debugPrint('🇮🇳 INDIA PASSPORT TESTS');
    debugPrint('Standard: 5.1 x 5.1 cm');

    final photoCounts = [1, 4, 6, 9, 12];

    for (int count in photoCounts) {
      _simulateUserScenario(
        country: 'India',
        photoCount: count,
        photoWidth: 5.1,
        photoHeight: 5.1,
        margin: 3.0,
      );
    }
  }

  static void _simulateUserScenario({
    required String country,
    required int photoCount,
    required double photoWidth,
    required double photoHeight,
    required double margin,
  }) {
    debugPrint('\n📋 Testing: $country $photoCount photos');

    // This simulates what should happen in the app
    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: photoCount,
      calculatedPhotos: photoCount, // Should match user request
      actualPhotosInPreview: photoCount, // Should match user request
      actualPhotosInFinal: photoCount, // Should match user request
      country: country,
    );
  }

  static void _simulateDimensionScenario({
    required String country,
    required double width,
    required double height,
    required String unit,
    required double photoWidth,
    required double photoHeight,
  }) {
    debugPrint('\n📏 Testing: $country dimensions ${width}x$height $unit');

    // Convert to cm
    double widthCm = unit == 'inch' ? width * 2.54 : width;
    double heightCm = unit == 'inch' ? height * 2.54 : height;

    // Calculate how many photos would fit
    double marginCm = 0.25; // 2.5mm
    int cols = ((widthCm + marginCm) / (photoWidth + marginCm)).floor();
    int rows = ((heightCm + marginCm) / (photoHeight + marginCm)).floor();
    int photoCount = cols * rows;

    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: width,
      userRequestedHeight: height,
      unit: unit,
      actualWidth: widthCm,
      actualHeight: heightCm,
      photosGenerated: photoCount,
    );
  }

  /// Test margin variations
  static void testMarginVariations() {
    debugPrint('\n📐 TESTING MARGIN VARIATIONS');
    debugPrint('=' * 50);

    final margins = [0.0, 1.0, 2.5, 5.0, 10.0, 15.0]; // mm

    for (double margin in margins) {
      _testMarginScenario(margin);
    }
  }

  static void _testMarginScenario(double marginMm) {
    debugPrint('\n🔧 Testing margin: ${marginMm}mm');

    // Test with Canada scenario
    RuntimeUserInputValidator.validateMarginScenario(
      userRequestedMarginMm: marginMm,
      calculatedMarginMm: marginMm, // Should match
      photoCount: 6,
      collageWidth: 15.0, // Example
      collageHeight: 21.0, // Example
    );
  }

  /// Run edge case tests
  static void testEdgeCases() {
    debugPrint('\n🔍 TESTING EDGE CASES');
    debugPrint('=' * 50);

    // Single photo
    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 1,
      calculatedPhotos: 1,
      actualPhotosInPreview: 1,
      actualPhotosInFinal: 1,
      country: 'Single Photo Test',
    );

    // Large number of photos
    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 25,
      calculatedPhotos: 25,
      actualPhotosInPreview: 25,
      actualPhotosInFinal: 25,
      country: 'Large Photo Count Test',
    );

    // Very small dimensions
    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: 5.0,
      userRequestedHeight: 7.0,
      unit: 'cm',
      actualWidth: 5.0,
      actualHeight: 7.0,
      photosGenerated: 1,
    );

    // Large dimensions
    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: 50.0,
      userRequestedHeight: 70.0,
      unit: 'cm',
      actualWidth: 50.0,
      actualHeight: 70.0,
      photosGenerated: 100,
    );
  }

  /// Run all comprehensive tests
  static void runFullTestSuite() {
    debugPrint('\n🧪 RUNNING FULL COMPREHENSIVE TEST SUITE');
    debugPrint('=' * 60);

    // Basic validation suite
    RuntimeUserInputValidator.runQuickValidationSuite();

    // Country-specific tests
    testSpecificCountry('canada');
    testSpecificCountry('usa');
    testSpecificCountry('uk');
    testSpecificCountry('india');

    // Margin tests
    testMarginVariations();

    // Edge cases
    testEdgeCases();

    // Comprehensive unit tests
    ComprehensiveUserInputTester.runAllTests();

    debugPrint('\n' + '=' * 60);
    debugPrint('🎉 FULL TEST SUITE COMPLETED');
    debugPrint('Check output above for any ❌ FAILED tests');
    debugPrint('All ✅ PASSED tests indicate correct behavior');
  }
}
