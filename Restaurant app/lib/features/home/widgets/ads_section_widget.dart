import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_snackbar_widget.dart';
import 'package:paustik_poornahar_restaurant/features/profile/controllers/profile_controller.dart';
import 'package:paustik_poornahar_restaurant/features/subscription/controllers/subscription_controller.dart';
import 'package:paustik_poornahar_restaurant/helper/route_helper.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/images.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';

class AdsSectionWidget extends StatelessWidget {
  const AdsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color.alphaBlend(primary.withValues(alpha: 0.03), Theme.of(context).cardColor), Color.alphaBlend(primary.withValues(alpha: 0.10), Theme.of(context).cardColor)],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('want_to_get_highlighted'.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              'create_ads_to_reach_more_customers'.tr,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            ElevatedButton(
              onPressed: () {
                if(Get.find<ProfileController>().modulePermission!.newAds!){
                  Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
                    if(trialEnd) {
                      Get.toNamed(RouteHelper.getCreateAdvertisementRoute());
                    }
                  });
                }else{
                  showCustomSnackBar('you_have_no_permission_to_access_this_feature'.tr);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary, foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 6),
                minimumSize: const Size(0, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('create_ads'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ]),
            ),
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        Container(
          height: 64, width: 64, alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor.withValues(alpha: 0.7)),
          child: Image.asset(Images.adsIcon, height: 34, width: 34, color: primary),
        ),
      ]),
    );
  }
}
