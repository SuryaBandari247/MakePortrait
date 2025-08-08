import 'package:flutter/material.dart';

/// FOCUSED DIAGNOSTIC: Canada 6-Photo Issue
/// This tool diagnoses exactly why user gets 4 photos when requesting 6
class Canada6PhotoDiagnostic {
  /// Diagnose the exact Canada 6-photo scenario step by step
  static void diagnoseCanada6PhotoIssue() {
    debugPrint('\n🔥 FOCUSED DIAGNOSTIC: CANADA 6-PHOTO BUG');
    debugPrint('=' * 60);
    debugPrint('🎯 USER REQUEST: 6 photos with Canada passport size');
    debugPrint('🇨🇦 CANADA SPEC: 5.0 x 7.0 cm photos');
    debugPrint('📏 TYPICAL COLLAGE: A4 paper (21.0 x 29.7 cm)');

    // Step 1: Calculate what the grid should be for 6 photos
    _step1_CalculateOptimalGrid();

    // Step 2: Check current calculation logic
    _step2_CheckCurrentLogic();

    // Step 3: Identify the exact problem
    _step3_IdentifyProblem();

    // Step 4: Provide solution
    _step4_ProvideSolution();
  }

  static void _step1_CalculateOptimalGrid() {
    debugPrint('\n📊 STEP 1: OPTIMAL GRID CALCULATION');
    debugPrint('-' * 40);

    int targetPhotos = 6;
    double photoWidth = 5.0; // cm
    double photoHeight = 7.0; // cm
    double margin = 2.5; // mm = 0.25 cm

    debugPrint('Target: $targetPhotos photos');
    debugPrint('Photo size: ${photoWidth}x${photoHeight}cm');
    debugPrint('Margin: ${margin}mm');

    // Test all possible grids that can fit 6 photos
    List<Map<String, dynamic>> possibleGrids = [];

    for (int cols = 1; cols <= targetPhotos; cols++) {
      int rows = (targetPhotos / cols).ceil();
      int totalSlots = cols * rows;

      if (totalSlots >= targetPhotos) {
        double width = cols * photoWidth + (cols - 1) * (margin / 10);
        double height = rows * photoHeight + (rows - 1) * (margin / 10);

        possibleGrids.add({
          'cols': cols,
          'rows': rows,
          'totalSlots': totalSlots,
          'width': width,
          'height': height,
          'ratio': width / height,
          'exact': totalSlots == targetPhotos,
        });
      }
    }

    debugPrint('\n🔍 POSSIBLE GRIDS FOR 6 PHOTOS:');
    for (var grid in possibleGrids) {
      String exact = grid['exact'] ? '⭐ EXACT' : '   ';
      debugPrint(
        '  ${grid['cols']}x${grid['rows']} = ${grid['totalSlots']} slots | '
        '${grid['width'].toStringAsFixed(1)}x${grid['height'].toStringAsFixed(1)}cm | '
        'ratio ${grid['ratio'].toStringAsFixed(2)} $exact',
      );
    }

    // Find the optimal grid
    var optimal = possibleGrids.where((g) => g['exact']).isNotEmpty
        ? possibleGrids.where((g) => g['exact']).first
        : possibleGrids.first;

    debugPrint(
      '\n✅ OPTIMAL CHOICE: ${optimal['cols']}x${optimal['rows']} = ${optimal['totalSlots']} slots',
    );
    debugPrint(
      '   Collage size: ${optimal['width'].toStringAsFixed(1)}x${optimal['height'].toStringAsFixed(1)}cm',
    );
    debugPrint('   Should place: $targetPhotos photos (user request)');
  }

