import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

// Top-level function for background image decoding
img.Image? decodeImageInBackground(Uint8List bytes) {
  return img.decodeImage(bytes);
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Print to console for debugging
    print('[GlobalError] ${details.exceptionAsString()}');
    if (details.stack != null) {
      print(details.stack);
    }
  };
  runApp(const PhotoResizeApp());
}

class PhotoResizeApp extends StatelessWidget {
  const PhotoResizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightBlue = Color(0xFF49A6E9); // #49A6E9
    const blueOverlay = Color(0x3349A6E9); // 20% opacity for overlays
    const red = Color(0xFFF20505); // #F20505
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightBlue,
      onPrimary: Colors.white,
      secondary: red,
      onSecondary: Colors.white,
      error: red,
      onError: Colors.white,
      background: Colors.white,
      onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    );
    return MaterialApp(
      title: 'Photo Resize App',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBlue,
          elevation: 0,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Color(0x2249A6E9),
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(lightBlue),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            overlayColor: MaterialStatePropertyAll(blueOverlay),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(lightBlue),
            side: MaterialStatePropertyAll(BorderSide(color: lightBlue)),
            overlayColor: MaterialStatePropertyAll(blueOverlay),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: lightBlue),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightBlue),
          ),
          border: OutlineInputBorder(),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: lightBlue,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: lightBlue,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const GradientBackground(child: PhotoResizeHomePage()),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF49A6E9), // Light blue at top
            Colors.white, // White at bottom
          ],
        ),
      ),
      child: child,
    );
  }
}

class PhotoResizeHomePage extends StatefulWidget {
  const PhotoResizeHomePage({super.key});

  @override
  State<PhotoResizeHomePage> createState() => _PhotoResizeHomePageState();
}

class _PhotoResizeHomePageState extends State<PhotoResizeHomePage> {
  // For persistence
  static const _prefsKey = 'photo_resize_app_state';

  // Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final state = <String, dynamic>{
      'step': _step,
      'selectedSize': _selectedSize,
      'customUnit': _customUnit,
      'customWidth': _customWidth,
      'customHeight': _customHeight,
      'imageFile': _imageFile?.path,
      'originalImageBytes': _originalImageBytes != null
          ? base64Encode(_originalImageBytes!)
          : null,
      'freeCroppedImageBytes': _freeCroppedImageBytes != null
          ? base64Encode(_freeCroppedImageBytes!)
          : null,
      'maskCroppedImageBytes': _maskCroppedImageBytes != null
          ? base64Encode(_maskCroppedImageBytes!)
          : null,
      'finalImageBytes': _finalImageBytes != null
          ? base64Encode(_finalImageBytes!)
          : null,
    };
    await prefs.setString(_prefsKey, jsonEncode(state));
  }

  // Restore state from SharedPreferences
  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null) return;
    try {
      final state = jsonDecode(jsonStr);
      setState(() {
        _step = state['step'] ?? 0;
        _selectedSize = state['selectedSize'] ?? _selectedSize;
        _customUnit = state['customUnit'] ?? _customUnit;
        _customWidth = (state['customWidth'] ?? _customWidth).toDouble();
        _customHeight = (state['customHeight'] ?? _customHeight).toDouble();
        // _imageFile is not restored (path only, not XFile)
        _originalImageBytes = state['originalImageBytes'] != null
            ? base64Decode(state['originalImageBytes'])
            : null;
        _freeCroppedImageBytes = state['freeCroppedImageBytes'] != null
            ? base64Decode(state['freeCroppedImageBytes'])
            : null;
        _maskCroppedImageBytes = state['maskCroppedImageBytes'] != null
            ? base64Decode(state['maskCroppedImageBytes'])
            : null;
        _finalImageBytes = state['finalImageBytes'] != null
            ? base64Decode(state['finalImageBytes'])
            : null;
      });
    } catch (_) {}
  }

  // Clear saved state
  Future<void> _clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  @override
  void initState() {
    super.initState();
    _restoreState();
  }

  // Step 0: Select image, Step 1: Free crop, Step 2: Select passport size, Step 3: Crop with mask, Step 4: Confirm
  int _step = 0;
  XFile? _imageFile;
  Uint8List? _originalImageBytes;
  Uint8List? _freeCroppedImageBytes;
  Uint8List? _maskCroppedImageBytes;
  Uint8List? _finalImageBytes;
  String _selectedSize = 'India (2x2 inch)';
  final Map<String, List<double>> _passportSizes = {
    'India (2x2 inch)': [5.08, 5.08],
    'US (2x2 inch)': [5.08, 5.08],
    'UK (35x45 mm)': [3.5, 4.5],
    'EU (35x45 mm)': [3.5, 4.5],
    'China (33x48 mm)': [3.3, 4.8],
    'Canada (50x70 mm)': [5.0, 7.0],
    'Australia (35x45 mm)': [3.5, 4.5],
    'Singapore (35x45 mm)': [3.5, 4.5],
    'Malaysia (35x50 mm)': [3.5, 5.0],
    'Custom': [3.5, 4.5], // Default custom values
  };
  String _customUnit = 'cm';
  double _customWidth = 3.5;
  double _customHeight = 4.5;
  final int _dpi = 300;

  Future<void> _pickImage({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _originalImageBytes = bytes;
        _freeCroppedImageBytes = null;
        _maskCroppedImageBytes = null;
        _finalImageBytes = null;
        _step = 1;
      });
      await _saveState();
    }
  }

  Future<void> _processImage() async {
    if (_maskCroppedImageBytes == null) return;
    final size = _passportSizes[_selectedSize]!;
    final widthCm = size[0];
    final heightCm = size[1];
    final widthPx = (widthCm / 2.54 * _dpi).round();
    final heightPx = (heightCm / 2.54 * _dpi).round();
    img.Image? image = img.decodeImage(_maskCroppedImageBytes!);
    if (image == null) return;
    final resized = img.copyResize(
      image,
      width: widthPx,
      height: heightPx,
      interpolation: img.Interpolation.linear,
    );
    final processedBytes = kIsWeb
        ? img.encodePng(resized)
        : img.encodeJpg(resized);
    setState(() {
      _finalImageBytes = Uint8List.fromList(processedBytes);
      _step = 4;
    });
    await _saveState();
  }

  void _goHome() async {
    await _saveState();
    setState(() {
      _step = 0;
      // Do not clear image/crop state, just go to home step
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Resize App'),
        actions: [
          if (_step == 1 || _step == 2 || _step == 3 || _step == 4)
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: _goHome,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (context) {
            if (_step == 0) {
              // Step 1: Select image
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Step 1: Select or Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () => _pickImage(fromCamera: false),
                          label: const Text('Gallery'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _pickImage(fromCamera: true),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else if (_step == 1) {
              // Step 2: Free crop (optional)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Step 2: Crop Photo (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (_originalImageBytes != null)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.memory(
                          _freeCroppedImageBytes ?? _originalImageBytes!,
                          height: 200,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      if (_originalImageBytes == null) return;
                      final cropped = await Navigator.push<Uint8List?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _CropScreen(
                            imageBytes: _originalImageBytes!,
                            aspectRatio: null,
                            targetWidth: 0,
                            targetHeight: 0,
                            unit: 'cm',
                            dpi: _dpi,
                          ),
                        ),
                      );
                      if (cropped != null) {
                        setState(() {
                          _freeCroppedImageBytes = cropped;
                        });
                      }
                    },
                    child: const Text('Crop Freely'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _step = 2;
                      });
                    },
                    child: const Text('Next: Select Passport Size'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _step = 0;
                        _imageFile = null;
                        _originalImageBytes = null;
                        _freeCroppedImageBytes = null;
                        _maskCroppedImageBytes = null;
                        _finalImageBytes = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ],
              );
            } else if (_step == 2) {
              // Step 3: Select passport size
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Step 3: Select Passport Size',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedSize,
                    items: _passportSizes.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(key),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSize = newValue ?? _selectedSize;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Passport Size',
                    ),
                  ),
                  if (_selectedSize == 'Custom') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _customWidth.toString(),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Width',
                            ),
                            onChanged: (val) {
                              setState(() {
                                _customWidth =
                                    double.tryParse(val) ?? _customWidth;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _customHeight.toString(),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Height',
                            ),
                            onChanged: (val) {
                              setState(() {
                                _customHeight =
                                    double.tryParse(val) ?? _customHeight;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _customUnit,
                          items: ['cm', 'inch', 'px']
                              .map(
                                (u) =>
                                    DropdownMenuItem(value: u, child: Text(u)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              if (val != null) _customUnit = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () async {
                      // Go to crop with mask step
                      List<double> size;
                      String unit = 'cm';
                      if (_selectedSize == 'Custom') {
                        size = [_customWidth, _customHeight];
                        unit = _customUnit;
                      } else {
                        size = _passportSizes[_selectedSize]!;
                        unit = 'cm';
                      }
                      final aspectRatio = size[0] / size[1];
                      final cropSource =
                          _freeCroppedImageBytes ?? _originalImageBytes;
                      if (cropSource == null) return;
                      final cropped = await Navigator.push<Uint8List?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _CropScreen(
                            imageBytes: cropSource,
                            aspectRatio: aspectRatio,
                            targetWidth: size[0],
                            targetHeight: size[1],
                            unit: unit,
                            dpi: _dpi,
                          ),
                        ),
                      );
                      if (cropped != null) {
                        setState(() {
                          _maskCroppedImageBytes = cropped;
                          _step = 3;
                        });
                        await _saveState();
                      }
                    },
                    child: const Text('Next: Crop to Passport Size'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _step = 1;
                        _maskCroppedImageBytes = null;
                        _finalImageBytes = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ],
              );
            } else if (_step == 3) {
              // Step 4: Confirm crop and resize
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Step 4: Confirm Crop',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (_maskCroppedImageBytes != null)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.memory(
                          _maskCroppedImageBytes!,
                          height: 200,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      await _processImage();
                    },
                    child: const Text('Confirm & Resize'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _step = 2;
                        _finalImageBytes = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ],
              );
            } else if (_step == 4) {
              // Step 5: Final preview and save
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Step 5: Final Preview',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  if (_finalImageBytes != null)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.memory(_finalImageBytes!, height: 200),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save to Gallery'),
                    onPressed: () async {
                      if (_finalImageBytes == null) return;
                      final result = await ImageGallerySaverPlus.saveImage(
                        _finalImageBytes!,
                        quality: 100,
                        name:
                            'resized_photo_${DateTime.now().millisecondsSinceEpoch}',
                      );
                      final isSuccess =
                          (result['isSuccess'] ?? result['success'] ?? false) ==
                          true;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSuccess
                                  ? 'Saved to gallery!'
                                  : 'Failed to save.',
                            ),
                          ),
                        );
                      }
                      await _saveState();
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _step = 3;
                        _finalImageBytes = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

