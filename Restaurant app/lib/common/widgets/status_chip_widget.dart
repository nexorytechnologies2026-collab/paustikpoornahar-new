import 'package:flutter/material.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';

/// Pill-shaped filter tab used across the kitchen app (home, order history,
/// ads, food categories): optional coloured icon circle and count badge.
class StatusChipWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final Color? color;
  const StatusChipWidget({super.key, required this.title, required this.isSelected, required this.onTap, this.count, this.icon, this.color});

  /// Icon and colour for an order / ad status key.
  static (IconData, Color) styleFor(String status) {
    switch(status) {
      case 'all': return (Icons.list_alt_rounded, const Color(0xFF0E9E31));
      case 'pending': return (Icons.access_time_rounded, const Color(0xFFF08A24));
      case 'confirmed': case 'approved': return (Icons.check_rounded, const Color(0xFF0E9E31));
      case 'cooking': return (Icons.soup_kitchen_rounded, const Color(0xFFE5484D));
      case 'ready_for_handover': return (Icons.shopping_bag_rounded, const Color(0xFF3B82F6));
      case 'food_on_the_way': return (Icons.delivery_dining_rounded, const Color(0xFF8B5CF6));
      case 'delivered': return (Icons.task_alt_rounded, const Color(0xFF0E9E31));
      case 'refunded': return (Icons.replay_rounded, const Color(0xFF3B82F6));
      case 'canceled': case 'denied': return (Icons.close_rounded, const Color(0xFFE5484D));
      case 'failed': return (Icons.error_outline_rounded, const Color(0xFF6B7280));
      case 'running': return (Icons.play_arrow_rounded, const Color(0xFF0E9E31));
      case 'paused': return (Icons.pause_rounded, const Color(0xFFF08A24));
      case 'expired': return (Icons.event_busy_rounded, const Color(0xFF6B7280));
      default: return (Icons.receipt_long_rounded, const Color(0xFF6B7280));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.fromLTRB(icon != null ? 6 : 14, 6, count != null ? 10 : 14, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            color: isSelected ? c.withValues(alpha: 0.12) : Theme.of(context).hintColor.withValues(alpha: 0.06),
            border: Border.all(color: isSelected ? c.withValues(alpha: 0.5) : Colors.transparent),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Container(
                height: 26, width: 26,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c),
                child: Icon(icon, size: 15, color: Colors.white),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
            ],
            Text(
              title, maxLines: 1,
              style: (isSelected ? robotoBold : robotoMedium).copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isSelected && icon == null ? c : null,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: c.withValues(alpha: 0.15)),
                child: Text(count.toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: c)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
