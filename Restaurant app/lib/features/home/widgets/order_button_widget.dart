import 'package:paustik_poornahar_restaurant/common/widgets/status_chip_widget.dart';
import 'package:paustik_poornahar_restaurant/features/order/controllers/order_controller.dart';
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
    final String status = fromHistory ? orderController.statusList[index] : orderController.runningOrders![index].status;
    final (IconData icon, Color color) = StatusChipWidget.styleFor(status);

    return StatusChipWidget(
      title: title,
      isSelected: (fromHistory ? orderController.historyIndex : orderController.orderIndex) == index,
      count: fromHistory ? (orderCount ?? 0) : orderController.runningOrders![index].orderList.length,
      icon: icon, color: color,
      onTap: () => fromHistory ? orderController.setHistoryIndex(index) : orderController.setOrderIndex(index),
    );
  }
}
