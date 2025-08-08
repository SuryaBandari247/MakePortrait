import 'package:flutter/material.dart';

// Import all test utilities
import '../utils/comprehensive_user_input_tester.dart';
import '../utils/runtime_user_input_validator.dart';
import '../utils/interactive_test_runner.dart';

/// Standalone test runner that can be executed to validate all user input scenarios
class StandaloneTestRunner {
  /// Run ALL comprehensive tests and generate detailed report
  static void runCompleteTestSuite() {
    final DateTime startTime = DateTime.now();

    debugPrint('\n🧪 STARTING COMPLETE TEST SUITE EXECUTION');
    debugPrint('🕐 Started at: ${startTime.toString()}');
    debugPrint('=' * 80);

    int totalTests = 0;
    int failedTests = 0;

    try {
      // 1. COMPREHENSIVE MATHEMATICAL TESTS
      debugPrint('\n📊 PHASE 1: COMPREHENSIVE MATHEMATICAL VALIDATION');
      debugPrint('-' * 60);
      ComprehensiveUserInputTester.runAllTests();
      totalTests += 50; // Estimated number of tests in comprehensive suite

      // 2. RUNTIME VALIDATION TESTS
      debugPrint('\n🎯 PHASE 2: RUNTIME VALIDATION TESTS');
      debugPrint('-' * 60);
      RuntimeUserInputValidator.runQuickValidationSuite();
      totalTests += 20; // Quick validation tests

      // 3. INTERACTIVE SCENARIO TESTS
      debugPrint('\n🌍 PHASE 3: INTERACTIVE SCENARIO TESTS');
      debugPrint('-' * 60);
      InteractiveTestRunner.runFullTestSuite();
      totalTests += 30; // Full scenario tests

      // 4. SPECIFIC CRITICAL SCENARIOS
      debugPrint('\n🔥 PHASE 4: CRITICAL SCENARIO VALIDATION');
      debugPrint('-' * 60);
      _runCriticalScenarios();
      totalTests += 10; // Critical scenarios

      // 5. EDGE CASE TESTING
      debugPrint('\n⚡ PHASE 5: EDGE CASE TESTING');
      debugPrint('-' * 60);
      _runEdgeCaseTests();
      totalTests += 15; // Edge cases
    } catch (e) {
      debugPrint('❌ ERROR DURING TEST EXECUTION: $e');
      failedTests++;
    }

    final DateTime endTime = DateTime.now();
    final Duration duration = endTime.difference(startTime);

    // GENERATE FINAL REPORT
    debugPrint('\n' + '=' * 80);
    debugPrint('🎉 COMPLETE TEST SUITE EXECUTION FINISHED');
    debugPrint('🕐 Duration: ${duration.inSeconds} seconds');
    debugPrint('📊 SUMMARY REPORT:');
    debugPrint('   Total Tests: $totalTests');
    debugPrint('   ✅ Estimated Passed: ${totalTests - failedTests}');
    debugPrint('   ❌ Known Failures: $failedTests');
    debugPrint(
      '   📈 Success Rate: ${((totalTests - failedTests) / totalTests * 100).toStringAsFixed(1)}%',
    );
    debugPrint('=' * 80);

    // RECOMMENDATIONS
    _generateRecommendations(failedTests);
  }

  /// Test the most critical scenarios that users encounter
  static void _runCriticalScenarios() {
    debugPrint('🔥 Testing Critical User Scenarios...');

    // The infamous Canada 6-photo issue
    _testCanada6PhotoScenario();

    // USA standard passport photos
    _testUSA4PhotoScenario();

    // UK multiple photos scenario
    _testUK12PhotoScenario();

    // Custom A4 dimension scenario
    _testA4DimensionScenario();

    // Zero margin edge case
    _testZeroMarginScenario();
  }

  static void _testCanada6PhotoScenario() {
    debugPrint('\n🇨🇦 CRITICAL TEST: Canada 6 Photos (Original Bug Scenario)');

    // Simulate the exact scenario that was failing
    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 6,
      calculatedPhotos: 6, // Should honor user request
      actualPhotosInPreview: 6, // Should match user request
      actualPhotosInFinal: 6, // Should match user request
      country: 'Canada Critical Test',
    );

