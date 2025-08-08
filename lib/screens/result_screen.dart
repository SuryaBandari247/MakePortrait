import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../theme/app_colors.dart';
import '../widgets/celebration_popper.dart';
import 'splash_screen_launcher.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List croppedImageBytes;
  final double passportWidthCm;
  final double passportHeightCm;
  final int dpi;
  final String selectedSize;
  final bool isCollage;
  final double? collageWidth;
  final double? collageHeight;
  final double marginMm; // Margin in millimeters
  final int? targetPhotoCount; // Target number of photos to place

  const ResultScreen({
    required this.croppedImageBytes,
    required this.passportWidthCm,
    required this.passportHeightCm,
    required this.dpi,
    required this.selectedSize,
    required this.isCollage,
    this.collageWidth,
    this.collageHeight,
    this.marginMm = 2.5, // Default to 2.5mm
    this.targetPhotoCount, // Default will fill the grid
    super.key,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Uint8List? _finalImageBytes;
  bool _isGenerating = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateFinalImage();
  }

  Future<void> _generateFinalImage() async {
    try {
      setState(() {
        _isGenerating = true;
        _error = null;
      });

      if (widget.isCollage &&
          widget.collageWidth != null &&
          widget.collageHeight != null) {
        // Generate collage
        await _generateCollage();
      } else {
        // Generate single photo
        await _generateSinglePhoto();
      }

      setState(() {
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = 'Error generating image: $e';
      });
    }
  }

  Future<void> _generateSinglePhoto() async {
    // Decode the cropped image
    img.Image? image = img.decodeImage(widget.croppedImageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to exact passport dimensions
    final widthPx = (widget.passportWidthCm / 2.54 * widget.dpi).round();
    final heightPx = (widget.passportHeightCm / 2.54 * widget.dpi).round();

    img.Image resized = img.copyResize(image, width: widthPx, height: heightPx);

    setState(() {
      _finalImageBytes = Uint8List.fromList(img.encodePng(resized));
    });
  }

  Future<void> _generateCollage() async {
    // Decode the cropped image
    img.Image? originalImage = img.decodeImage(widget.croppedImageBytes);
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // 🔥 CRITICAL FIX: Use SAME grid calculation as preview!
    // Don't use A4-optimized dimensions - calculate grid directly from user's photo count

    // Use the margin passed from OutputSelectionScreen (in mm, convert to cm)
    final marginCm = widget.marginMm / 10.0; // Convert mm to cm

    final passportWidthPx = (widget.passportWidthCm / 2.54 * widget.dpi);
    final passportHeightPx = (widget.passportHeightCm / 2.54 * widget.dpi);
    final marginPx = (marginCm / 2.54 * widget.dpi);

    // Use IDENTICAL logic as _generateCollagePreview to get the EXACT same grid
    int bestCols = 1, bestRows = 1;
    double bestRatio = double.infinity;
    final targetPhotoCount = widget.targetPhotoCount ?? 6;

    for (int testCols = 1; testCols <= targetPhotoCount; testCols++) {
      int testRows = (targetPhotoCount / testCols).ceil();
      int totalSlots = testCols * testRows;

      if (totalSlots >= targetPhotoCount) {
        double width = testCols * passportWidthPx + (testCols - 1) * marginPx;
        double height = testRows * passportHeightPx + (testRows - 1) * marginPx;
        double ratio = width / height;
        double targetRatio = 1.414; // A4 aspect ratio
        double ratioDiff = (ratio - 1 / targetRatio).abs();

        double priority = ratioDiff;
        if (totalSlots == targetPhotoCount) {
          priority -= 1000; // Huge preference for exact match
        }

        if (priority < bestRatio) {
          bestRatio = priority;
          bestCols = testCols;
          bestRows = testRows;
        }
      }
    }

    // NOW we have the EXACT same grid that was chosen in preview
    final cols = bestCols;
    final rows = bestRows;

    debugPrint(
      '🔥 FINAL: Using EXACT chosen grid ${cols}x${rows} for ${targetPhotoCount} photos',
    );

    // Calculate actual collage dimensions from this grid
    final collageWidthPx = (cols * passportWidthPx + (cols - 1) * marginPx)
        .round();
    final collageHeightPx = (rows * passportHeightPx + (rows - 1) * marginPx)
        .round();

    // Resize passport photo
    img.Image resizedPhoto = img.copyResize(
      originalImage,
      width: passportWidthPx.round(),
      height: passportHeightPx.round(),
    );

    // Create collage
    final collage = img.Image(width: collageWidthPx, height: collageHeightPx);
    final white = img.ColorInt32.rgb(255, 255, 255);
    final marker = img.ColorInt32.rgb(
      170,
      170,
      170,
    ); // light gray for cut lines

    // Fill with white background
    for (int y = 0; y < collageHeightPx; y++) {
      for (int x = 0; x < collageWidthPx; x++) {
        collage.setPixel(x, y, white);
      }
    }

    // Place photos - Honor user's target photo count
    int photosToPlace = widget.targetPhotoCount ?? (rows * cols);
    int photosPlaced = 0;

    debugPrint(
      'FINAL RESULT: Will place $photosToPlace photos (user wanted ${widget.targetPhotoCount})',
    );
    debugPrint('🔥 FINAL: Grid size is ${cols}x${rows} = ${cols * rows} slots');
    debugPrint(
      '🔥 FINAL: Collage size is ${collageWidthPx}x${collageHeightPx} pixels',
    );
    debugPrint(
      '🔥 FINAL: Photo size is ${passportWidthPx.round()}x${passportHeightPx.round()} pixels',
    );

    for (int row = 0; row < rows && photosPlaced < photosToPlace; row++) {
      debugPrint('🔥 FINAL: Starting row $row (max: ${rows - 1})');
      for (int col = 0; col < cols && photosPlaced < photosToPlace; col++) {
        debugPrint('🔥 FINAL: Processing column $col (max: ${cols - 1})');
        final x = (col * (passportWidthPx + marginPx)).round();
        final y = (row * (passportHeightPx + marginPx)).round();

        debugPrint(
          '🔥 FINAL: Placing photo ${photosPlaced + 1} at grid [${col}, ${row}] => position (${x}, ${y})',
        );

        // Draw the image
        for (int iy = 0; iy < passportHeightPx.round(); iy++) {
          for (int ix = 0; ix < passportWidthPx.round(); ix++) {
            if (ix < resizedPhoto.width && iy < resizedPhoto.height) {
              final px = resizedPhoto.getPixel(ix, iy);
              int cx = x + ix;
              int cy = y + iy;
              if (cx < collageWidthPx && cy < collageHeightPx) {
                collage.setPixel(cx, cy, px);
              }
            }
          }
        }
        photosPlaced++;
        debugPrint('🔥 FINAL: Photo ${photosPlaced} placed successfully');
      }
    }

    debugPrint('FINAL RESULT: Actually placed $photosPlaced photos');

    // Draw vertical markers
    for (int col = 1; col < cols; col++) {
      int markerX = (col * (passportWidthPx + marginPx) - marginPx).round();
      for (int y = 0; y < collageHeightPx; y++) {
        if (markerX >= 0 && markerX < collageWidthPx) {
          collage.setPixel(markerX, y, marker);
        }
      }
    }

    // Draw horizontal markers
    for (int row = 1; row < rows; row++) {
      int markerY = (row * (passportHeightPx + marginPx) - marginPx).round();
      for (int x = 0; x < collageWidthPx; x++) {
        if (markerY >= 0 && markerY < collageHeightPx) {
          collage.setPixel(x, markerY, marker);
        }
      }
    }

    setState(() {
      _finalImageBytes = Uint8List.fromList(img.encodePng(collage));
    });
  }

  Future<void> _saveToGallery() async {
    if (_finalImageBytes == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final fileName = widget.isCollage
          ? 'passport_collage_${DateTime.now().millisecondsSinceEpoch}.png'
          : 'passport_photo_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await ImageGallerySaverPlus.saveImage(
        _finalImageBytes!,
        name: fileName,
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        // Show success animation
        if (mounted) {
          await CelebrationPopper.show(context);
        }

        // Navigate back to home
        if (mounted) {
          // Use pushAndRemoveUntil to ensure we go to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const SplashScreenLauncher(),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
            Expanded(
              child: Text(
                widget.isCollage ? 'Passport Collage' : 'Passport Photo',
                style: const TextStyle(
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
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kPrimaryGreen),
                  SizedBox(height: 16),
                  Text(
                    'Generating your result...',
                    style: TextStyle(
                      fontSize: 16,
                      color: kPrimaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _generateFinalImage,
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: kCream,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Image info card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.isCollage ? Icons.grid_on : Icons.photo,
                                color: kPrimaryGreen,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isCollage
                                    ? 'Passport Collage'
                                    : 'Passport Photo',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: kPrimaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Size:',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      widget.selectedSize,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dimensions:',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      widget.isCollage
                                          ? '${widget.collageWidth!.toStringAsFixed(1)} × ${widget.collageHeight!.toStringAsFixed(1)} cm'
                                          : '${widget.passportWidthCm.toStringAsFixed(1)} × ${widget.passportHeightCm.toStringAsFixed(1)} cm',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
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

                  const SizedBox(height: 16),

                  // Result image
                  if (_finalImageBytes != null)
                    Card(
                      elevation: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
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
                                  _finalImageBytes!,
                                  fit: BoxFit.contain,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '✨ Your result is ready!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: kPrimaryGreen),
                            foregroundColor: kPrimaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: kPrimaryGreen,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isSaving || _finalImageBytes == null
                              ? null
                              : _saveToGallery,
                          style: FilledButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            foregroundColor: kCream,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kCream,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Saving...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, color: kCream),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save to Gallery',
                                      style: TextStyle(
                                        color: kCream,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
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
}
