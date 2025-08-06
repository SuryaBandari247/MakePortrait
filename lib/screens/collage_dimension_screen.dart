import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Ensure this path and file exist and define kBannerGold and kCream

class CollageDimensionScreen extends StatefulWidget {
  final void Function(double width, double height, String unit) onSubmit;
  const CollageDimensionScreen({required this.onSubmit, super.key});

  @override
  State<CollageDimensionScreen> createState() => _CollageDimensionScreenState();
}

class _CollageDimensionScreenState extends State<CollageDimensionScreen> {
  final _formKey = GlobalKey<FormState>();
  double _width = 10.0;
  double _height = 15.0;
  String _unit = 'cm';

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
                'Set Collage Dimensions',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor:
            kBannerGold, // Make sure kBannerGold is defined in app_colors.dart
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: kCream, // Make sure kCream is defined in app_colors.dart
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter collage dimensions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _width.toString(),
                          decoration: const InputDecoration(labelText: 'Width'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              (v == null ||
                                  double.tryParse(v) == null ||
                                  double.parse(v) <= 0)
                              ? 'Enter valid width'
                              : null,
                          onSaved: (v) => _width = double.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _height.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Height',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              (v == null ||
                                  double.tryParse(v) == null ||
                                  double.parse(v) <= 0)
                              ? 'Enter valid height'
                              : null,
                          onSaved: (v) => _height = double.parse(v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: const [
                      DropdownMenuItem(value: 'cm', child: Text('cm')),
                      DropdownMenuItem(value: 'inch', child: Text('inch')),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? 'cm'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: kPrimaryGreen),
                            foregroundColor: kPrimaryGreen,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: kPrimaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              widget.onSubmit(_width, _height, _unit);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            foregroundColor: kCream,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: kCream),
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
      ),
    );
  }
}
