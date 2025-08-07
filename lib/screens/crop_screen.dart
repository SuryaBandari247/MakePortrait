import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:crop_your_image/crop_your_image.dart';
import '../widgets/plus_control.dart';
import 'output_selection_screen.dart';

class CropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final double? aspectRatio;
  final double targetWidth;
  final double targetHeight;
  final String unit;
  final int dpi;
  final String? selectedSize;
  const CropScreen({
    required this.imageBytes,
    required this.aspectRatio,
    required this.targetWidth,
    required this.targetHeight,
    required this.unit,
    required this.dpi,
    this.selectedSize,
    super.key,
  });

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> with TickerProviderStateMixin {
  late CropController _controller;
  late Key _cropperKey;
  bool _cropping = false;
  bool _cropperReady = false;
  double? _aspectRatio;
  late AnimationController _zoomAnimationController;
  late Animation<double> _zoomAnimation;

  final List<Map<String, dynamic>> _ratios = [
    {'label': 'Free', 'value': null},
    {'label': '1:1', 'value': 1.0},
    {'label': '3:4', 'value': 3 / 4},
    {'label': '4:3', 'value': 4 / 3},
    {'label': '2:3', 'value': 2 / 3},
    {'label': '3:2', 'value': 3 / 2},
    {'label': '16:9', 'value': 16 / 9},
    {'label': '9:16', 'value': 9 / 16},
  ];
  int _selectedRatioIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CropController();
    _cropperKey = UniqueKey();
    if (widget.aspectRatio != null) {
      _aspectRatio = widget.aspectRatio;
    } else {
      _aspectRatio = null;
    }

    // Initialize zoom animation
    _zoomAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the zoom animation loop after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _zoomAnimationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    super.dispose();
  }

  void _onAspectRatioSelected(int i) {
    setState(() {
      _selectedRatioIndex = i;
      if (i == 0) {
        _aspectRatio = null;
      } else {
        _aspectRatio = _ratios[i]['value'];
      }
      _controller = CropController();
      _cropperKey = UniqueKey();
      _cropperReady = false; // Reset cropper ready state

      // Restart zoom animation when aspect ratio changes
      _zoomAnimationController.reset();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _zoomAnimationController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFixedAspect = widget.aspectRatio != null;
    if (isFixedAspect) {
      _aspectRatio = widget.aspectRatio;
    }
    void resetCropping() {
      if (mounted) {
        setState(() => _cropping = false);
      } else {
        _cropping = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/make_portrait_logo.png', width: 32, height: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Crop Image',
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
        actions: [
          TextButton(
            onPressed: _cropping ? null : () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kCream)),
          ),
        ],
      ),
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            if (isFixedAspect)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Builder(
                  builder: (context) {
                    String unit = widget.unit;
                    double w = widget.targetWidth;
                    double h = widget.targetHeight;
                    final selectedSize = widget.selectedSize;
                    if (selectedSize != null &&
                        selectedSize.toLowerCase().contains('inch')) {
                      unit = 'inch';
                      w = (widget.targetWidth / 2.54);
                      h = (widget.targetHeight / 2.54);
                    } else if (selectedSize != null &&
                        selectedSize.toLowerCase().contains('mm')) {
                      unit = 'cm';
                    }
                    String dimStr = unit == 'inch'
                        ? '${w.toStringAsFixed(2)} x ${h.toStringAsFixed(2)} in'
                        : '${w.toStringAsFixed(2)} x ${h.toStringAsFixed(2)} cm';
                    return Text(
                      'Crop to passport size: $dimStr',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: kPrimaryGreen,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            if (!isFixedAspect)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    children: List.generate(_ratios.length, (i) {
                      final selected = i == _selectedRatioIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: OutlinedButton(
                          onPressed: () => _onAspectRatioSelected(i),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? kPrimaryGreen
                                : Colors.transparent,
                            side: BorderSide(color: kPrimaryGreen, width: 2),
                            foregroundColor: selected ? kCream : kPrimaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            _ratios[i]['label'],
                            style: TextStyle(
                              color: selected ? kCream : kPrimaryGreen,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            // Reset button section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Animated zoom tutorial hint
                  AnimatedBuilder(
                    animation: _zoomAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _zoomAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kPrimaryGreen.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pinch,
                                color: kPrimaryGreen.withValues(alpha: 0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pinch to zoom',
                                style: TextStyle(
                                  color: kPrimaryGreen.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Reset button
                  OutlinedButton.icon(
                    onPressed: (_cropping || !_cropperReady)
                        ? null
                        : () {
                            // Reset the crop controller and recreate the cropper
                            setState(() {
                              _controller = CropController();
                              _cropperKey = UniqueKey();
                              _cropperReady = false;
                            });

                            // Restart zoom animation after reset
                            _zoomAnimationController.reset();
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (mounted) {
                                  _zoomAnimationController.repeat(
                                    reverse: true,
                                  );
                                }
                              },
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text(
                      'Reset',
                      style: TextStyle(color: kPrimaryGreen, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(
                  30.0,
                ), // Margin to keep controls in bounds
                child: Crop(
                  key: _cropperKey,
                  controller: _controller,
                  image: widget.imageBytes,
                  aspectRatio: _aspectRatio,
                  baseColor: kCream,
                  maskColor: Colors.black.withValues(alpha: 0.3),
                  onStatusChanged: (status) {
                    if (status == CropStatus.ready && !_cropperReady) {
                      setState(() => _cropperReady = true);
                    }
                  },
                  onCropped: (result) async {
                    Uint8List? bytes;
                    if (result is CropSuccess) {
                      bytes = result.croppedImage;
                    }
                    if (bytes != null && mounted) {
                      // Only navigate to output selection if this is a passport crop (has valid target dimensions)
                      if (widget.targetWidth > 0 && widget.targetHeight > 0) {
                        final outputResult =
                            await Navigator.push<Map<String, dynamic>?>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OutputSelectionScreen(
                                  croppedImageBytes: bytes!,
                                  passportWidthCm: widget.targetWidth,
                                  passportHeightCm: widget.targetHeight,
                                  dpi: widget.dpi,
                                  selectedSize:
                                      widget.selectedSize ?? 'Unknown',
                                ),
                              ),
                            );

                        if (outputResult != null) {
                          // Return both the cropped image and the output configuration
                          Navigator.pop(context, {
                            'croppedImage': bytes,
                            'outputConfig': outputResult,
                          });
                        }
                      } else {
                        // For free crop, just return the image
                        Navigator.pop(context, {'croppedImage': bytes});
                      }
                    }
                    resetCropping();
                  },
                  initialRectBuilder: InitialRectBuilder.withBuilder((
                    viewportRect,
                    imageRect,
                  ) {
                    Rect rect;
                    // Account for corner controls (plus signs) - they are 28x28 pixels
                    const double cornerControlSize = 28.0;
                    const double safetyMargin = 20.0; // Large safety margin
                    const double totalMargin = cornerControlSize + safetyMargin;

                    if (_aspectRatio == null) {
                      // For free aspect ratio, use a very conservative scale and ensure large padding
                      const scale =
                          0.4; // Very conservative scale to keep controls well within bounds
                      final w = (imageRect.width * scale).clamp(
                        100.0,
                        viewportRect.width -
                            totalMargin * 3, // Triple margin for extra safety
                      );
                      final h = (imageRect.height * scale).clamp(
                        100.0,
                        viewportRect.height -
                            totalMargin * 3, // Triple margin for extra safety
                      );
                      final l =
                          viewportRect.left + (viewportRect.width - w) / 2;
                      final t =
                          viewportRect.top + (viewportRect.height - h) / 2;
                      rect = Rect.fromLTWH(l, t, w, h);
                    } else {
                      // For fixed aspect ratio, ensure corner controls stay within bounds
                      final double padX = totalMargin;
                      final double padY = totalMargin;
                      final double maxWidth = (viewportRect.width - padX * 2)
                          .clamp(100.0, double.infinity);
                      final double maxHeight = (viewportRect.height - padY * 2)
                          .clamp(100.0, double.infinity);

                      double cropWidth = maxWidth;
                      double cropHeight = maxHeight;

                      if (_aspectRatio! > 0) {
                        if (maxWidth / maxHeight > _aspectRatio!) {
                          cropHeight = maxHeight;
                          cropWidth = cropHeight * _aspectRatio!;
                        } else {
                          cropWidth = maxWidth;
                          cropHeight = cropWidth / _aspectRatio!;
                        }
                      }

                      // Ensure minimum size
                      cropWidth = cropWidth.clamp(100.0, maxWidth);
                      cropHeight = cropHeight.clamp(100.0, maxHeight);

                      final double left =
                          viewportRect.left +
                          (viewportRect.width - cropWidth) / 2;
                      final double top =
                          viewportRect.top +
                          (viewportRect.height - cropHeight) / 2;

                      rect = Rect.fromLTWH(left, top, cropWidth, cropHeight);
                    }
                    return rect;
                  }),
                  overlayBuilder: (context, rect) {
                    return const SizedBox.shrink();
                  },
                  progressIndicator: const CircularProgressIndicator(),
                  radius: 20,
                  willUpdateScale: (newScale) => newScale < 5,
                  cornerDotBuilder: (size, edgeAlignment) =>
                      PlusControl(backgroundColor: kCream),
                  clipBehavior: Clip.hardEdge, // Prevent overflow
                  interactive: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _cropping
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: kPrimaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: FilledButton(
                      onPressed: (_cropping || !_cropperReady)
                          ? null
                          : () {
                              setState(() => _cropping = true);
                              _controller.crop();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: kCream,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _cropping
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kCream,
                                ),
                              ),
                            )
                          : const Text(
                              'Apply Crop',
                              style: TextStyle(color: kCream),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
