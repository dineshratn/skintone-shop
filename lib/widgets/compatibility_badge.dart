import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants/app_constants.dart';
import '../constants/color_constants.dart';

class CompatibilityBadge extends StatelessWidget {
  final ProductCompatibility compatibility;
  final bool compact;

  const CompatibilityBadge({
    Key? key,
    required this.compatibility,
    this.compact = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    
    // Determine compatibility level and colors
    if (compatibility.compatibilityScore >= 80) {
      backgroundColor = ColorConstants.highCompatibility.withOpacity(0.2);
      textColor = ColorConstants.success;
      label = compact ? 'High Match' : AppConstants.highCompatibility;
    } else if (compatibility.compatibilityScore >= 50) {
      backgroundColor = ColorConstants.mediumCompatibility.withOpacity(0.2);
      textColor = Colors.orange.shade800;
      label = compact ? 'Good Match' : AppConstants.mediumCompatibility;
    } else {
      backgroundColor = ColorConstants.lowCompatibility.withOpacity(0.2);
      textColor = ColorConstants.error;
      label = compact ? 'Low Match' : AppConstants.lowCompatibility;
    }
    
    if (compact) {
      // Compact version for product cards
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              compatibility.compatibilityScore >= 80 ? Icons.star 
                  : compatibility.compatibilityScore >= 50 ? Icons.star_half 
                  : Icons.star_border,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      // Expanded version for product details
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  compatibility.compatibilityScore >= 80 ? Icons.check_circle
                      : compatibility.compatibilityScore >= 50 ? Icons.check_circle_outline
                      : Icons.remove_circle_outline,
                  size: 18,
                  color: textColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Score indicator
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: compatibility.compatibilityScore / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: textColor,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${compatibility.compatibilityScore}%',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
