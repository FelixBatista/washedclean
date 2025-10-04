import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class UrgencyChip extends StatelessWidget {
  final String urgency;
  final String? customText;

  const UrgencyChip({
    super.key,
    required this.urgency,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (urgency.toLowerCase()) {
      case 'red':
        color = AppTheme.urgencyRed;
        text = customText ?? 'Act Now';
        icon = Icons.warning;
        break;
      case 'yellow':
        color = AppTheme.urgencyYellow;
        text = customText ?? 'Treat Soon';
        icon = Icons.schedule;
        break;
      case 'green':
        color = AppTheme.urgencyGreen;
        text = customText ?? 'No Rush';
        icon = Icons.check_circle;
        break;
      default:
        color = AppTheme.mediumGray;
        text = customText ?? 'Unknown';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
