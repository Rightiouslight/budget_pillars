import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/icon_picker_dialog.dart';
import '../dashboard_controller.dart';

/// Dialog for adding or editing an account
class AddAccountDialog extends ConsumerStatefulWidget {
  final String? accountId; // If editing, pass the account ID
  final String? initialName;
  final String? initialIcon;

  const AddAccountDialog({
    super.key,
    this.accountId,
    this.initialName,
    this.initialIcon,
  });

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedIconCodePoint;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);

    // Parse icon from string (codePoint) or use default
    if (widget.initialIcon != null) {
      final parsed = int.tryParse(widget.initialIcon!);
      if (parsed != null && AppIcons.isValidAccountIcon(parsed)) {
        _selectedIconCodePoint = parsed;
      } else {
        _selectedIconCodePoint = AppIcons.defaultAccountIcon.codePoint;
      }
    } else {
      _selectedIconCodePoint = AppIcons.defaultAccountIcon.codePoint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.accountId != null;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        await ref
            .read(dashboardControllerProvider.notifier)
            .editAccount(
              accountId: widget.accountId!,
              name: _nameController.text.trim(),
              icon: _selectedIconCodePoint.toString(),
            );
      } else {
        await ref
            .read(dashboardControllerProvider.notifier)
            .addAccount(
              name: _nameController.text.trim(),
              icon: _selectedIconCodePoint.toString(),
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
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this account? All pockets and categories in this account will be deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(dashboardControllerProvider.notifier)
          .deleteAccount(widget.accountId!);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(dashboardControllerProvider);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Account' : 'Add Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Account Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g., Main, Savings, Business',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an account name';
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
                    availableIcons: AppIcons.accountIcons,
                    initialCodePoint: _selectedIconCodePoint,
                    title: 'Select Account Icon',
                  ),
                );
                if (selected != null) {
                  setState(() {
                    _selectedIconCodePoint = selected;
                  });
                }
              },
              icon: Icon(
                AppIcons.getAccountIconData(_selectedIconCodePoint),
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
          ],
        ),
      ),
      actionsOverflowButtonSpacing: 8,
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
              : Text(_isEditing ? 'Save' : 'Add Account'),
        ),
      ],
    );
  }
}
