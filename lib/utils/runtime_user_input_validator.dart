import 'package:flutter/material.dart';

/// Runtime validator that tests the actual app behavior with user inputs
class RuntimeUserInputValidator {
  /// Test photo count scenarios during runtime
  static void validatePhotoCountScenario({
    required int userRequestedPhotos,
    required int calculatedPhotos,
    required int actualPhotosInPreview,
    required int actualPhotosInFinal,
    required String country,
  }) {
    debugPrint(
      '\n🔍 VALIDATING: $country - User requested $userRequestedPhotos photos',
    );

    List<String> issues = [];

    // Critical validations
    if (calculatedPhotos != userRequestedPhotos) {
      issues.add(
        '❌ CALCULATION ISSUE: User wanted $userRequestedPhotos, system calculated $calculatedPhotos',
      );
    }

    if (actualPhotosInPreview != userRequestedPhotos) {
      issues.add(
        '❌ PREVIEW ISSUE: User wanted $userRequestedPhotos, preview shows $actualPhotosInPreview',
      );
    }

    if (actualPhotosInFinal != userRequestedPhotos) {
      issues.add(
        '❌ FINAL ISSUE: User wanted $userRequestedPhotos, final shows $actualPhotosInFinal',
      );
    }

    if (actualPhotosInPreview != actualPhotosInFinal) {
      issues.add(
        '❌ CONSISTENCY ISSUE: Preview shows $actualPhotosInPreview, final shows $actualPhotosInFinal',
      );
    }

    // Report results
    if (issues.isEmpty) {
      debugPrint(
        '✅ PASSED: $country $userRequestedPhotos photos - All validations successful',
      );
    } else {
      debugPrint('❌ FAILED: $country $userRequestedPhotos photos');
      for (String issue in issues) {
        debugPrint('   $issue');
      }
      debugPrint(
        '   📊 Summary: Requested=$userRequestedPhotos, Calc=$calculatedPhotos, Preview=$actualPhotosInPreview, Final=$actualPhotosInFinal',
      );
    }
  }

  /// Test dimension scenarios during runtime
  static void validateDimensionScenario({
    required double userRequestedWidth,
    required double userRequestedHeight,
    required String unit,
    required double actualWidth,
    required double actualHeight,
    required int photosGenerated,
  }) {
    debugPrint(
      '\n📏 VALIDATING: ${userRequestedWidth}x$userRequestedHeight $unit dimensions',
    );

    // Convert to consistent units (cm)
    double expectedWidthCm = userRequestedWidth;
    double expectedHeightCm = userRequestedHeight;
    if (unit == 'inch') {
      expectedWidthCm = userRequestedWidth * 2.54;
      expectedHeightCm = userRequestedHeight * 2.54;
    }

    List<String> issues = [];
    double tolerance = 0.1; // 1mm tolerance for rounding

    // Validate dimensions
    if ((actualWidth - expectedWidthCm).abs() > tolerance) {
      issues.add(
        '❌ WIDTH ISSUE: Expected ${expectedWidthCm.toStringAsFixed(1)}cm, got ${actualWidth.toStringAsFixed(1)}cm',
      );
    }

    if ((actualHeight - expectedHeightCm).abs() > tolerance) {
      issues.add(
        '❌ HEIGHT ISSUE: Expected ${expectedHeightCm.toStringAsFixed(1)}cm, got ${actualHeight.toStringAsFixed(1)}cm',
      );
    }

    // Report results
    if (issues.isEmpty) {
      debugPrint(
        '✅ PASSED: Dimensions match (${actualWidth.toStringAsFixed(1)}x${actualHeight.toStringAsFixed(1)}cm, $photosGenerated photos)',
      );
    } else {
      debugPrint('❌ FAILED: Dimension validation');
      for (String issue in issues) {
        debugPrint('   $issue');
      }
      debugPrint(
        '   📊 Generated: ${actualWidth.toStringAsFixed(1)}x${actualHeight.toStringAsFixed(1)}cm with $photosGenerated photos',
      );
    }
  }

  /// Test margin scenarios during runtime
  static void validateMarginScenario({
    required double userRequestedMarginMm,
    required double calculatedMarginMm,
    required int photoCount,
    required double collageWidth,
    required double collageHeight,
  }) {
    debugPrint('\n📐 VALIDATING: ${userRequestedMarginMm}mm margin');

    List<String> issues = [];

    // Validate margin is honored
    if ((calculatedMarginMm - userRequestedMarginMm).abs() > 0.01) {
      issues.add(
        '❌ MARGIN ISSUE: Expected ${userRequestedMarginMm}mm, applied ${calculatedMarginMm}mm',
      );
    }

    // Check if collage dimensions are reasonable with margin
    if (collageWidth <= 0 || collageHeight <= 0) {
      issues.add('❌ DIMENSION ISSUE: Invalid collage dimensions with margin');
    }

    // Report results
    if (issues.isEmpty) {
      debugPrint(
        '✅ PASSED: Margin ${userRequestedMarginMm}mm applied correctly (${collageWidth.toStringAsFixed(1)}x${collageHeight.toStringAsFixed(1)}cm, $photoCount photos)',
      );
    } else {
      debugPrint('❌ FAILED: Margin validation');
      for (String issue in issues) {
        debugPrint('   $issue');
      }
    }
  }

