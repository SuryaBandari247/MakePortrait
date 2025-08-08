import 'dart:developer' as developer;

class SpecificCollageTest {
  static void testCanadaScenario() {
    // Canada passport: 5.0 x 7.0 cm
    // Target: 6 photos
    // Margin: 2.5mm

    const passportWidthCm = 5.0;
    const passportHeightCm = 7.0;
    const targetPhotoCount = 6;
    const marginMm = 2.5;
    const dpi = 300;

    developer.log('=== CANADA 6-PHOTO SCENARIO TEST ===');
    developer.log('Passport size: ${passportWidthCm}x$passportHeightCm cm');
    developer.log('Target photos: $targetPhotoCount');
    developer.log('Margin: ${marginMm}mm');

    // Step 1: Preview calculation (from output_selection_screen.dart)
    final previewResult = _calculateDimensionsFromPhotoCount(
      passportWidthCm,
      passportHeightCm,
      targetPhotoCount,
      marginMm,
      dpi,
    );

    developer.log('\n--- PREVIEW CALCULATION ---');
    developer.log(
      'Calculated dimensions: ${previewResult['width']!.toStringAsFixed(2)}x${previewResult['height']!.toStringAsFixed(2)} cm',
    );
    developer.log(
      'Grid layout: ${previewResult['cols']}x${previewResult['rows']}',
    );
    developer.log('Total photos in preview: ${previewResult['photos']}');

    // Step 2: Preview verification (from _generateCollagePreview)
    final previewVerification = _verifyPreviewCalculation(
      passportWidthCm,
      passportHeightCm,
      previewResult['width']!,
      previewResult['height']!,
      marginMm,
      dpi,
    );

    developer.log('\n--- PREVIEW VERIFICATION ---');
    developer.log(
      'Preview grid: ${previewVerification['cols']}x${previewVerification['rows']}',
    );
    developer.log('Preview photos shown: ${previewVerification['photos']}');

    // Step 3: Final calculation (from result_screen.dart)
    final finalResult = _verifyFinalCalculation(
      passportWidthCm,
      passportHeightCm,
      previewResult['width']!,
      previewResult['height']!,
      marginMm,
      dpi,
    );

    developer.log('\n--- FINAL CALCULATION ---');
    developer.log('Final grid: ${finalResult['cols']}x${finalResult['rows']}');
    developer.log('Final photos placed: ${finalResult['photos']}');

    // Step 4: Compare results
    developer.log('\n--- COMPARISON ---');
    if (previewResult['photos'] == previewVerification['photos'] &&
        previewVerification['photos'] == finalResult['photos']) {
      developer.log('✅ ALL MATCH: ${finalResult['photos']} photos');
    } else {
      developer.log('❌ MISMATCH DETECTED!');
      developer.log('Preview calculation: ${previewResult['photos']} photos');
      developer.log(
        'Preview verification: ${previewVerification['photos']} photos',
      );
      developer.log('Final result: ${finalResult['photos']} photos');

      // Detailed debug info
      developer.log('\n--- DETAILED DEBUG ---');
      _debugCalculations(
        passportWidthCm,
        passportHeightCm,
        previewResult['width']!,
        previewResult['height']!,
        marginMm,
        dpi,
      );
    }
  }

  static Map<String, double> _calculateDimensionsFromPhotoCount(
    double passportWidthCm,
    double passportHeightCm,
    int targetPhotoCount,
    double marginMm,
    int dpi,
  ) {
    final passportWidthPx = (passportWidthCm / 2.54 * dpi);
    final passportHeightPx = (passportHeightCm / 2.54 * dpi);
    final marginPx = (marginMm / 10.0 / 2.54 * dpi);

    int bestCols = 1, bestRows = 1;
    double bestRatio = double.infinity;

    for (int cols = 1; cols <= targetPhotoCount; cols++) {
      int rows = (targetPhotoCount / cols).ceil();
      if (cols * rows >= targetPhotoCount) {
        double width = cols * passportWidthPx + (cols - 1) * marginPx;
        double height = rows * passportHeightPx + (rows - 1) * marginPx;
        double ratio = width / height;
        double targetRatio = 1.414; // A4 aspect ratio
        double ratioDiff = (ratio - 1 / targetRatio).abs();

        if (ratioDiff < bestRatio) {
          bestRatio = ratioDiff;
          bestCols = cols;
          bestRows = rows;
        }
      }
    }

    double finalWidthPx =
        bestCols * passportWidthPx + (bestCols - 1) * marginPx;
    double finalHeightPx =
        bestRows * passportHeightPx + (bestRows - 1) * marginPx;

    return {
      'width': finalWidthPx * 2.54 / dpi,
      'height': finalHeightPx * 2.54 / dpi,
      'photos': (bestCols * bestRows).toDouble(),
      'cols': bestCols.toDouble(),
      'rows': bestRows.toDouble(),
    };
  }

