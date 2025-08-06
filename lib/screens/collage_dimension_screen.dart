import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Ensure this path and file exist and define kBannerGold and kCream

class CollageDimensionScreen extends StatefulWidget {
  final void Function(double width, double height, String unit) onSubmit;
  final double passportWidthCm;
  final double passportHeightCm;
  final int dpi;

  const CollageDimensionScreen({
    required this.onSubmit,
    required this.passportWidthCm,
    required this.passportHeightCm,
    required this.dpi,
    super.key,
  });

  @override
  State<CollageDimensionScreen> createState() => _CollageDimensionScreenState();
}

class _CollageDimensionScreenState extends State<CollageDimensionScreen> {
  final _formKey = GlobalKey<FormState>();
  double _width = 10.0;
  double _height = 15.0;
  String _unit = 'cm';
  bool _usePhotoCount = true; // New: determines which mode to use
  int _targetPhotoCount = 6;
  double _marginMm = 2.5; // margin in mm

  // Calculated values
  int _calculatedPhotos = 0;
  double _calculatedWidth = 0.0;
  double _calculatedHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _updateCalculations();
  }

  void _updateCalculations() {
    if (_usePhotoCount) {
      _calculateDimensionsFromPhotoCount();
    } else {
      _calculatePhotosFromDimensions();
    }
  }

  void _calculateDimensionsFromPhotoCount() {
    // Convert passport size to pixels
    final passportWidthPx = (widget.passportWidthCm / 2.54 * widget.dpi);
    final passportHeightPx = (widget.passportHeightCm / 2.54 * widget.dpi);
    final marginPx =
        (_marginMm / 10.0 / 2.54 * widget.dpi); // mm to cm to pixels

    // Try different arrangements to fit the target number of photos
    int bestCols = 1, bestRows = 1;
    double bestRatio = double.infinity;

    for (int cols = 1; cols <= _targetPhotoCount; cols++) {
      int rows = (_targetPhotoCount / cols).ceil();
      if (cols * rows >= _targetPhotoCount) {
        // Calculate aspect ratio difference from a reasonable paper size (closer to A4)
        double width = cols * passportWidthPx + (cols - 1) * marginPx;
        double height = rows * passportHeightPx + (rows - 1) * marginPx;
        double ratio = width / height;
        double targetRatio = 1.414; // A4 aspect ratio (height/width)
        double ratioDiff = (ratio - 1 / targetRatio).abs();

        if (ratioDiff < bestRatio) {
          bestRatio = ratioDiff;
          bestCols = cols;
          bestRows = rows;
        }
      }
    }

    // Calculate final dimensions
    double finalWidthPx =
        bestCols * passportWidthPx + (bestCols - 1) * marginPx;
    double finalHeightPx =
        bestRows * passportHeightPx + (bestRows - 1) * marginPx;

    // Convert back to cm
    _calculatedWidth = finalWidthPx * 2.54 / widget.dpi;
    _calculatedHeight = finalHeightPx * 2.54 / widget.dpi;
    _calculatedPhotos = bestCols * bestRows;
  }

  void _calculatePhotosFromDimensions() {
    // Convert dimensions to cm
    double widthCm = _width;
    double heightCm = _height;
    if (_unit == 'inch') {
      widthCm = _width * 2.54;
      heightCm = _height * 2.54;
    }

    // Convert to pixels
    final widthPx = (widthCm / 2.54 * widget.dpi);
    final heightPx = (heightCm / 2.54 * widget.dpi);
    final passportWidthPx = (widget.passportWidthCm / 2.54 * widget.dpi);
    final passportHeightPx = (widget.passportHeightCm / 2.54 * widget.dpi);
    final marginPx = (_marginMm / 10.0 / 2.54 * widget.dpi);

    // Calculate how many photos fit
    final cols = ((widthPx + marginPx) / (passportWidthPx + marginPx)).floor();
    final rows = ((heightPx + marginPx) / (passportHeightPx + marginPx))
        .floor();

    _calculatedPhotos = cols * rows;
    _calculatedWidth = widthCm;
    _calculatedHeight = heightCm;
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
                'Set Collage Configuration',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode Selection
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Configuration Method',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('By Photo Count'),
                                subtitle: const Text(
                                  'Specify number of photos',
                                ),
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
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('By Dimensions'),
                                subtitle: const Text('Specify paper size'),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Configuration Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _usePhotoCount
                              ? 'Photo Count Configuration'
                              : 'Dimension Configuration',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_usePhotoCount) ...[
                          // Photo count mode
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _targetPhotoCount.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Number of Photos',
                                    helperText: 'How many photos do you want?',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    final val = int.tryParse(v ?? '');
                                    return (val == null ||
                                            val <= 0 ||
                                            val > 100)
                                        ? 'Enter 1-100 photos'
                                        : null;
                                  },
                                  onChanged: (v) {
                                    final val = int.tryParse(v);
                                    if (val != null && val > 0) {
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
                                  initialValue: _marginMm.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Margin (mm)',
                                    helperText: 'Space between photos',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) {
                                    final val = double.tryParse(v ?? '');
                                    return (val == null || val < 0 || val > 20)
                                        ? 'Enter 0-20 mm'
                                        : null;
                                  },
                                  onChanged: (v) {
                                    final val = double.tryParse(v);
                                    if (val != null && val >= 0) {
                                      setState(() {
                                        _marginMm = val;
                                        _updateCalculations();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Dimension mode
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _width.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Width',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) =>
                                      (v == null ||
                                          double.tryParse(v) == null ||
                                          double.parse(v) <= 0)
                                      ? 'Enter valid width'
                                      : null,
                                  onChanged: (v) {
                                    final val = double.tryParse(v);
                                    if (val != null && val > 0) {
                                      setState(() {
                                        _width = val;
                                        _updateCalculations();
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _height.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Height',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) =>
                                      (v == null ||
                                          double.tryParse(v) == null ||
                                          double.parse(v) <= 0)
                                      ? 'Enter valid height'
                                      : null,
                                  onChanged: (v) {
                                    final val = double.tryParse(v);
                                    if (val != null && val > 0) {
                                      setState(() {
                                        _height = val;
                                        _updateCalculations();
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _unit,
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
                                      _unit = v ?? 'cm';
                                      _updateCalculations();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _marginMm.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Margin (mm)',
                                    helperText: 'Space between photos',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (v) {
                                    final val = double.tryParse(v ?? '');
                                    return (val == null || val < 0 || val > 20)
                                        ? 'Enter 0-20 mm'
                                        : null;
                                  },
                                  onChanged: (v) {
                                    final val = double.tryParse(v);
                                    if (val != null && val >= 0) {
                                      setState(() {
                                        _marginMm = val;
                                        _updateCalculations();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Results Card
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
                            Icon(Icons.info_outline, color: kPrimaryGreen),
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
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Final Dimensions:',
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
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Photos that will fit:',
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Margin: ${_marginMm.toStringAsFixed(1)} mm between photos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
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
                        onPressed: _calculatedPhotos > 0
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  widget.onSubmit(
                                    _calculatedWidth,
                                    _calculatedHeight,
                                    'cm',
                                  );
                                }
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          foregroundColor: kCream,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: kCream, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
