import 'package:flutter/material.dart';
import '../dialogs/add_pocket_dialog.dart';

class PocketCardWidget extends StatelessWidget {
  final String accountId;
  final String id;
  final String name;
  final String icon;
  final double balance;
  final String? color;

  const PocketCardWidget({
    super.key,
    required this.accountId,
    required this.id,
    required this.name,
    required this.icon,
    required this.balance,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color != null ? _parseColor(color!) : null;

    return Card(
      color: cardColor,
      elevation: 2,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AddPocketDialog(
              accountId: accountId,
              pocketId: id,
              initialName: name,
              initialIcon: icon,
              initialColor: color,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),

              // Name and Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pocket',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Balance
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
