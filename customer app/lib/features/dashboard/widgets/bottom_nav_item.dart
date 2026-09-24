import 'package:flutter/material.dart';
import 'package:paustik_poornahar/util/dimensions.dart';
import 'package:paustik_poornahar/util/styles.dart';

class BottomNavItem extends StatelessWidget {
  final IconData? iconData;
  final Widget? icon;
  final Function? onTap;
  final bool isSelected;
  final String title;
  const BottomNavItem({super.key, this.iconData, this.icon, this.onTap, this.isSelected = false, required this.title});

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color color = isSelected ? selectedColor : Colors.grey;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap as void Function()?,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).disabledColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              icon ?? Icon(iconData, color: color, size: 22),
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