  static Map<String, double> _verifyPreviewCalculation(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    // This simulates _generateCollagePreview calculation
    final previewScale = 0.3;
    final passportWidthPx = (passportWidthCm / 2.54 * dpi * previewScale)
        .round();
    final passportHeightPx = (passportHeightCm / 2.54 * dpi * previewScale)
        .round();
    final marginPx = (marginMm / 10.0 / 2.54 * dpi * previewScale).round();
    final collageWidthPx = (collageWidthCm / 2.54 * dpi * previewScale).round();
    final collageHeightPx = (collageHeightCm / 2.54 * dpi * previewScale)
        .round();

    final cols = ((collageWidthPx + marginPx) / (passportWidthPx + marginPx))
        .floor();
    final rows = ((collageHeightPx + marginPx) / (passportHeightPx + marginPx))
        .floor();

    return {
      'photos': (cols * rows).toDouble(),
      'cols': cols.toDouble(),
      'rows': rows.toDouble(),
    };
  }

  static Map<String, double> _verifyFinalCalculation(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    // This matches the result_screen.dart calculation exactly
    final marginCm = marginMm / 10.0;
    final passportWidthPxFloat = (passportWidthCm / 2.54 * dpi);
    final passportHeightPxFloat = (passportHeightCm / 2.54 * dpi);
    final collageWidthPxFloat = (collageWidthCm / 2.54 * dpi);
    final collageHeightPxFloat = (collageHeightCm / 2.54 * dpi);
    final marginPxFloat = (marginCm / 2.54 * dpi);

    final cols =
        ((collageWidthPxFloat + marginPxFloat) /
                (passportWidthPxFloat + marginPxFloat))
            .floor();
    final rows =
        ((collageHeightPxFloat + marginPxFloat) /
                (passportHeightPxFloat + marginPxFloat))
            .floor();

    return {
      'photos': (cols * rows).toDouble(),
      'cols': cols.toDouble(),
      'rows': rows.toDouble(),
    };
  }

  static void _debugCalculations(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    developer.log('Passport size: ${passportWidthCm}x$passportHeightCm cm');
    developer.log('Collage size: ${collageWidthCm}x$collageHeightCm cm');
    developer.log('Margin: ${marginMm}mm = ${marginMm / 10}cm');

    // Preview calculation details
    final previewScale = 0.3;
    final prevPassportWPx = (passportWidthCm / 2.54 * dpi * previewScale)
        .round();
    final prevPassportHPx = (passportHeightCm / 2.54 * dpi * previewScale)
        .round();
    final prevMarginPx = (marginMm / 10.0 / 2.54 * dpi * previewScale).round();
    final prevCollageWPx = (collageWidthCm / 2.54 * dpi * previewScale).round();
    final prevCollageHPx = (collageHeightCm / 2.54 * dpi * previewScale)
        .round();

    developer.log('\nPreview calculation (scale $previewScale):');
    developer.log('  Passport: ${prevPassportWPx}x${prevPassportHPx}px');
    developer.log('  Margin: ${prevMarginPx}px');
    developer.log('  Collage: ${prevCollageWPx}x${prevCollageHPx}px');
    developer.log(
      '  Cols calc: ($prevCollageWPx + $prevMarginPx) / ($prevPassportWPx + $prevMarginPx) = ${((prevCollageWPx + prevMarginPx) / (prevPassportWPx + prevMarginPx)).floor()}',
    );
    developer.log(
      '  Rows calc: ($prevCollageHPx + $prevMarginPx) / ($prevPassportHPx + $prevMarginPx) = ${((prevCollageHPx + prevMarginPx) / (prevPassportHPx + prevMarginPx)).floor()}',
    );

    // Final calculation details
    final marginCm = marginMm / 10.0;
    final finalPassportWPx = (passportWidthCm / 2.54 * dpi);
    final finalPassportHPx = (passportHeightCm / 2.54 * dpi);
    final finalMarginPx = (marginCm / 2.54 * dpi);
    final finalCollageWPx = (collageWidthCm / 2.54 * dpi);
    final finalCollageHPx = (collageHeightCm / 2.54 * dpi);

    developer.log('\nFinal calculation (full scale):');
    developer.log('  Passport: ${finalPassportWPx}x${finalPassportHPx}px');
    developer.log('  Margin: ${finalMarginPx}px');
    developer.log('  Collage: ${finalCollageWPx}x${finalCollageHPx}px');
    developer.log(
      '  Cols calc: ($finalCollageWPx + $finalMarginPx) / ($finalPassportWPx + $finalMarginPx) = ${((finalCollageWPx + finalMarginPx) / (finalPassportWPx + finalMarginPx)).floor()}',
    );
    developer.log(
      '  Rows calc: ($finalCollageHPx + $finalMarginPx) / ($finalPassportHPx + $finalMarginPx) = ${((finalCollageHPx + finalMarginPx) / (finalPassportHPx + finalMarginPx)).floor()}',
    );
  }
}
