import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_popup_menu_button.dart';
import 'package:paustik_poornahar_restaurant/features/profile/controllers/profile_controller.dart';
import 'package:paustik_poornahar_restaurant/helper/price_converter_helper.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/images.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';
class BusinessAnalyticsWidget extends StatefulWidget {
  final ProfileController profileController;
  const BusinessAnalyticsWidget({super.key, required this.profileController});

  @override
  State<BusinessAnalyticsWidget> createState() => _BusinessAnalyticsWidgetState();
}

class _BusinessAnalyticsWidgetState extends State<BusinessAnalyticsWidget> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final List<MenuItem> items = [
      MenuItem('all'.tr, null, 0, Colors.blue),
      MenuItem('today'.tr, null, 1, Colors.blue),
      MenuItem('this_week'.tr, null, 2, Colors.indigoAccent),
      MenuItem('this_month'.tr, null, 3, Colors.orange),
    ];
    double totalEarning =  0.0;
    int totalOrders = 0;
    if(widget.profileController.profileModel != null){
      switch(index){
        case 0:
          totalEarning = widget.profileController.profileModel!.totalEarning??0;
          totalOrders = widget.profileController.profileModel!.orderCount??0;
          break;
        case 1:
          totalEarning = widget.profileController.profileModel!.todaysEarning??0;
          totalOrders = widget.profileController.profileModel!.todaysOrderCount??0;
          break;
        case 2:
          totalEarning = widget.profileController.profileModel!.thisWeekEarning??0;
          totalOrders = widget.profileController.profileModel!.thisWeekOrderCount??0;
          break;
        case 3:
          totalEarning = widget.profileController.profileModel!.thisMonthEarning??0;
          totalOrders = widget.profileController.profileModel!.thisMonthOrderCount??0;
          break;
      }
    }
    final Color primary = Theme.of(context).primaryColor;
    final Color accent = Theme.of(context).colorScheme.tertiary;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('business_analytics'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: 2),
            Text(
              'track_your_business_performance'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            ),
          ]),
        ),

        CustomPopupMenuButton(
          items: items,
          onSelected: (int value) {
            setState(() {
              index = value;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              border: Border.all(color: primary.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Text(items[index].title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      Row(children: [
        Expanded(child: _StatCard(
          color: primary, title: 'total_earning'.tr, value: PriceConverter.convertPrice(totalEarning),
          icon: Image.asset(Images.walletBold, height: 24, width: 24, color: primary),
        )),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(child: _StatCard(
          color: accent, title: 'total_orders'.tr, value: '$totalOrders',
          icon: Icon(Icons.room_service_rounded, size: 26, color: accent),
        )),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;
  final Widget icon;
  const _StatCard({required this.color, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Theme.of(context).cardColor, Color.alphaBlend(color.withValues(alpha: 0.05), Theme.of(context).cardColor)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 44, width: 44, alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          child: icon,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(value, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge), textDirection: TextDirection.ltr),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          // Decorative mini bar chart
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (final (double h, double a) in [(10.0, 0.18), (18.0, 0.32), (26.0, 0.55)])
              Container(
                width: 6, height: h, margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: a), borderRadius: BorderRadius.circular(3)),
              ),
          ]),
        ]),
      ]),
    );
  }
}
