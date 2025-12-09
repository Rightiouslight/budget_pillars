import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/icon_picker_dialog.dart';
import '../../../core/widgets/color_picker_dialog.dart';
import '../dashboard_controller.dart';

/// Dialog for adding or editing a pocket
class AddPocketDialog extends ConsumerStatefulWidget {
  final String accountId;
  final String? pocketId; // If editing, pass the pocket ID
  final String? initialName;
  final String? initialIcon;
  final String? initialColor;

  const AddPocketDialog({
    super.key,
    required this.accountId,
    this.pocketId,
    this.initialName,
    this.initialIcon,
    this.initialColor,
  });

  @override
  ConsumerState<AddPocketDialog> createState() => _AddPocketDialogState();
}

class _AddPocketDialogState extends ConsumerState<AddPocketDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedIconCodePoint;
  String? _selectedColor;

  final List<String?> _colorOptions = [
    null, // Default
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#96CEB4', // Green
    '#FFEAA7', // Yellow
    '#DFE6E9', // Gray
    '#A29BFE', // Purple
    '#FD79A8', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);

    // Parse icon from string (codePoint) or use default
    if (widget.initialIcon != null) {
      final parsed = int.tryParse(widget.initialIcon!);
      if (parsed != null && AppIcons.isValidPocketIcon(parsed)) {
        _selectedIconCodePoint = parsed;
      } else {
        _selectedIconCodePoint = AppIcons.defaultPocketIcon.codePoint;
      }
    } else {
      _selectedIconCodePoint = AppIcons.defaultPocketIcon.codePoint;
    }

    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.pocketId != null;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        await ref
            .read(dashboardControllerProvider.notifier)
            .editPocket(
              accountId: widget.accountId,
              pocketId: widget.pocketId!,
              name: _nameController.text.trim(),
              icon: _selectedIconCodePoint.toString(),
              color: _selectedColor,
            );
      } else {
        await ref
            .read(dashboardControllerProvider.notifier)
            .addPocket(
              accountId: widget.accountId,
              name: _nameController.text.trim(),
              icon: _selectedIconCodePoint.toString(),
              color: _selectedColor,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pocket'),
        content: const Text(
          'Are you sure you want to delete this pocket? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final errorMessage = await ref
          .read(dashboardControllerProvider.notifier)
          .deletePocket(
            accountId: widget.accountId,
            pocketId: widget.pocketId!,
          );

      if (mounted) {
        if (errorMessage != null) {
          // Show error dialog with list of linked items
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cannot Delete Pocket'),
              content: SingleChildScrollView(child: Text(errorMessage)),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Success - close the dialog
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(dashboardControllerProvider);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Pocket' : 'Add Pocket'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pocket Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pocket Name',
                  hintText: 'e.g., Cash, Savings, Emergency',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a pocket name';
                  }
                  return null;
                },
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Icon Selector
              const Text(
                'Select Icon',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDialog<int>(
                    context: context,
                    builder: (context) => IconPickerDialog(
                      availableIcons: AppIcons.categoryIcons,
                      initialCodePoint: _selectedIconCodePoint,
                      title: 'Select Pocket Icon',
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedIconCodePoint = selected;
                    });
                  }
                },
                icon: Icon(
                  AppIcons.getPocketIconData(_selectedIconCodePoint),
                  size: 28,
                ),
                label: const Text('Choose Icon'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Color Selector
              const Text(
                'Select Color (Optional)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._colorOptions.map((color) {
                    final isSelected = color == _selectedColor;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color != null
                              ? Color(
                                  int.parse(color.substring(1), radix: 16) +
                                      0xFF000000,
                                )
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: color == null
                            ? Icon(
                                Icons.clear,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                            : null,
                      ),
                    );
                  }),
                  // Custom color picker button
                  InkWell(
                    onTap: () async {
                      // Parse current color or use default
                      Color? initialColor;
                      if (_selectedColor != null &&
                          !_colorOptions.contains(_selectedColor)) {
                        try {
                          initialColor = Color(
                            int.parse(_selectedColor!.substring(1), radix: 16) +
                                0xFF000000,
                          );
                        } catch (e) {
                          initialColor = null;
                        }
                      }

                      final selectedHex = await showDialog<String>(
                        context: context,
                        builder: (context) => ColorPickerDialog(
                          initialColor: initialColor,
                          title: 'Pick Custom Color',
                        ),
                      );

                      if (selectedHex != null) {
                        setState(() {
                          _selectedColor = selectedHex;
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            _selectedColor != null &&
                                !_colorOptions.contains(_selectedColor)
                            ? Color(
                                int.parse(
                                      _selectedColor!.substring(1),
                                      radix: 16,
                                    ) +
                                    0xFF000000,
                              )
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color:
                              _selectedColor != null &&
                                  !_colorOptions.contains(_selectedColor)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width:
                              _selectedColor != null &&
                                  !_colorOptions.contains(_selectedColor)
                              ? 3
                              : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.colorize,
                        size: 20,
                        color:
                            _selectedColor != null &&
                                !_colorOptions.contains(_selectedColor)
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: controllerState.isLoading ? null : _delete,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: controllerState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: controllerState.isLoading ? null : _submit,
          child: controllerState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save' : 'Add Pocket'),
        ),
      ],
    );
  }
}
