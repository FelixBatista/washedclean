import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/ratings_service.dart';

class RatingBar extends HookWidget {
  final Function(RatingType)? onRatingChanged;
  final RatingType? initialRating;

  const RatingBar({
    super.key,
    this.onRatingChanged,
    this.initialRating,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRating = useState(initialRating ?? RatingType.none);

    return Row(
      children: [
        // Thumbs up
        GestureDetector(
          onTap: () {
            final newRating = selectedRating.value == RatingType.up 
                ? RatingType.none 
                : RatingType.up;
            selectedRating.value = newRating;
            onRatingChanged?.call(newRating);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedRating.value == RatingType.up 
                  ? AppTheme.urgencyGreen 
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 20,
                  color: selectedRating.value == RatingType.up 
                      ? AppTheme.white 
                      : AppTheme.mediumGray,
                ),
                const SizedBox(width: 8),
                Text(
                  'Helpful',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selectedRating.value == RatingType.up 
                        ? AppTheme.white 
                        : AppTheme.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Thumbs down
        GestureDetector(
          onTap: () {
            final newRating = selectedRating.value == RatingType.down 
                ? RatingType.none 
                : RatingType.down;
            selectedRating.value = newRating;
            onRatingChanged?.call(newRating);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedRating.value == RatingType.down 
                  ? AppTheme.urgencyRed 
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_down,
                  size: 20,
                  color: selectedRating.value == RatingType.down 
                      ? AppTheme.white 
                      : AppTheme.mediumGray,
                ),
                const SizedBox(width: 8),
                Text(
                  'Not helpful',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selectedRating.value == RatingType.down 
                        ? AppTheme.white 
                        : AppTheme.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
