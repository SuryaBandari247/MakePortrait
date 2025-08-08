// Canada 6-photo test calculation
// Passport: 5.0 x 7.0 cm
// Target: 6 photos
// Margin: 2.5mm = 0.25cm
// DPI: 300

void main() {
  testCanadaCalculation();
}

void testCanadaCalculation() {
  final passportWidthCm = 5.0;
  final passportHeightCm = 7.0;
  final targetPhotos = 6;
  final marginMm = 2.5;
  final marginCm = marginMm / 10.0; // 0.25cm
  final dpi = 300;

  print('=== CANADA CALCULATION TEST ===');

  // Test all possible arrangements for 6 photos
  for (int cols = 1; cols <= 6; cols++) {
    int rows = (targetPhotos / cols).ceil();
    if (cols * rows >= targetPhotos) {
      // Calculate dimensions using CURRENT method (from output_selection_screen.dart)
      final passportWidthPx = (passportWidthCm / 2.54 * dpi);
      final passportHeightPx = (passportHeightCm / 2.54 * dpi);
      final marginPx = (marginCm / 2.54 * dpi);

      final widthPx = cols * passportWidthPx + (cols - 1) * marginPx;
      final heightPx = rows * passportHeightPx + (rows - 1) * marginPx;

      final widthCm = widthPx * 2.54 / dpi;
      final heightCm = heightPx * 2.54 / dpi;

      // Now verify with RESULT method (from result_screen.dart)
      final collageWidthPxFloat = (widthCm / 2.54 * dpi);
      final collageHeightPxFloat = (heightCm / 2.54 * dpi);

      final verifyMarginPx = (marginCm / 2.54 * dpi);
      final verifyPassportWPx = (passportWidthCm / 2.54 * dpi);
      final verifyPassportHPx = (passportHeightCm / 2.54 * dpi);

      final verifyCols =
          ((collageWidthPxFloat + verifyMarginPx) /
                  (verifyPassportWPx + verifyMarginPx))
              .floor();
      final verifyRows =
          ((collageHeightPxFloat + verifyMarginPx) /
                  (verifyPassportHPx + verifyMarginPx))
              .floor();

      print(
        'Layout ${cols}x${rows}: ${widthCm.toStringAsFixed(2)}x${heightCm.toStringAsFixed(2)}cm',
      );
      print('  Preview: ${cols * rows} photos');
      print(
        '  Final verification: ${verifyCols * verifyRows} photos (${verifyCols}x${verifyRows})',
      );
      print('  Match: ${cols * rows == verifyCols * verifyRows}');
      print('');
    }
  }
}