  static void _step2_CheckCurrentLogic() {
    debugPrint('\n🔍 STEP 2: CHECK CURRENT APP LOGIC');
    debugPrint('-' * 40);

    // Simulate current _calculateDimensionsFromPhotoCount logic
    int targetPhotos = 6;
    double photoWidthCm = 5.0;
    double photoHeightCm = 7.0;
    double marginMm = 2.5;
    int dpi = 300;

    final passportWidthPx = (photoWidthCm / 2.54 * dpi);
    final passportHeightPx = (photoHeightCm / 2.54 * dpi);
    final marginPx = (marginMm / 10.0 / 2.54 * dpi);

    debugPrint('Converting to pixels:');
    debugPrint(
      '  Photo: ${passportWidthPx.toStringAsFixed(1)} x ${passportHeightPx.toStringAsFixed(1)} px',
    );
    debugPrint('  Margin: ${marginPx.toStringAsFixed(1)} px');

    int bestCols = 1, bestRows = 1;
    double bestRatio = double.infinity;

    debugPrint('\n🔄 GRID SELECTION PROCESS:');
    for (int cols = 1; cols <= targetPhotos; cols++) {
      int rows = (targetPhotos / cols).ceil();
      int totalSlots = cols * rows;

      if (totalSlots >= targetPhotos) {
        double width = cols * passportWidthPx + (cols - 1) * marginPx;
        double height = rows * passportHeightPx + (rows - 1) * marginPx;
        double ratio = width / height;
        double targetRatio = 1.414; // A4 aspect ratio
        double ratioDiff = (ratio - 1 / targetRatio).abs();

        double priority = ratioDiff;
        if (totalSlots == targetPhotos) {
          priority -= 1000; // Huge preference for exact match
        }

        debugPrint(
          '  ${cols}x${rows} = $totalSlots slots | '
          'size ${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}px | '
          'ratio ${ratio.toStringAsFixed(2)} | '
          'diff ${ratioDiff.toStringAsFixed(3)} | '
          'priority ${priority.toStringAsFixed(3)}',
        );

        if (priority < bestRatio) {
          bestRatio = priority;
          bestCols = cols;
          bestRows = rows;
        }
      }
    }

    double finalWidthPx =
        bestCols * passportWidthPx + (bestCols - 1) * marginPx;
    double finalHeightPx =
        bestRows * passportHeightPx + (bestRows - 1) * marginPx;
    double calculatedWidth = finalWidthPx * 2.54 / dpi;
    double calculatedHeight = finalHeightPx * 2.54 / dpi;

    debugPrint('\n✅ CURRENT APP CHOICE:');
    debugPrint(
      '  Grid: ${bestCols}x${bestRows} = ${bestCols * bestRows} slots',
    );
    debugPrint(
      '  Collage: ${calculatedWidth.toStringAsFixed(1)}x${calculatedHeight.toStringAsFixed(1)}cm',
    );
    debugPrint('  _calculatedPhotos should be: $targetPhotos (user request)');

    // Now check what happens in preview/final generation
    _checkGridCalculationInCollageGeneration(
      calculatedWidth,
      calculatedHeight,
      photoWidthCm,
      photoHeightCm,
      marginMm,
      dpi,
    );
  }

  static void _checkGridCalculationInCollageGeneration(
    double collageWidth,
    double collageHeight,
    double photoWidth,
    double photoHeight,
    double marginMm,
    int dpi,
  ) {
    debugPrint('\n🖼️ COLLAGE GENERATION GRID CALCULATION:');
    debugPrint(
      '   Input collage: ${collageWidth.toStringAsFixed(1)}x${collageHeight.toStringAsFixed(1)}cm',
    );

    final marginCm = marginMm / 10.0;
    final passportWidthPxFloat = (photoWidth / 2.54 * dpi);
    final passportHeightPxFloat = (photoHeight / 2.54 * dpi);
    final collageWidthPxFloat = (collageWidth / 2.54 * dpi);
    final collageHeightPxFloat = (collageHeight / 2.54 * dpi);
    final marginPxFloat = (marginCm / 2.54 * dpi);

    final cols =
        ((collageWidthPxFloat + marginPxFloat) /
                (passportWidthPxFloat + marginPxFloat))
            .floor();
    final rows =
        ((collageHeightPxFloat + marginPxFloat) /
                (passportHeightPxFloat + marginPxFloat))
            .floor();

    debugPrint('   Calculated grid: ${cols}x${rows} = ${cols * rows} slots');
    debugPrint('   ⚠️  THIS IS WHERE PHOTOS GET LOST!');

    if (cols * rows < 6) {
      debugPrint(
        '   🚨 PROBLEM: Grid only has ${cols * rows} slots but user wants 6 photos!',
      );
    }
  }

