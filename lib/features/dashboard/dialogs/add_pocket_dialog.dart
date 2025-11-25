import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late String _selectedIcon;
  String? _selectedColor;

  final List<String> _iconOptions = [
    '💰',
    '💵',
    '💳',
    '🏦',
    '💎',
    '🪙',
    '🎯',
    '⭐',
    '🎁',
    '📌',
    '🔖',
    '✨',
  ];

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
    _selectedIcon = widget.initialIcon ?? '💰';
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
              icon: _selectedIcon,
              color: _selectedColor,
            );
      } else {
        await ref
            .read(dashboardControllerProvider.notifier)
            .addPocket(
              accountId: widget.accountId,
              name: _nameController.text.trim(),
              icon: _selectedIcon,
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
      await ref
          .read(dashboardControllerProvider.notifier)
          .deletePocket(
            accountId: widget.accountId,
            pocketId: widget.pocketId!,
          );
      if (mounted) {
        Navigator.of(context).pop();
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconOptions.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
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
                children: _colorOptions.map((color) {
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
                }).toList(),
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
        const Spacer(),
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