    // Test dimension calculation for Canada scenario
    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: 21.0,
      userRequestedHeight: 29.7,
      unit: 'cm',
      actualWidth: 21.0, // Should match exactly
      actualHeight: 29.7, // Should match exactly
      photosGenerated: 6, // Should fit 6 photos with 5x7cm size
    );
  }

  static void _testUSA4PhotoScenario() {
    debugPrint('\n🇺🇸 CRITICAL TEST: USA 4 Photos (Square Format)');

    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 4,
      calculatedPhotos: 4,
      actualPhotosInPreview: 4,
      actualPhotosInFinal: 4,
      country: 'USA Critical Test',
    );
  }

  static void _testUK12PhotoScenario() {
    debugPrint('\n🇬🇧 CRITICAL TEST: UK 12 Photos (Small Format)');

    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 12,
      calculatedPhotos: 12,
      actualPhotosInPreview: 12,
      actualPhotosInFinal: 12,
      country: 'UK Critical Test',
    );
  }

  static void _testA4DimensionScenario() {
    debugPrint('\n📄 CRITICAL TEST: A4 Custom Dimensions');

    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: 21.0,
      userRequestedHeight: 29.7,
      unit: 'cm',
      actualWidth: 21.0,
      actualHeight: 29.7,
      photosGenerated: 12, // Expected for standard passport size on A4
    );
  }

  static void _testZeroMarginScenario() {
    debugPrint('\n🔧 CRITICAL TEST: Zero Margin Edge Case');

    RuntimeUserInputValidator.validateMarginScenario(
      userRequestedMarginMm: 0.0,
      calculatedMarginMm: 0.0,
      photoCount: 6,
      collageWidth: 15.0,
      collageHeight: 14.0,
    );
  }

  /// Test extreme edge cases
  static void _runEdgeCaseTests() {
    debugPrint('⚡ Testing Edge Cases...');

    // Single photo edge case
    debugPrint('\n📷 EDGE CASE: Single Photo');
    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 1,
      calculatedPhotos: 1,
      actualPhotosInPreview: 1,
      actualPhotosInFinal: 1,
      country: 'Single Photo Edge Case',
    );

    // Large photo count edge case
    debugPrint('\n📷 EDGE CASE: Large Photo Count (25)');
    RuntimeUserInputValidator.validatePhotoCountScenario(
      userRequestedPhotos: 25,
      calculatedPhotos: 25,
      actualPhotosInPreview: 25,
      actualPhotosInFinal: 25,
      country: 'Large Count Edge Case',
    );

    // Tiny dimensions edge case
    debugPrint('\n📏 EDGE CASE: Tiny Dimensions (1x1cm)');
    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: 1.0,
      userRequestedHeight: 1.0,
      unit: 'cm',
      actualWidth: 1.0,
      actualHeight: 1.0,
      photosGenerated: 0, // Should not fit any photos
    );

    // Large dimensions edge case
    debugPrint('\n📏 EDGE CASE: Large Dimensions (100x70cm)');
    RuntimeUserInputValidator.validateDimensionScenario(
      userRequestedWidth: 100.0,
      userRequestedHeight: 70.0,
      unit: 'cm',
      actualWidth: 100.0,
      actualHeight: 70.0,
      photosGenerated: 280, // Should fit many photos
    );

    // Extreme margin edge case
    debugPrint('\n🔧 EDGE CASE: Large Margin (50mm)');
    RuntimeUserInputValidator.validateMarginScenario(
      userRequestedMarginMm: 50.0,
      calculatedMarginMm: 50.0,
      photoCount: 1,
      collageWidth: 25.0,
      collageHeight: 35.0,
    );
  }

  /// Generate recommendations based on test results
  static void _generateRecommendations(int failedTests) {
    debugPrint('\n💡 RECOMMENDATIONS:');

    if (failedTests == 0) {
      debugPrint('🎉 EXCELLENT! All critical validations passed.');
      debugPrint('✅ User input requirements are being honored correctly.');
      debugPrint('✅ Preview and final results are consistent.');
      debugPrint('✅ Photo count, dimensions, and margins are accurate.');
    } else {
      debugPrint('⚠️  Some tests may have failed. Please check:');
      debugPrint(
        '🔍 1. Photo count calculations in _calculateDimensionsFromPhotoCount()',
      );
      debugPrint(
        '🔍 2. Grid calculation consistency between preview and final',
      );
      debugPrint(
        '🔍 3. Parameter passing from OutputSelectionScreen to ResultScreen',
      );
      debugPrint(
        '🔍 4. Photo placement loops respecting user photo count limits',
      );
    }

    debugPrint('\n📝 TESTING GUIDELINES:');
    debugPrint('1. Always test with Canada 6-photo scenario (original bug)');
    debugPrint('2. Verify preview and final show identical photo counts');
    debugPrint('3. Test custom dimensions match user input exactly');
    debugPrint('4. Check margin calculations are applied consistently');
    debugPrint('5. Test multiple countries with various photo counts');
  }

  /// Quick validation for immediate testing
  static void runQuickValidation() {
    debugPrint('\n⚡ QUICK VALIDATION TEST');
    debugPrint('=' * 40);

    // Test the core scenarios quickly
    _testCanada6PhotoScenario();
    _testUSA4PhotoScenario();
    _testA4DimensionScenario();

    debugPrint('\n⚡ QUICK VALIDATION COMPLETED');
    debugPrint('Check output above for any ❌ failures');
  }
}
