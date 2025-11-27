import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog for selecting a custom color with HSV picker and hex input
class ColorPickerDialog extends StatefulWidget {
  final Color? initialColor;
  final String title;

  const ColorPickerDialog({
    super.key,
    this.initialColor,
    this.title = 'Pick a Color',
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _currentColor;
  late TextEditingController _hexController;
  bool _isEditingHex = false;

  @override
  void initState() {
    super.initState();
    _currentColor = HSVColor.fromColor(widget.initialColor ?? Colors.blue);
    _hexController = TextEditingController(
      text: _colorToHex(_currentColor.toColor()),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color? _hexToColor(String hex) {
    try {
      // Remove # if present
      final hexCode = hex.replaceAll('#', '');
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _updateColorFromHex(String hex) {
    final color = _hexToColor(hex);
    if (color != null) {
      setState(() {
        _currentColor = HSVColor.fromColor(color);
        _isEditingHex = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Color Preview
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _currentColor.toColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hue Slider
            Text('Hue', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Stack(
                children: [
                  // Hue gradient background
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          const HSVColor.fromAHSV(1, 0, 1, 1).toColor(),
                          const HSVColor.fromAHSV(1, 60, 1, 1).toColor(),
                          const HSVColor.fromAHSV(1, 120, 1, 1).toColor(),
                          const HSVColor.fromAHSV(1, 180, 1, 1).toColor(),
                          const HSVColor.fromAHSV(1, 240, 1, 1).toColor(),
                          const HSVColor.fromAHSV(1, 300, 1, 1).toColor(),
                          const HSVColor.fromAHSV(1, 360, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 40,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _currentColor.hue,
                      min: 0,
                      max: 360,
                      onChanged: (value) {
                        setState(() {
                          _currentColor = _currentColor.withHue(value);
                          _hexController.text = _colorToHex(
                            _currentColor.toColor(),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Saturation Slider
            Text('Saturation', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Stack(
                children: [
                  // Saturation gradient background
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          HSVColor.fromAHSV(
                            1,
                            _currentColor.hue,
                            0,
                            1,
                          ).toColor(),
                          HSVColor.fromAHSV(
                            1,
                            _currentColor.hue,
                            1,
                            1,
                          ).toColor(),
                        ],
                      ),
                    ),
                  ),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 40,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _currentColor.saturation,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        setState(() {
                          _currentColor = _currentColor.withSaturation(value);
                          _hexController.text = _colorToHex(
                            _currentColor.toColor(),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Value (Brightness) Slider
            Text('Brightness', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Stack(
                children: [
                  // Value gradient background
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          HSVColor.fromAHSV(
                            1,
                            _currentColor.hue,
                            _currentColor.saturation,
                            0,
                          ).toColor(),
                          HSVColor.fromAHSV(
                            1,
                            _currentColor.hue,
                            _currentColor.saturation,
                            1,
                          ).toColor(),
                        ],
                      ),
                    ),
                  ),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 40,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _currentColor.value,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        setState(() {
                          _currentColor = _currentColor.withValue(value);
                          _hexController.text = _colorToHex(
                            _currentColor.toColor(),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hex Input
            TextField(
              controller: _hexController,
              decoration: InputDecoration(
                labelText: 'Hex Color',
                hintText: '#FF5733',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[#0-9A-Fa-f]')),
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: (value) {
                setState(() {
                  _isEditingHex = true;
                });
              },
              onSubmitted: _updateColorFromHex,
            ),
            if (_isEditingHex && _hexToColor(_hexController.text) == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'Invalid hex format. Use #RRGGBB',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _colorToHex(_currentColor.toColor()),
                    );
                  },
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
