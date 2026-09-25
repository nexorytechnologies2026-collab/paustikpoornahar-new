import 'package:paustik_poornahar_restaurant/common/widgets/confirmation_dialog_widget.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_snackbar_widget.dart';
import 'package:paustik_poornahar_restaurant/features/auth/controllers/auth_controller.dart';
import 'package:paustik_poornahar_restaurant/features/language/controllers/localization_controller.dart';
import 'package:paustik_poornahar_restaurant/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:paustik_poornahar_restaurant/features/menu/domain/models/menu_model.dart';
import 'package:paustik_poornahar_restaurant/features/menu/widgets/profile_image_widget.dart';
import 'package:paustik_poornahar_restaurant/features/profile/controllers/profile_controller.dart';
import 'package:paustik_poornahar_restaurant/features/subscription/controllers/subscription_controller.dart';
import 'package:paustik_poornahar_restaurant/helper/route_helper.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/images.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuButtonWidget extends StatelessWidget {
  final MenuModel menu;
  final bool isProfile;
  final bool isLogout;
  final double height;
  const MenuButtonWidget({super.key, required this.menu, required this.isProfile, required this.isLogout, required this.height});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding:  EdgeInsets.only( bottom:  Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () async {
          if(menu.isBlocked) {
            showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
          }else if(menu.isNotSubscribe){
            showCustomSnackBar('you_have_no_available_subscription'.tr);
          } else if(menu.isLanguage){
            Get.back();
            _manageLanguageFunctionality();
          }else {
            if (isLogout) {
              Get.back();
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.dialog(ConfirmationDialogWidget(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                  Get.find<AuthController>().clearSharedData();
                  await Get.find<ProfileController>().trialWidgetShow(route: RouteHelper.payment);
                  Get.offAllNamed(RouteHelper.getSignInRoute());
                }), useSafeArea: false);
              } else {
                await Get.find<ProfileController>().trialWidgetShow(route: RouteHelper.payment);
                Get.find<AuthController>().clearSharedData();
                Get.toNamed(RouteHelper.getSignInRoute());
              }
            } else {
              if(menu.route.contains(RouteHelper.mySubscription)) {
                Get.offNamed(menu.route);
              } else {
                if (!Get.find<SubscriptionController>().isTrialEndModalShown) {
                  Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
                    if(trialEnd) {
                      Get.offNamed(menu.route);
                    }else {
                      Get.find<SubscriptionController>().setTrialEndModalShown(true);
                    }
                  });
                }
              }
            }
          }
        },
        child: Column(children: [

          Builder(builder: (context) {
            final bool loggedIn = Get.find<AuthController>().isLoggedIn();
            final Color accent = isLogout && loggedIn ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor;
            return Container(
              height: height, width: height,
              padding: EdgeInsets.all(isProfile ? 4 : height * 0.28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: accent.withValues(alpha: 0.08),
                border: Border.all(color: accent.withValues(alpha: 0.15)),
              ),
              alignment: Alignment.center,
              child: isProfile
                  ? ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), child: ProfileImageWidget(size: height))
                  : CustomAssetImageWidget(image: menu.icon, width: height, height: height, color: accent, fit: BoxFit.contain),
            );
          }),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(menu.title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 0.5, height: 1.3, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.85)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),

        ]),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }

}