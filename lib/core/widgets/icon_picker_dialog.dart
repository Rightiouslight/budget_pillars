import 'package:flutter/material.dart';
import '../constants/app_icons.dart';

/// Categories for organizing icons in the picker
enum IconCategory {
  all('All Icons'),
  finance('Finance & Money'),
  food('Food & Dining'),
  home('Home & Utilities'),
  transport('Transportation'),
  health('Health & Fitness'),
  shopping('Shopping & Personal'),
  entertainment('Entertainment'),
  education('Education'),
  technology('Technology'),
  family('Family & Pets'),
  misc('Miscellaneous');

  final String label;
  const IconCategory(this.label);
}

/// Dialog for selecting an icon from a comprehensive list
class IconPickerDialog extends StatefulWidget {
  final List<IconOption> availableIcons;
  final int? initialCodePoint;
  final String title;

  const IconPickerDialog({
    super.key,
    required this.availableIcons,
    this.initialCodePoint,
    this.title = 'Select Icon',
  });

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  late int? _selectedCodePoint;
  IconCategory _selectedCategory = IconCategory.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCodePoint = widget.initialCodePoint;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IconOption> get _filteredIcons {
    List<IconOption> icons = widget.availableIcons;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      icons = icons
          .where(
            (icon) =>
                icon.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Filter by category (basic keyword matching)
    if (_selectedCategory != IconCategory.all) {
      icons = icons.where((icon) {
        final name = icon.name.toLowerCase();
        switch (_selectedCategory) {
          case IconCategory.finance:
            return name.contains('bank') ||
                name.contains('wallet') ||
                name.contains('card') ||
                name.contains('money') ||
                name.contains('paid') ||
                name.contains('payment') ||
                name.contains('savings') ||
                name.contains('business') ||
                name.contains('work') ||
                name.contains('portfolio');
          case IconCategory.food:
            return name.contains('food') ||
                name.contains('restaurant') ||
                name.contains('cafe') ||
                name.contains('pizza') ||
                name.contains('bar') ||
                name.contains('dining') ||
                name.contains('lunch') ||
                name.contains('dinner') ||
                name.contains('breakfast') ||
                name.contains('bakery') ||
                name.contains('cream');
          case IconCategory.home:
            return name.contains('home') ||
                name.contains('house') ||
                name.contains('apartment') ||
                name.contains('electricity') ||
                name.contains('bolt') ||
                name.contains('water') ||
                name.contains('heating') ||
                name.contains('thermostat') ||
                name.contains('internet') ||
                name.contains('wifi') ||
                name.contains('phone') ||
                name.contains('cleaning') ||
                name.contains('maintenance') ||
                name.contains('build');
          case IconCategory.transport:
            return name.contains('car') ||
                name.contains('gas') ||
                name.contains('parking') ||
                name.contains('bus') ||
                name.contains('subway') ||
                name.contains('train') ||
                name.contains('taxi') ||
                name.contains('motorcycle') ||
                name.contains('bike') ||
                name.contains('flight');
          case IconCategory.health:
            return name.contains('hospital') ||
                name.contains('medical') ||
                name.contains('pharmacy') ||
                name.contains('gym') ||
                name.contains('fitness') ||
                name.contains('sports') ||
                name.contains('wellness') ||
                name.contains('spa') ||
                name.contains('health');
          case IconCategory.shopping:
            return name.contains('shop') ||
                name.contains('cart') ||
                name.contains('bag') ||
                name.contains('groceries') ||
                name.contains('clothing') ||
                name.contains('haircut') ||
                name.contains('beauty') ||
                name.contains('laundry');
          case IconCategory.entertainment:
            return name.contains('movie') ||
                name.contains('theater') ||
                name.contains('gaming') ||
                name.contains('music') ||
                name.contains('audio') ||
                name.contains('headphones') ||
                name.contains('tv') ||
                name.contains('game') ||
                name.contains('park') ||
                name.contains('beach');
          case IconCategory.education:
            return name.contains('school') ||
                name.contains('book') ||
                name.contains('library') ||
                name.contains('science') ||
                name.contains('engineering');
          case IconCategory.technology:
            return name.contains('phone') ||
                name.contains('computer') ||
                name.contains('laptop') ||
                name.contains('tablet') ||
                name.contains('headset') ||
                name.contains('camera') ||
                name.contains('printer') ||
                name.contains('android');
          case IconCategory.family:
            return name.contains('pet') ||
                name.contains('child') ||
                name.contains('toy') ||
                name.contains('cake') ||
                name.contains('celebrations') ||
                name.contains('gift');
          case IconCategory.misc:
            return name.contains('bill') ||
                name.contains('receipt') ||
                name.contains('subscription') ||
                name.contains('investment') ||
                name.contains('charity') ||
                name.contains('volunteer') ||
                name.contains('other') ||
                name.contains('category');
          default:
            return true;
        }
      }).toList();
    }

    return icons;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredIcons = _filteredIcons;

    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
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
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<IconCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: IconCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Results count
            Text(
              '${filteredIcons.length} icons available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Icon grid
            Expanded(
              child: filteredIcons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No icons found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or category',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: filteredIcons.length,
                      itemBuilder: (context, index) {
                        final iconOption = filteredIcons[index];
                        final isSelected =
                            iconOption.codePoint == _selectedCodePoint;

                        return Tooltip(
                          message: iconOption.name,
                          waitDuration: const Duration(milliseconds: 500),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCodePoint = iconOption.codePoint;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surface,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                iconOption.iconData,
                                size: 28,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

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
                  onPressed: _selectedCodePoint != null
                      ? () => Navigator.pop(context, _selectedCodePoint)
                      : null,
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
