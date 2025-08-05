import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:crop_your_image/crop_your_image.dart';
import '../widgets/plus_control.dart';

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

class _CropScreenState extends State<CropScreen> {
  late CropController _controller;
  late Key _cropperKey;
  bool _cropping = false;
  bool _cropperReady = false;
  double? _aspectRatio;
  Rect? _lastCropRect;

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
    // Optionally, you can show a warning using another mechanism if needed.
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: kPrimaryGreen),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Note: If you zoom in a lot or select a very small crop area, the output image quality may be low.',
                      style: TextStyle(color: kPrimaryGreen),
                    ),
                  ),
                ],
              ),
            ),
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
                      'Crop the image to the required passport size. The crop mask is fixed to the target dimensions or aspect ratio ($dimStr).',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
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
            Expanded(
              child: Crop(
                key: _cropperKey,
                controller: _controller,
                image: widget.imageBytes,
                aspectRatio: _aspectRatio,
                baseColor: kPrimaryGreen,
                maskColor: kPrimaryGreen.withOpacity(0.4),
                onStatusChanged: (status) {
                  if (status == CropStatus.ready && _aspectRatio == null) {
                    _controller.aspectRatio = null;
                  }
                  if (status == CropStatus.ready && !_cropperReady) {
                    setState(() => _cropperReady = true);
                  }
                },
                onCropped: (result) async {
                  Uint8List? bytes;
                  if (result is CropSuccess) {
                    bytes = result.croppedImage;
                    // Optionally, you can show a warning if the crop area is too small
                  }
                  if (bytes != null && mounted) {
                    Navigator.pop(context, bytes);
                  }
                  resetCropping();
                },
                initialRectBuilder: InitialRectBuilder.withBuilder((
                  viewportRect,
                  imageRect,
                ) {
                  Rect rect;
                  if (_aspectRatio == null) {
                    const scale = 0.8;
                    final w = imageRect.width * scale;
                    final h = imageRect.height * scale;
                    final l = imageRect.left + (imageRect.width - w) / 2;
                    final t = imageRect.top + (imageRect.height - h) / 2;
                    rect = Rect.fromLTWH(l, t, w, h);
                  } else {
                    const double padX = 24;
                    const double padY = 32;
                    final double maxWidth = viewportRect.width - padX * 2;
                    final double maxHeight = viewportRect.height - padY * 2;
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
                    final double left =
                        viewportRect.left +
                        (viewportRect.width - cropWidth) / 2;
                    final double top =
                        viewportRect.top +
                        (viewportRect.height - cropHeight) / 2;
                    rect = Rect.fromLTWH(left, top, cropWidth, cropHeight);
                  }
                  _lastCropRect = rect;
                  return rect;
                }),
                overlayBuilder: (context, rect) {
                  return const SizedBox.shrink();
                },
                progressIndicator: const CircularProgressIndicator(),
                radius: 20,
                willUpdateScale: (newScale) => newScale < 5,
                cornerDotBuilder: (size, edgeAlignment) =>
                    PlusControl(backgroundColor: kPrimaryGreen),
                clipBehavior: Clip.none,
                interactive: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _cropping ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryGreen,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: kPrimaryGreen),
                    ),
                  ),
                  FilledButton(
                    onPressed: (_cropping || !_cropperReady)
                        ? null
                        : () {
                            setState(() => _cropping = true);
                            _controller.crop();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: kCream,
                    ),
                    child: _cropping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Apply Crop',
                            style: TextStyle(color: kCream),
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
