import 'dart:developer' as developer;

class CollageDebugTester {
  static void testAllCombinations() {
    // Test all passport sizes
    final passportSizes = {
      'India (2x2 inch)': [5.08, 5.08],
      'US (2x2 inch)': [5.08, 5.08],
      'UK (35x45 mm)': [3.5, 4.5],
      'EU (35x45 mm)': [3.5, 4.5],
      'China (33x48 mm)': [3.3, 4.8],
      'Canada (50x70 mm)': [5.0, 7.0],
      'Australia (35x45 mm)': [3.5, 4.5],
      'Singapore (35x45 mm)': [3.5, 4.5],
      'Malaysia (35x50 mm)': [3.5, 5.0],
    };

    // Test cases
    final testCases = [
      {'photoCount': 6, 'margin': 2.5, 'mode': 'by_photo_count'},
      {'photoCount': 4, 'margin': 2.5, 'mode': 'by_photo_count'},
      {'photoCount': 8, 'margin': 2.5, 'mode': 'by_photo_count'},
      {'photoCount': 12, 'margin': 2.5, 'mode': 'by_photo_count'},
      {'width': 10.0, 'height': 15.0, 'margin': 2.5, 'mode': 'by_dimensions'},
      {
        'width': 21.0,
        'height': 29.7,
        'margin': 2.5,
        'mode': 'by_dimensions',
      }, // A4
    ];

    final dpi = 300;

    developer.log('=== COLLAGE DEBUG TEST ===');

    for (final country in passportSizes.keys) {
      final size = passportSizes[country]!;
      final passportWidthCm = size[0];
      final passportHeightCm = size[1];

      developer.log(
        '\n--- TESTING: $country (${passportWidthCm}x${passportHeightCm} cm) ---',
      );

      for (final testCase in testCases) {
        final margin = testCase['margin'] as double;
        final mode = testCase['mode'] as String;

        developer.log('\nTest Case: $mode, margin: ${margin}mm');

        if (mode == 'by_photo_count') {
          final photoCount = testCase['photoCount'] as int;
          developer.log('Target photos: $photoCount');

          final result = calculateDimensionsFromPhotoCount(
            passportWidthCm,
            passportHeightCm,
            photoCount,
            margin,
            dpi,
          );

          final verification = verifyCalculation(
            passportWidthCm,
            passportHeightCm,
            result['width']!,
            result['height']!,
            margin,
            dpi,
          );

          developer.log(
            'Preview calculation: ${result['photos']} photos, ${result['width']!.toStringAsFixed(1)}x${result['height']!.toStringAsFixed(1)} cm',
          );
          developer.log(
            'Final verification: ${verification['photos']} photos (${verification['cols']}x${verification['rows']})',
          );

          if (result['photos'] != verification['photos']) {
            developer.log(
              '❌ MISMATCH! Preview: ${result['photos']}, Final: ${verification['photos']}',
            );
          } else {
            developer.log('✅ Match: ${result['photos']} photos');
          }
        } else {
          final width = testCase['width'] as double;
          final height = testCase['height'] as double;
          developer.log('Paper size: ${width}x${height} cm');

          final result = calculatePhotosFromDimensions(
            passportWidthCm,
            passportHeightCm,
            width,
            height,
            margin,
            dpi,
          );

          final verification = verifyCalculation(
            passportWidthCm,
            passportHeightCm,
            width,
            height,
            margin,
            dpi,
          );

          developer.log(
            'Preview calculation: ${result['photos']} photos (${result['cols']}x${result['rows']})',
          );
          developer.log(
            'Final verification: ${verification['photos']} photos (${verification['cols']}x${verification['rows']})',
          );

          if (result['photos'] != verification['photos']) {
            developer.log(
              '❌ MISMATCH! Preview: ${result['photos']}, Final: ${verification['photos']}',
            );
          } else {
            developer.log('✅ Match: ${result['photos']} photos');
          }
        }
      }
    }
  }

  // Simulates the preview calculation from output_selection_screen.dart
  static Map<String, double> calculateDimensionsFromPhotoCount(
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

  // Simulates the preview calculation for by-dimensions mode
  static Map<String, double> calculatePhotosFromDimensions(
    double passportWidthCm,
    double passportHeightCm,
    double widthCm,
    double heightCm,
    double marginMm,
    int dpi,
  ) {
    final widthPx = (widthCm / 2.54 * dpi);
    final heightPx = (heightCm / 2.54 * dpi);
    final passportWidthPx = (passportWidthCm / 2.54 * dpi);
    final passportHeightPx = (passportHeightCm / 2.54 * dpi);
    final marginPx = (marginMm / 10.0 / 2.54 * dpi);

    final cols = ((widthPx + marginPx) / (passportWidthPx + marginPx)).floor();
    final rows = ((heightPx + marginPx) / (passportHeightPx + marginPx))
        .floor();

    return {
      'width': widthCm,
      'height': heightCm,
      'photos': (cols * rows).toDouble(),
      'cols': cols.toDouble(),
      'rows': rows.toDouble(),
    };
  }

  // Simulates the final calculation from result_screen.dart
  static Map<String, double> verifyCalculation(
    double passportWidthCm,
    double passportHeightCm,
    double collageWidthCm,
    double collageHeightCm,
    double marginMm,
    int dpi,
  ) {
    // This matches the result_screen.dart calculation exactly
    final marginCm = marginMm / 10.0; // Convert mm to cm
    final passportWidthPxFloat = (passportWidthCm / 2.54 * dpi);
    final passportHeightPxFloat = (passportHeightCm / 2.54 * dpi);
    final collageWidthPxFloat = (collageWidthCm / 2.54 * dpi);
    final collageHeightPxFloat = (collageHeightCm / 2.54 * dpi);
    final marginPxFloat = (marginCm / 2.54 * dpi);

    // Calculate grid using floating point (same as preview)
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
}
