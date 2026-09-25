import 'package:flutter/material.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String imageData;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  const BottomNavItemWidget({super.key, required this.imageData, required this.title, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color color = isSelected ? selectedColor : Colors.grey;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).disabledColor.withValues(alpha: 0.35) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(imageData, color: color, height: 20, width: 20),
              const SizedBox(height: 2),
              Text(
                title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: (isSelected ? robotoBold : robotoRegular).copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: color),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
