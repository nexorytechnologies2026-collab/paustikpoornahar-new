import 'package:paustik_poornahar_restaurant/features/order/controllers/order_controller.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';
import 'package:flutter/material.dart';

class OrderButtonWidget extends StatelessWidget {
  final String title;
  final int index;
  final OrderController orderController;
  final bool fromHistory;
  final int? orderCount;
  const OrderButtonWidget({super.key, required this.title, required this.index, required this.orderController, required this.fromHistory, this.orderCount});

  @override
  Widget build(BuildContext context) {

    int selectedIndex;
    int length = 0;

    if(fromHistory) {
      selectedIndex = orderController.historyIndex;
      length = 0;
    }else {
      selectedIndex = orderController.orderIndex;
      length = orderController.runningOrders![index].orderList.length;
    }

    bool isSelected = selectedIndex == index;

    if(!fromHistory) {
      final (IconData icon, Color color) = _statusStyle(orderController.runningOrders![index].status);
      return Padding(
        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          onTap: () => orderController.setOrderIndex(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: isSelected ? color.withValues(alpha: 0.12) : Theme.of(context).hintColor.withValues(alpha: 0.06),
              border: Border.all(color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent),
            ),
            child: Row(children: [
              Container(
                height: 28, width: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(title, maxLines: 1, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: color.withValues(alpha: 0.15)),
                child: Text(length.toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: color)),
              ),
            ]),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => fromHistory ? orderController.setHistoryIndex(index) : orderController.setOrderIndex(index),
      child: Row(children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.1),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(
                title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: isSelected ? Theme.of(context).cardColor : Theme.of(context).hintColor,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: isSelected ? Theme.of(context).cardColor.withValues(alpha: 0.2) : Theme.of(context).cardColor.withValues(alpha: 0.4),
                ),
                child: Text(
                  fromHistory ? orderCount.toString() : length.toString(),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: Dimensions.paddingSizeSmall),

      ]),
    );
  }

  static (IconData, Color) _statusStyle(String status) {
    switch(status) {
      case 'pending': return (Icons.access_time_rounded, const Color(0xFFF08A24));
      case 'confirmed': return (Icons.check_rounded, const Color(0xFF0E9E31));
      case 'cooking': return (Icons.soup_kitchen_rounded, const Color(0xFFE5484D));
      case 'ready_for_handover': return (Icons.shopping_bag_rounded, const Color(0xFF3B82F6));
      case 'food_on_the_way': return (Icons.delivery_dining_rounded, const Color(0xFF8B5CF6));
      default: return (Icons.receipt_long_rounded, const Color(0xFF6B7280));
    }
  }
}
