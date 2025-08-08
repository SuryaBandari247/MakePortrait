import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../theme/app_colors.dart';
import '../utils/collage_debug_tester.dart';
import '../utils/specific_collage_test.dart';
import '../utils/collage_calculation_fixer.dart';
import '../utils/comprehensive_user_input_tester.dart';
import '../utils/runtime_user_input_validator.dart';
import '../utils/interactive_test_runner.dart';
import '../utils/standalone_test_runner.dart';
import '../utils/canada_6_photo_diagnostic.dart';
import '../utils/complete_validation_runner.dart';
import '../utils/final_verification_test.dart';
import 'result_screen.dart';

class OutputSelectionScreen extends StatefulWidget {
  final Uint8List croppedImageBytes;
  final double passportWidthCm;
  final double passportHeightCm;
  final int dpi;
  final String selectedSize;

  const OutputSelectionScreen({
    required this.croppedImageBytes,
    required this.passportWidthCm,
    required this.passportHeightCm,
    required this.dpi,
    required this.selectedSize,
    super.key,
  });

  @override
  State<OutputSelectionScreen> createState() => _OutputSelectionScreenState();
}

class _OutputSelectionScreenState extends State<OutputSelectionScreen> {
  bool _isCollage = false;
  bool _usePhotoCount = true;
  int _targetPhotoCount = 6;
  double _marginMm = 2.5;
  double _customWidth = 10.0;
  double _customHeight = 15.0;
  String _customUnit = 'cm';

  // Text controllers to manage field values
  late TextEditingController _photoCountController;
  late TextEditingController _marginController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _customMarginController;

  // Calculated values
  int _calculatedPhotos = 0;
  double _calculatedWidth = 0.0;
  double _calculatedHeight = 0.0;
  Uint8List? _collagePreviewBytes;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _photoCountController = TextEditingController(
      text: _targetPhotoCount.toString(),
    );
    _marginController = TextEditingController(text: _marginMm.toString());
    _widthController = TextEditingController(text: _customWidth.toString());
    _heightController = TextEditingController(text: _customHeight.toString());
    _customMarginController = TextEditingController(text: _marginMm.toString());

    // 🔥 FOCUSED DIAGNOSTIC FOR CANADA 6-PHOTO BUG
    debugPrint('🔥 RUNNING CANADA 6-PHOTO DIAGNOSTIC');
    Canada6PhotoDiagnostic.diagnoseCanada6PhotoIssue();
    Canada6PhotoDiagnostic.testFix();

    // 🧪 RUN COMPREHENSIVE USER INPUT TESTS
    debugPrint('🧪 STARTING COMPREHENSIVE USER INPUT VALIDATION TESTS');
    ComprehensiveUserInputTester.runAllTests();

    // 🎯 RUN INTERACTIVE TESTS FOR CURRENT SCENARIO
    debugPrint('🎯 RUNNING INTERACTIVE TESTS FOR: ${widget.selectedSize}');
    InteractiveTestRunner.runFullTestSuite();

    // 🚀 RUN COMPLETE STANDALONE TEST SUITE
    debugPrint('🚀 EXECUTING COMPLETE STANDALONE TEST SUITE');
    StandaloneTestRunner.runCompleteTestSuite(); // Run debug test to identify calculation differences
    CollageDebugTester.testAllCombinations();

    // Run specific Canada scenario test
    SpecificCollageTest.testCanadaScenario();

    // Run detailed debug for Canada issue
    CollageCalculationFixer.debugCanadaIssue();

    // 🚀 RUN ALL COMPREHENSIVE TESTS FOR VALIDATION
    debugPrint('\n🚀 RUNNING COMPLETE VALIDATION TEST SUITE');
    CompleteValidationRunner.runAllValidationTests();
    CompleteValidationRunner.runAllCountryTests();

    // 🎯 RUN FINAL VERIFICATION FOR CRITICAL SCENARIO
    debugPrint('\n🎯 RUNNING FINAL VERIFICATION TEST');
    FinalVerificationTest.runCanada6PhotoVerification();
    FinalVerificationTest.runAllCountriesQuickTest();

