import 'dart:developer' as developer;

class CollageCalculationFixer {
  static void debugCanadaIssue() {
    const passportWidthCm = 5.0;
    const passportHeightCm = 7.0;
    const targetPhotos = 6;
    const marginMm = 2.5;
    const dpi = 300;

    developer.log('=== DEBUGGING CANADA 6-PHOTO ISSUE ===');
    developer.log('Passport: ${passportWidthCm}x${passportHeightCm} cm');
    developer.log('Target: $targetPhotos photos');
    developer.log('Margin: ${marginMm}mm');

    // Step 1: How the preview calculates dimensions
    final result = calculateDimensionsFromPhotoCount(
      passportWidthCm,
      passportHeightCm,
      targetPhotos,
      marginMm,
      dpi,
    );
    developer.log('\n--- PREVIEW DIMENSION CALCULATION ---');
    developer.log(
      'Best layout: ${result['cols']}x${result['rows']} = ${result['photos']} photos',
    );
    developer.log(
      'Calculated size: ${result['width']!.toStringAsFixed(2)}x${result['height']!.toStringAsFixed(2)} cm',
    );

    // Step 2: How the preview verifies photos fit
    final previewVerify = verifyPhotosInPreview(
      passportWidthCm,
      passportHeightCm,
      result['width']!,
      result['height']!,
      marginMm,
      dpi,
    );
    developer.log('\n--- PREVIEW VERIFICATION ---');
    developer.log(
      'Preview shows: ${previewVerify['photos']} photos (${previewVerify['cols']}x${previewVerify['rows']})',
    );

    // Step 3: How the final result calculates
    final finalVerify = verifyPhotosInFinal(
      passportWidthCm,
      passportHeightCm,
      result['width']!,
      result['height']!,
      marginMm,
      dpi,
    );
    developer.log('\n--- FINAL RESULT CALCULATION ---');
    developer.log(
      'Final places: ${finalVerify['photos']} photos (${finalVerify['cols']}x${finalVerify['rows']})',
    );

    // Step 4: Show the exact problem
    developer.log('\n--- ISSUE ANALYSIS ---');
    if (result['photos'] != previewVerify['photos']) {
      developer.log(
        '❌ PREVIEW MISMATCH: Calculated ${result['photos']} but preview shows ${previewVerify['photos']}',
      );
    }
    if (previewVerify['photos'] != finalVerify['photos']) {
      developer.log(
        '❌ FINAL MISMATCH: Preview shows ${previewVerify['photos']} but final places ${finalVerify['photos']}',
      );
    }
    if (result['photos'] == previewVerify['photos'] &&
        previewVerify['photos'] == finalVerify['photos']) {
      developer.log('✅ All calculations match: ${result['photos']} photos');
    }

    // Step 5: Show detailed pixel calculations
    _showDetailedCalculations(
      passportWidthCm,
      passportHeightCm,
      result['width']!,
      result['height']!,
      marginMm,
      dpi,
    );
  }