  static void _step3_IdentifyProblem() {
    debugPrint('\n🚨 STEP 3: PROBLEM IDENTIFICATION');
    debugPrint('-' * 40);

    debugPrint(
      '❌ ISSUE: The app calculates collage dimensions based on A4 optimization',
    );
    debugPrint(
      '❌ ISSUE: These dimensions may not fit the user\'s requested photo count',
    );
    debugPrint(
      '❌ ISSUE: Preview and final generation use grid calculation from dimensions',
    );
    debugPrint('❌ ISSUE: If dimensions don\'t fit 6 photos, only 4 get placed');

    debugPrint('\n🔍 ROOT CAUSE:');
    debugPrint('1. User requests 6 photos');
    debugPrint('2. App calculates "optimal" collage dimensions for A4 ratio');
    debugPrint(
      '3. These dimensions might only fit 4 photos due to rounding/optimization',
    );
    debugPrint(
      '4. Preview/final use dimension-based grid → shows only 4 photos',
    );
    debugPrint('5. User gets confused: "I asked for 6, why do I see 4?"');
  }

  static void _step4_ProvideSolution() {
    debugPrint('\n✅ STEP 4: SOLUTION');
    debugPrint('-' * 40);

    debugPrint('🎯 SOLUTION: Force grid to accommodate user\'s photo count');
    debugPrint('');
    debugPrint('CURRENT LOGIC (WRONG):');
    debugPrint('  1. Calculate optimal collage size for A4 ratio');
    debugPrint(
      '  2. Calculate how many photos fit → might be less than requested',
    );
    debugPrint('');
    debugPrint('FIXED LOGIC (CORRECT):');
    debugPrint('  1. Calculate minimum collage size to fit requested photos');
    debugPrint('  2. Ensure grid always accommodates user\'s photo count');
    debugPrint('  3. Both preview and final use user\'s photo count as limit');

    debugPrint('\n🔧 IMPLEMENTATION:');
    debugPrint('1. In _calculateDimensionsFromPhotoCount():');
    debugPrint('   _calculatedPhotos = _targetPhotoCount (ALWAYS)');
    debugPrint('');
    debugPrint('2. In collage generation:');
    debugPrint('   Place exactly _calculatedPhotos photos (user\'s request)');
    debugPrint('   Ignore extra grid slots');
    debugPrint('');
    debugPrint('3. Verification:');
    debugPrint('   Preview photos = User request');
    debugPrint('   Final photos = User request');
    debugPrint('   Preview photos = Final photos');
  }

  /// Quick test to verify if the fix is working
  static void testFix() {
    debugPrint('\n🧪 TESTING THE FIX');
    debugPrint('=' * 40);

    debugPrint('🇨🇦 CANADA 6-PHOTO TEST:');
    debugPrint('Expected Result:');
    debugPrint('  ✅ User requests: 6 photos');
    debugPrint('  ✅ Preview shows: 6 photos');
    debugPrint('  ✅ Final shows: 6 photos');
    debugPrint('  ✅ Consistency: Perfect match');

    debugPrint('\n🚨 If you still see 4 photos:');
    debugPrint('  1. Check _calculatedPhotos = _targetPhotoCount is working');
    debugPrint('  2. Check photo placement loop uses _calculatedPhotos limit');
    debugPrint('  3. Check targetPhotoCount is passed to ResultScreen');
    debugPrint('  4. Check ResultScreen honors targetPhotoCount');
  }
}
