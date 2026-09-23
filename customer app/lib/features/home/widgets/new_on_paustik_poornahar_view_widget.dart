import 'package:paustik_poornahar/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:paustik_poornahar/features/home/widgets/restaurants_card_widget.dart';
import 'package:paustik_poornahar/features/restaurant/controllers/restaurant_controller.dart';
import 'package:paustik_poornahar/helper/responsive_helper.dart';
import 'package:paustik_poornahar/helper/route_helper.dart';
import 'package:paustik_poornahar/util/app_constants.dart';
import 'package:paustik_poornahar/util/dimensions.dart';
import 'package:paustik_poornahar/util/styles.dart';
import 'package:paustik_poornahar/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewOnPaustikPoornaharViewWidget extends StatelessWidget {
  final bool isLatest;
  const NewOnPaustikPoornaharViewWidget({super.key, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
        return (restController.latestRestaurantList != null && restController.latestRestaurantList!.isEmpty) ? const SizedBox() : Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
          child: Container(
            width: Dimensions.webMaxWidth,
            height: 210,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${'new_on'.tr} ${AppConstants.appName}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),

                    ArrowIconButtonWidget(
                      onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(isLatest ? 'latest' : '')),
                    ),
                  ]),
                ),


                restController.latestRestaurantList != null ? SizedBox(
                  height: 130,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                    itemCount: restController.latestRestaurantList!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.getRestaurantRoute(restController.latestRestaurantList![index].id, slug: restController.latestRestaurantList![index].slug ?? ''),
                                arguments: RestaurantScreen(restaurant: restController.latestRestaurantList![index]),
                              );
                            },
                            child: RestaurantsCardWidget(
                              isNewOnPaustikPoornahar: true,
                              restaurant: restController.latestRestaurantList![index],
                            ),
                          ),
                        );
                      },
                  ),
                ) : const RestaurantsCardShimmer(isNewOnPaustikPoornahar: false),
             ],
            ),

          ),
        );
      }
    );
  }
}