  static Map<String, double> calculateDimensionsFromPhotoCount(
    double passportWidthCm,
    double passportHeightCm,
    int targetPhotos,
    double marginMm,
    int dpi,
  ) {
    final passportWidthPx = (passportWidthCm / 2.54 * dpi);
    final passportHeightPx = (passportHeightCm / 2.54 * dpi);
    final marginPx = (marginMm / 10.0 / 2.54 * dpi);

    int bestCols = 1, bestRows = 1;
    double bestRatio = double.infinity;

    for (int cols = 1; cols <= targetPhotos; cols++) {
      int rows = (targetPhotos / cols).ceil();
      if (cols * rows >= targetPhotos) {
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

  static Map<String, double> verifyPhotosInPreview(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    // This simulates the preview calculation with 0.3 scale
    final previewScale = 0.3;
    final passportWidthPx = (passportWidthCm / 2.54 * dpi * previewScale);
    final passportHeightPx = (passportHeightCm / 2.54 * dpi * previewScale);
    final marginPx = (marginMm / 10.0 / 2.54 * dpi * previewScale);
    final collageWidthPx = (collageWidthCm / 2.54 * dpi * previewScale);
    final collageHeightPx = (collageHeightCm / 2.54 * dpi * previewScale);

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

  static Map<String, double> verifyPhotosInFinal(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    // This simulates the final result calculation
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

  static void _showDetailedCalculations(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    developer.log('\n--- DETAILED PIXEL CALCULATIONS ---');

    // Preview (scaled)
    final previewScale = 0.3;
    final prevPassportW = (passportWidthCm / 2.54 * dpi * previewScale);
    final prevPassportH = (passportHeightCm / 2.54 * dpi * previewScale);
    final prevMargin = (marginMm / 10.0 / 2.54 * dpi * previewScale);
    final prevCollageW = (collageWidthCm / 2.54 * dpi * previewScale);
    final prevCollageH = (collageHeightCm / 2.54 * dpi * previewScale);

    developer.log('Preview (scale 0.3):');
    developer.log(
      '  Passport: ${prevPassportW.toStringAsFixed(2)}x${prevPassportH.toStringAsFixed(2)}px',
    );
    developer.log('  Margin: ${prevMargin.toStringAsFixed(2)}px');
    developer.log(
      '  Collage: ${prevCollageW.toStringAsFixed(2)}x${prevCollageH.toStringAsFixed(2)}px',
    );
    developer.log(
      '  Cols: (${prevCollageW.toStringAsFixed(2)} + ${prevMargin.toStringAsFixed(2)}) / (${prevPassportW.toStringAsFixed(2)} + ${prevMargin.toStringAsFixed(2)}) = ${((prevCollageW + prevMargin) / (prevPassportW + prevMargin)).toStringAsFixed(4)} → ${((prevCollageW + prevMargin) / (prevPassportW + prevMargin)).floor()}',
    );
    developer.log(
      '  Rows: (${prevCollageH.toStringAsFixed(2)} + ${prevMargin.toStringAsFixed(2)}) / (${prevPassportH.toStringAsFixed(2)} + ${prevMargin.toStringAsFixed(2)}) = ${((prevCollageH + prevMargin) / (prevPassportH + prevMargin)).toStringAsFixed(4)} → ${((prevCollageH + prevMargin) / (prevPassportH + prevMargin)).floor()}',
    );

    // Final (full scale)
    final finalPassportW = (passportWidthCm / 2.54 * dpi);
    final finalPassportH = (passportHeightCm / 2.54 * dpi);
    final finalMargin = (marginMm / 10.0 / 2.54 * dpi);
    final finalCollageW = (collageWidthCm / 2.54 * dpi);
    final finalCollageH = (collageHeightCm / 2.54 * dpi);

    developer.log('\nFinal (full scale):');
    developer.log(
      '  Passport: ${finalPassportW.toStringAsFixed(2)}x${finalPassportH.toStringAsFixed(2)}px',
    );
    developer.log('  Margin: ${finalMargin.toStringAsFixed(2)}px');
    developer.log(
      '  Collage: ${finalCollageW.toStringAsFixed(2)}x${finalCollageH.toStringAsFixed(2)}px',
    );
    developer.log(
      '  Cols: (${finalCollageW.toStringAsFixed(2)} + ${finalMargin.toStringAsFixed(2)}) / (${finalPassportW.toStringAsFixed(2)} + ${finalMargin.toStringAsFixed(2)}) = ${((finalCollageW + finalMargin) / (finalPassportW + finalMargin)).toStringAsFixed(4)} → ${((finalCollageW + finalMargin) / (finalPassportW + finalMargin)).floor()}',
    );
    developer.log(
      '  Rows: (${finalCollageH.toStringAsFixed(2)} + ${finalMargin.toStringAsFixed(2)}) / (${finalPassportH.toStringAsFixed(2)} + ${finalMargin.toStringAsFixed(2)}) = ${((finalCollageH + finalMargin) / (finalPassportH + finalMargin)).toStringAsFixed(4)} → ${((finalCollageH + finalMargin) / (finalPassportH + finalMargin)).floor()}',
    );
  }
}