// Plus (+) control for crop corners
class PlusControl extends StatelessWidget {
  final Color backgroundColor;
  const PlusControl({super.key, required this.backgroundColor});
  @override
  Widget build(BuildContext context) {
    // Compute dynamic color: white if background is dark, black otherwise
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final plusColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          child: CustomPaint(painter: _PlusPainter(plusColor)),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  final Color plusColor;
  _PlusPainter(this.plusColor);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = plusColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    // Draw vertical line
    canvas.drawLine(
      Offset(centerX, centerY - size.height / 2 + 4),
      Offset(centerX, centerY + size.height / 2 - 4),
      paint,
    );
    // Draw horizontal line
    canvas.drawLine(
      Offset(centerX - size.width / 2 + 4, centerY),
      Offset(centerX + size.width / 2 - 4, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Ruler overlay painter
class _RulerPainter extends CustomPainter {
  final String unit;
  final int dpi;
  final double width;
  final double height;
  _RulerPainter({
    required this.unit,
    required this.dpi,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1;
    double pxPerUnit;
    if (unit == 'cm') {
      pxPerUnit = size.width / width;
    } else if (unit == 'inch') {
      pxPerUnit = size.width / width;
    } else if (unit == 'px') {
      pxPerUnit = size.width / width;
    } else {
      pxPerUnit = 1;
    }
    // Draw horizontal ruler
    for (int i = 0; i <= width; i++) {
      double x = i * pxPerUnit;
      canvas.drawLine(Offset(x, 0), Offset(x, 10), paint);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(fontSize: 8, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x + 2, 0));
    }
    // Draw vertical ruler
    for (int i = 0; i <= height; i++) {
      double y = i * (size.height / height);
      canvas.drawLine(Offset(0, y), Offset(10, y), paint);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(fontSize: 8, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Full screen cropper page
class _CropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final double? aspectRatio;
  final double targetWidth;
  final double targetHeight;
  final String unit;
  final int dpi;
  const _CropScreen({
    required this.imageBytes,
    required this.aspectRatio,
    required this.targetWidth,
    required this.targetHeight,
    required this.unit,
    required this.dpi,
    Key? key,
  }) : super(key: key);

  @override
  State<_CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<_CropScreen> {
  late CropController _controller;
  late Key _cropperKey;
  bool _cropping = false;
  bool _cropperReady = false;
  String? _warning;
  Rect? _lastCropRect;
  bool _showWarning = false;
  double? _aspectRatio;

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
  int _selectedRatioIndex = 0; // Default to Free
  // Remove _cropKey, not needed for controller-based aspect ratio

  @override
  void initState() {
    super.initState();
    _controller = CropController();
    _cropperKey = UniqueKey();
    // Always use fixed aspect ratio if provided (step 4), else allow free crop
    if (widget.aspectRatio != null) {
      _aspectRatio = widget.aspectRatio;
      print(
        '[CropScreen:initState] aspectRatio fixed to \\${widget.aspectRatio}',
      );
    } else {
      _aspectRatio = null;
      print('[CropScreen:initState] aspectRatio is free style');
    }
    // Initial warning: only if the image is already too small for the target size
    int pxW = 0, pxH = 0;
    if (widget.unit == 'cm') {
      pxW = (widget.targetWidth / 2.54 * widget.dpi).round();
      pxH = (widget.targetHeight / 2.54 * widget.dpi).round();
    } else if (widget.unit == 'inch') {
      pxW = (widget.targetWidth * widget.dpi).round();
      pxH = (widget.targetHeight * widget.dpi).round();
    } else if (widget.unit == 'px') {
      pxW = widget.targetWidth.round();
      pxH = widget.targetHeight.round();
    }
    img.Image? decoded;
    try {
      decoded = img.decodeImage(widget.imageBytes);
    } catch (_) {}
    if (decoded != null && (decoded.width < pxW || decoded.height < pxH)) {
      _showWarning = true;
    }
  }

  void _onAspectRatioSelected(int i) {
    setState(() {
      _selectedRatioIndex = i;
      if (i == 0) {
        _aspectRatio = null;
      } else {
        _aspectRatio = _ratios[i]['value'];
      }
      // Now re-create controller and key
      _controller = CropController();
      _cropperKey = UniqueKey();
      print(
        '[CropScreen] _onAspectRatioSelected: _aspectRatio=$_aspectRatio, _selectedRatioIndex=$_selectedRatioIndex',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFixedAspect = widget.aspectRatio != null;
    // Always use fixed aspect ratio for passport crop
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

    // _showWarning is updated only when crop rect changes (see below)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          TextButton(
            onPressed: _cropping ? null : () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Note: If you zoom in a lot or select a very small crop area, the output image quality may be low.',
                      style: TextStyle(color: Colors.blueGrey),
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
                    // Try to match the country unit (cm or inch)
                    // If the selected size string contains 'inch', use inch, else cm
                    // For custom, use widget.unit
                    String? selectedSize;
                    try {
                      final homeState = context
                          .findAncestorStateOfType<_PhotoResizeHomePageState>();
                      selectedSize = homeState?._selectedSize;
                    } catch (_) {}
                    if (selectedSize != null &&
                        selectedSize.toLowerCase().contains('inch')) {
                      unit = 'inch';
                      w = (widget.targetWidth / 2.54);
                      h = (widget.targetHeight / 2.54);
                    } else if (selectedSize != null &&
                        selectedSize.toLowerCase().contains('mm')) {
                      unit = 'cm';
                      // keep as cm
                    }
                    String dimStr = unit == 'inch'
                        ? '${w.toStringAsFixed(2)} x ${h.toStringAsFixed(2)} in'
                        : '${w.toStringAsFixed(2)} x ${h.toStringAsFixed(2)} cm';
                    return Text(
                      'Crop the image to the required passport size. The crop mask is fixed to the target dimensions or aspect ratio ($dimStr).',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
                      return ChoiceChip(
                        label: Text(_ratios[i]['label']),
                        selected: selected,
                        onSelected: (val) {
                          if (val) _onAspectRatioSelected(i);
                        },
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
                aspectRatio: _aspectRatio, // Will be null for Free
                baseColor: Colors.black,
                maskColor: Colors.black.withOpacity(0.4),
                onStatusChanged: (status) {
                  print('[CropScreen] Cropper status: $status');
                  if (status == CropStatus.ready && _aspectRatio == null) {
                    _controller.aspectRatio = null;
                    print(
                      '[CropScreen] onStatusChanged: Forced controller.aspectRatio to null for freestyle',
                    );
                  }
                  if (status == CropStatus.ready && !_cropperReady) {
                    setState(() => _cropperReady = true);
                    print('[CropScreen] Cropper is now ready');
                  }
                },
                onCropped: (result) async {
                  print(
                    '[CropScreen] onCropped called: type=${result.runtimeType}',
                  );
                  Uint8List? bytes;
                  if (result is CropSuccess) {
                    bytes = result.croppedImage;
                    print(
                      '[CropScreen] Got CropSuccess.croppedImage of length \\${bytes.length}',
                    );
                    // Calculate warning after crop
                    try {
                      final decoded = img.decodeImage(widget.imageBytes);
                      if (decoded != null && _lastCropRect != null) {
                        final origArea = decoded.width * decoded.height;
                        final cropArea =
                            _lastCropRect!.width * _lastCropRect!.height;
                        final percent = cropArea / origArea;
                        setState(() {
                          _showWarning = percent < 0.7;
                        });
                      }
                    } catch (_) {}
                  } else {
                    print('[CropScreen] Unexpected crop result: $result');
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
                    // Allow any (use full image by default)
                    const scale = 0.8;
                    final w = imageRect.width * scale;
                    final h = imageRect.height * scale;
                    final l = imageRect.left + (imageRect.width - w) / 2;
                    final t = imageRect.top + (imageRect.height - h) / 2;
                    rect = Rect.fromLTWH(l, t, w, h);
                    print(
                      "[CropScreen] initialRectBuilder: Freestyle mode, using small rect: $rect",
                    );
                  } else {
                    // Otherwise create centered rectangle with desired aspect
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
                    print(
                      '[CropScreen] initialRectBuilder: aspectRatio=$_aspectRatio, cropWidth=$cropWidth, cropHeight=$cropHeight',
                    );
                  }
                  // Do not setState or mutate _showWarning here!
                  _lastCropRect = rect;
                  return rect;
                }),
                overlayBuilder: (context, rect) {
                  // No setState here! Just print for debug.
                  print(
                    '[CropScreen] Mask size for selected ${isFixedAspect ? 'Fixed' : _ratios[_selectedRatioIndex]['label']}: width=${rect.width}, height=${rect.height}',
                  );
                  return const SizedBox.shrink();
                },
                progressIndicator: const CircularProgressIndicator(),
                radius: 20,
                willUpdateScale: (newScale) => newScale < 5,
                cornerDotBuilder: (size, edgeAlignment) =>
                    PlusControl(backgroundColor: Colors.black),
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
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: (_cropping || !_cropperReady)
                        ? null
                        : () {
                            print(
                              '[CropScreen] Apply Crop button pressed (controller.crop called)',
                            );
                            setState(() => _cropping = true);
                            _controller.crop();
                          },
                    child: _cropping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply Crop'),
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