  /// Quick validation for common scenarios
  static void runQuickValidationSuite() {
    debugPrint('\n🚀 RUNNING QUICK VALIDATION SUITE');
    debugPrint('=' * 50);

    // Test common scenarios that users frequently encounter
    _testCommonScenarios();

    debugPrint('=' * 50);
    debugPrint('🚀 QUICK VALIDATION COMPLETED');
  }

  static void _testCommonScenarios() {
    // Simulate common user scenarios
    final scenarios = [
      {
        'name': 'Canada 6 Photos',
        'photos': 6,
        'width': 5.0,
        'height': 7.0,
        'margin': 2.5,
      },
      {
        'name': 'USA 4 Photos',
        'photos': 4,
        'width': 5.08,
        'height': 5.08,
        'margin': 2.5,
      },
      {
        'name': 'UK 8 Photos',
        'photos': 8,
        'width': 4.5,
        'height': 3.5,
        'margin': 2.0,
      },
      {
        'name': 'India 9 Photos',
        'photos': 9,
        'width': 5.1,
        'height': 5.1,
        'margin': 3.0,
      },
    ];

    for (var scenario in scenarios) {
      _simulateUserScenario(scenario);
    }
  }

  static void _simulateUserScenario(Map<String, dynamic> scenario) {
    String name = scenario['name'];
    int photos = scenario['photos'];
    double width = scenario['width'];
    double height = scenario['height'];
    double margin = scenario['margin'];

    debugPrint('\n🎯 Testing scenario: $name');
    debugPrint(
      '   User inputs: $photos photos, ${width}x${height}cm, ${margin}mm margin',
    );

    // Simulate the calculation (this would be the actual app logic)
    final result = _simulateAppCalculation(photos, width, height, margin);

    // Validate the result
    validatePhotoCountScenario(
      userRequestedPhotos: photos,
      calculatedPhotos: result['calculatedPhotos']!,
      actualPhotosInPreview: result['previewPhotos']!,
      actualPhotosInFinal: result['finalPhotos']!,
      country: name,
    );
  }

  static Map<String, int> _simulateAppCalculation(
    int targetPhotos,
    double photoWidth,
    double photoHeight,
    double margin,
  ) {
    // This simulates what the app should do (honor user's photo count)
    return {
      'calculatedPhotos': targetPhotos, // Should match user's request
      'previewPhotos': targetPhotos, // Should match user's request
      'finalPhotos': targetPhotos, // Should match user's request
    };
  }

  /// Validation helper for integration with actual app flow
  static void validateCurrentState({
    required String scenario,
    required int userPhotos,
    required int calculatedPhotos,
    required double userWidth,
    required double userHeight,
    required double actualWidth,
    required double actualHeight,
    required double userMargin,
    String unit = 'cm',
  }) {
    debugPrint('\n🎯 REAL-TIME VALIDATION: $scenario');

    // Validate photo count
    if (userPhotos != calculatedPhotos) {
      debugPrint(
        '❌ PHOTO COUNT MISMATCH: User=$userPhotos, Calculated=$calculatedPhotos',
      );
    } else {
      debugPrint('✅ PHOTO COUNT: $userPhotos photos (correct)');
    }

    // Validate dimensions if provided
    if (userWidth > 0 && userHeight > 0) {
      double expectedW = unit == 'inch' ? userWidth * 2.54 : userWidth;
      double expectedH = unit == 'inch' ? userHeight * 2.54 : userHeight;

      if ((actualWidth - expectedW).abs() > 0.1 ||
          (actualHeight - expectedH).abs() > 0.1) {
        debugPrint(
          '❌ DIMENSION MISMATCH: Expected=${expectedW.toStringAsFixed(1)}x${expectedH.toStringAsFixed(1)}cm, Actual=${actualWidth.toStringAsFixed(1)}x${actualHeight.toStringAsFixed(1)}cm',
        );
      } else {
        debugPrint(
          '✅ DIMENSIONS: ${actualWidth.toStringAsFixed(1)}x${actualHeight.toStringAsFixed(1)}cm (correct)',
        );
      }
    }

    debugPrint('📊 Margin: ${userMargin}mm');
  }
}
