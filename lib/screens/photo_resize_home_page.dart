import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../screens/crop_screen.dart';

class PhotoResizeHomePage extends StatefulWidget {
  const PhotoResizeHomePage({super.key});

  @override
  State<PhotoResizeHomePage> createState() => _PhotoResizeHomePageState();
}

class _PhotoResizeHomePageState extends State<PhotoResizeHomePage> {
  static const _prefsKey = 'photo_resize_app_state';

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

  Future<void> _clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  @override
  void initState() {
    super.initState();
    _restoreState();
  }

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
    'Custom': [3.5, 4.5],
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
                          builder: (context) => CropScreen(
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
                          builder: (context) => CropScreen(
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