    _updateCalculations();
  }

  @override
  void dispose() {
    _photoCountController.dispose();
    _marginController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _customMarginController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    if (!_isCollage) return;

    if (_usePhotoCount) {
      _calculateDimensionsFromPhotoCount();
      // Update custom dimension fields to match calculated values
      _customWidth = _calculatedWidth;
      _customHeight = _calculatedHeight;
      _customUnit = 'cm';
      _widthController.text = _calculatedWidth.toStringAsFixed(1);
      _heightController.text = _calculatedHeight.toStringAsFixed(1);
    } else {
      _calculatePhotosFromDimensions();
    }
    _generateCollagePreview();
  }

  void _calculateDimensionsFromPhotoCount() {
    final passportWidthPx = (widget.passportWidthCm / 2.54 * widget.dpi);
    final passportHeightPx = (widget.passportHeightCm / 2.54 * widget.dpi);
    final marginPx = (_marginMm / 10.0 / 2.54 * widget.dpi);

    // CRITICAL FIX: Honor user's photo count requirement
    // Find grid that fits EXACTLY the requested photos or more
    int bestCols = 1, bestRows = 1;
    double bestRatio = double.infinity;

    // Try all possible grids that can fit AT LEAST the target photos
    for (int cols = 1; cols <= _targetPhotoCount; cols++) {
      int rows = (_targetPhotoCount / cols).ceil();
      int totalSlots = cols * rows;

      // Only consider grids that fit the target photos
      if (totalSlots >= _targetPhotoCount) {
        double width = cols * passportWidthPx + (cols - 1) * marginPx;
        double height = rows * passportHeightPx + (rows - 1) * marginPx;
        double ratio = width / height;
        double targetRatio = 1.414; // A4 aspect ratio
        double ratioDiff = (ratio - 1 / targetRatio).abs();

        // Prefer exact matches, then closest to A4 ratio
        double priority = ratioDiff;
        if (totalSlots == _targetPhotoCount) {
          priority -= 1000; // Huge preference for exact match
        }

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

    _calculatedWidth = finalWidthPx * 2.54 / widget.dpi;
    _calculatedHeight = finalHeightPx * 2.54 / widget.dpi;

    // ALWAYS use the user's target photo count, not grid capacity
    _calculatedPhotos = _targetPhotoCount;

    // 🧪 REAL-TIME VALIDATION: Photo count scenario
    RuntimeUserInputValidator.validateCurrentState(
      scenario: 'Photo Count Mode - ${widget.selectedSize}',
      userPhotos: _targetPhotoCount,
      calculatedPhotos: _calculatedPhotos,
      userWidth: 0, // Not applicable in photo count mode
      userHeight: 0, // Not applicable in photo count mode
      actualWidth: _calculatedWidth,
      actualHeight: _calculatedHeight,
      userMargin: _marginMm,
    );

    // Debug info
    debugPrint('USER WANTS: $_targetPhotoCount photos');
    debugPrint(
      'GRID CHOSEN: ${bestCols}x${bestRows} = ${bestCols * bestRows} slots',
    );
    debugPrint('WILL PLACE: $_calculatedPhotos photos (user request honored)');
  }

  void _calculatePhotosFromDimensions() {
    double widthCm = _customWidth;
    double heightCm = _customHeight;
    if (_customUnit == 'inch') {
      widthCm = _customWidth * 2.54;
      heightCm = _customHeight * 2.54;
    }

    final widthPx = (widthCm / 2.54 * widget.dpi);
    final heightPx = (heightCm / 2.54 * widget.dpi);
    final passportWidthPx = (widget.passportWidthCm / 2.54 * widget.dpi);
    final passportHeightPx = (widget.passportHeightCm / 2.54 * widget.dpi);
    final marginPx = (_marginMm / 10.0 / 2.54 * widget.dpi);

    // Use CORRECT formula with floating-point tolerance for precision issues:
    // If width = cols * photoWidth + (cols-1) * margin
    // Then: width = cols * (photoWidth + margin) - margin
    // So: cols = (width + margin) / (photoWidth + margin)
    final colsExact = (widthPx + marginPx) / (passportWidthPx + marginPx);
    final rowsExact = (heightPx + marginPx) / (passportHeightPx + marginPx);

    // Add small tolerance (0.01) to handle floating-point precision issues
    final cols = (colsExact + 0.01).floor();
    final rows = (rowsExact + 0.01).floor();

    // 🔍 DEBUG: Let's see exactly what's being calculated
    debugPrint('🔍 DIMENSION CALCULATION DEBUG:');
    debugPrint(
      '   Paper: ${widthCm.toStringAsFixed(1)}x${heightCm.toStringAsFixed(1)}cm',
    );
    debugPrint(
      '   Photo: ${widget.passportWidthCm}x${widget.passportHeightCm}cm',
    );
    debugPrint(
      '   Margin: ${_marginMm}mm = ${(_marginMm / 10.0).toStringAsFixed(2)}cm',
    );
    debugPrint(
      '   Paper pixels: ${widthPx.toStringAsFixed(0)}x${heightPx.toStringAsFixed(0)}px',
    );
    debugPrint(
      '   Photo pixels: ${passportWidthPx.toStringAsFixed(0)}x${passportHeightPx.toStringAsFixed(0)}px',
    );
    debugPrint('   Margin pixels: ${marginPx.toStringAsFixed(0)}px');
    debugPrint(
      '   Cols calc: (${widthPx.toStringAsFixed(0)} + ${marginPx.toStringAsFixed(0)}) / (${passportWidthPx.toStringAsFixed(0)} + ${marginPx.toStringAsFixed(0)}) = ${colsExact.toStringAsFixed(4)} → $cols',
    );
    debugPrint(
      '   Rows calc: (${heightPx.toStringAsFixed(0)} + ${marginPx.toStringAsFixed(0)}) / (${passportHeightPx.toStringAsFixed(0)} + ${marginPx.toStringAsFixed(0)}) = ${rowsExact.toStringAsFixed(4)} → $rows',
    );
    debugPrint('   Grid: ${cols}x${rows} = ${cols * rows} photos');

    _calculatedPhotos = cols * rows;
    _calculatedWidth = widthCm;
    _calculatedHeight = heightCm;

    // 🧪 REAL-TIME VALIDATION: Dimension scenario
    RuntimeUserInputValidator.validateCurrentState(
      scenario: 'Dimension Mode - ${widget.selectedSize}',
      userPhotos: 0, // Not applicable in dimension mode
      calculatedPhotos: _calculatedPhotos,
      userWidth: _customWidth,
      userHeight: _customHeight,
      actualWidth: _calculatedWidth,
      actualHeight: _calculatedHeight,
      userMargin: _marginMm,
      unit: _customUnit,
    );
  }

  void _generateCollagePreview() {
    if (!_isCollage || _calculatedPhotos <= 0) return;

    try {
      // 🔥 CRITICAL FIX: Don't calculate grid from dimensions!
      // Instead, use the EXACT grid that was chosen for user's photo count!

      // Step 1: Re-calculate the SAME grid that was chosen in _calculateDimensionsFromPhotoCount
      final passportWidthPx = (widget.passportWidthCm / 2.54 * widget.dpi);
      final passportHeightPx = (widget.passportHeightCm / 2.54 * widget.dpi);
      final marginPx = (_marginMm / 10.0 / 2.54 * widget.dpi);

      // 🔥 CRITICAL FIX: Use the correct photo count based on mode
      final effectivePhotoCount = _usePhotoCount
          ? _targetPhotoCount
          : _calculatedPhotos;

      // Use IDENTICAL logic as the calculation method to get the EXACT same grid
      int bestCols = 1, bestRows = 1;
      double bestRatio = double.infinity;

      if (_usePhotoCount) {
        // Photo Count Mode: Find optimal grid for target photo count
        for (int cols = 1; cols <= effectivePhotoCount; cols++) {
          int rows = (effectivePhotoCount / cols).ceil();
          int totalSlots = cols * rows;

          if (totalSlots >= effectivePhotoCount) {
            double width = cols * passportWidthPx + (cols - 1) * marginPx;
            double height = rows * passportHeightPx + (rows - 1) * marginPx;
            double ratio = width / height;
            double targetRatio = 1.414; // A4 aspect ratio
            double ratioDiff = (ratio - 1 / targetRatio).abs();

            double priority = ratioDiff;
            if (totalSlots == effectivePhotoCount) {
              priority -= 1000; // Huge preference for exact match
            }

            if (priority < bestRatio) {
              bestRatio = priority;
              bestCols = cols;
              bestRows = rows;
            }
          }
        }
      } else {
        // Dimension Mode: Use the EXACT SAME grid calculation as _calculatePhotosFromDimensions()
        double widthCm = _customWidth;
        double heightCm = _customHeight;
        if (_customUnit == 'inch') {
          widthCm = _customWidth * 2.54;
          heightCm = _customHeight * 2.54;
        }

        final widthPx = (widthCm / 2.54 * widget.dpi);
        final heightPx = (heightCm / 2.54 * widget.dpi);

        // Use the EXACT same formula with floating-point tolerance
        final colsExact = (widthPx + marginPx) / (passportWidthPx + marginPx);
        final rowsExact = (heightPx + marginPx) / (passportHeightPx + marginPx);

        // Add small tolerance (0.01) to handle floating-point precision issues
        bestCols = (colsExact + 0.01).floor();
        bestRows = (rowsExact + 0.01).floor();
      }

      // NOW we have the EXACT same grid that was chosen
      final cols = bestCols;
      final rows = bestRows;

      debugPrint(
        '🔥 PREVIEW: Using EXACT chosen grid ${cols}x${rows} for ${effectivePhotoCount} photos',
      );

      // Step 2: Create scaled preview using this EXACT grid
      final previewScale = 0.3;
      final passportWidthPxPreview = passportWidthPx * previewScale;
      final passportHeightPxPreview = passportHeightPx * previewScale;
      final marginPxPreview = marginPx * previewScale;
      final collageWidthPxPreview =
          (cols * passportWidthPx + (cols - 1) * marginPx) * previewScale;
      final collageHeightPxPreview =
          (rows * passportHeightPx + (rows - 1) * marginPx) * previewScale;

      // Decode and resize the cropped image
      img.Image? originalImage = img.decodeImage(widget.croppedImageBytes);
      if (originalImage == null) return;

      img.Image resizedPhoto = img.copyResize(
        originalImage,
        width: passportWidthPxPreview.round(),
        height: passportHeightPxPreview.round(),
      );

      // Create collage
      final collage = img.Image(
        width: collageWidthPxPreview.round(),
        height: collageHeightPxPreview.round(),
      );
      final white = img.ColorInt32.rgb(255, 255, 255);

      // Fill with white background
      for (int y = 0; y < collageHeightPxPreview.round(); y++) {
        for (int x = 0; x < collageWidthPxPreview.round(); x++) {
          collage.setPixel(x, y, white);
        }
      }

      // Place photos using the EXACT grid - honor effective photo count exactly
      int photosPlaced = 0;
      for (
        int row = 0;
        row < rows && photosPlaced < effectivePhotoCount;
        row++
      ) {
        for (
          int col = 0;
          col < cols && photosPlaced < effectivePhotoCount;
          col++
        ) {
          final x = col * (passportWidthPxPreview + marginPxPreview);
          final y = row * (passportHeightPxPreview + marginPxPreview);

          for (int iy = 0; iy < passportHeightPxPreview.round(); iy++) {
            for (int ix = 0; ix < passportWidthPxPreview.round(); ix++) {
              if (ix < resizedPhoto.width && iy < resizedPhoto.height) {
                final px = resizedPhoto.getPixel(ix, iy);
                int cx = x.round() + ix;
                int cy = y.round() + iy;
                if (cx < collageWidthPxPreview.round() &&
                    cy < collageHeightPxPreview.round()) {
                  collage.setPixel(cx, cy, px);
                }
              }
            }
          }
          photosPlaced++;
        }
      }

      debugPrint(
        'PREVIEW: Placed $photosPlaced photos (user wanted $effectivePhotoCount)',
      );

      setState(() {
        _collagePreviewBytes = Uint8List.fromList(img.encodePng(collage));
      });
    } catch (e) {
      // Handle error silently
      setState(() {
        _collagePreviewBytes = null;
      });
    }
  }

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
                'Choose Output Type',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview of cropped passport photo
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Passport Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: kPrimaryGreen, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              widget.croppedImageBytes,
                              width: 80,
                              height:
                                  80 *
                                  (widget.passportHeightCm /
                                      widget.passportWidthCm),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.selectedSize,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.passportWidthCm.toStringAsFixed(1)} × ${widget.passportHeightCm.toStringAsFixed(1)} cm',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Output type selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like to create?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPhotoTypeOption(
                            title: 'Single Photo',
                            subtitle: 'One passport photo',
                            imagePath: 'assets/single_passport.png',
                            isSelected: !_isCollage,
                            onTap: () {
                              setState(() {
                                _isCollage = false;
                                _collagePreviewBytes = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPhotoTypeOption(
                            title: 'Collage',
                            subtitle: 'Multiple photos on one page',
                            imagePath: 'assets/collage_passport.png',
                            isSelected: _isCollage,
                            onTap: () {
                              setState(() {
                                _isCollage = true;
                                _updateCalculations();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Collage configuration (show only when collage is selected)
            if (_isCollage) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collage Configuration',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Configuration mode selection
                      Column(
                        children: [
                          RadioListTile<bool>(
                            title: const Text('By Photo Count'),
                            value: true,
                            groupValue: _usePhotoCount,
                            onChanged: (value) {
                              setState(() {
                                _usePhotoCount = value!;
                                _updateCalculations();
                              });
                            },
                            activeColor: kPrimaryGreen,
                          ),
                          RadioListTile<bool>(
                            title: const Text('By Paper Size'),
                            value: false,
                            groupValue: _usePhotoCount,
                            onChanged: (value) {
                              setState(() {
                                _usePhotoCount = value!;
                                _updateCalculations();
                              });
                            },
                            activeColor: kPrimaryGreen,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Configuration inputs
                      if (_usePhotoCount) ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _photoCountController,
                                decoration: const InputDecoration(
                                  labelText: 'Number of Photos',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final val = int.tryParse(v);
                                  if (val != null && val > 0 && val <= 100) {
                                    setState(() {
                                      _targetPhotoCount = val;
                                      _updateCalculations();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _marginController,
                                decoration: const InputDecoration(
                                  labelText: 'Margin (mm)',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (v) {
                                  final val = double.tryParse(v);
                                  if (val != null && val >= 0 && val <= 20) {
                                    setState(() {
                                      _marginMm = val;
                                      _customMarginController.text = val
                                          .toString();
                                      _updateCalculations();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _widthController,
                                decoration: const InputDecoration(
                                  labelText: 'Width',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (v) {
                                  final val = double.tryParse(v);
                                  if (val != null && val > 0) {
                                    setState(() {
                                      _customWidth = val;
                                      _updateCalculations();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                decoration: const InputDecoration(
                                  labelText: 'Height',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (v) {
                                  final val = double.tryParse(v);
                                  if (val != null && val > 0) {
                                    setState(() {
                                      _customHeight = val;
                                      _updateCalculations();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _customUnit,
                                decoration: const InputDecoration(
                                  labelText: 'Unit',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'cm',
                                    child: Text('cm'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inch',
                                    child: Text('inch'),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    _customUnit = v ?? 'cm';
                                    _updateCalculations();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customMarginController,
                          decoration: const InputDecoration(
                            labelText: 'Margin (mm)',
                            helperText: 'Space between photos',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) {
                            final val = double.tryParse(v);
                            if (val != null && val >= 0 && val <= 20) {
                              setState(() {
                                _marginMm = val;
                                _marginController.text = val.toString();
                                _updateCalculations();
                              });
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Preview and results
              Card(
                elevation: 2,
                color: kPrimaryGreen.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.preview, color: kPrimaryGreen),
                          SizedBox(width: 8),
                          Text(
                            'Collage Preview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: kPrimaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Preview image
                          if (_collagePreviewBytes != null)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: kPrimaryGreen,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  _collagePreviewBytes!,
                                  width: 150,
                                  height:
                                      150 *
                                      (_calculatedHeight / _calculatedWidth),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 150,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),

                          const SizedBox(width: 16),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Final Size:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${_calculatedWidth.toStringAsFixed(1)} × ${_calculatedHeight.toStringAsFixed(1)} cm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: kPrimaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Photos:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '$_calculatedPhotos photos',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: kPrimaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Margin: ${_marginMm.toStringAsFixed(1)} mm',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: kPrimaryGreen),
                      foregroundColor: kPrimaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: kPrimaryGreen, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_isCollage) {
                        // Navigate to result screen for collage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultScreen(
                              croppedImageBytes: widget.croppedImageBytes,
                              passportWidthCm: widget.passportWidthCm,
                              passportHeightCm: widget.passportHeightCm,
                              dpi: widget.dpi,
                              selectedSize: widget.selectedSize,
                              isCollage: true,
                              collageWidth: _calculatedWidth,
                              collageHeight: _calculatedHeight,
                              marginMm: _marginMm, // Pass the configured margin
                              targetPhotoCount:
                                  _targetPhotoCount, // CRITICAL: Pass user's photo count requirement
                            ),
                          ),
                        );
                      } else {
                        // Navigate to result screen for single photo
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultScreen(
                              croppedImageBytes: widget.croppedImageBytes,
                              passportWidthCm: widget.passportWidthCm,
                              passportHeightCm: widget.passportHeightCm,
                              dpi: widget.dpi,
                              selectedSize: widget.selectedSize,
                              isCollage: false,
                              marginMm:
                                  _marginMm, // Pass margin for consistency
                            ),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: kCream,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isCollage ? 'Create Collage' : 'Create Photo',
                      style: const TextStyle(color: kCream, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTypeOption({
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? kPrimaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? kPrimaryGreen.withOpacity(0.1)
              : Colors.transparent,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Radio button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<bool>(
                  value: title == 'Single Photo' ? false : true,
                  groupValue: _isCollage,
                  onChanged: (value) => onTap(),
                  activeColor: kPrimaryGreen,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? kPrimaryGreen : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? kPrimaryGreen.withOpacity(0.8)
                              : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
