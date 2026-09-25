import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:paustik_poornahar_restaurant/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:paustik_poornahar_restaurant/features/disbursement/helper/disbursement_helper.dart';
import 'package:paustik_poornahar_restaurant/features/home/screens/home_screen.dart';
import 'package:paustik_poornahar_restaurant/features/menu/screens/menu_screen.dart';
import 'package:paustik_poornahar_restaurant/features/order/screens/order_history_screen.dart';
import 'package:paustik_poornahar_restaurant/features/payment/screens/wallet_screen.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/screens/restaurant_screen.dart';
import 'package:paustik_poornahar_restaurant/features/subscription/controllers/subscription_controller.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  const DashboardScreen({super.key, required this.pageIndex});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  DisbursementHelper disbursementHelper = DisbursementHelper();
  bool _canExit = false;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const OrderHistoryScreen(),
      const RestaurantScreen(),
      const WalletScreen(),
      Container(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    showDisbursementWarningMessage();

    if(Get.find<SubscriptionController>().isTrialEndModalShown){
      Get.find<SubscriptionController>().trialEndBottomSheet();
    }
  }

  Future<void> showDisbursementWarningMessage() async {
    disbursementHelper.enableDisbursementWarningMessage(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if(_pageIndex != 0) {
          _setPage(0);
        }else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          ));
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(

        bottomNavigationBar: !GetPlatform.isMobile ? const SizedBox() : SafeArea(
          child: Container(
            height: 64,
            margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              BottomNavItemWidget(imageData: Images.homeButton, title: 'home'.tr, isSelected: _pageIndex == 0, onTap: () => _setPage(0)),
              BottomNavItemWidget(imageData: Images.orderButton, title: 'orders'.tr, isSelected: _pageIndex == 1, onTap: () => _setPage(1)),
              BottomNavItemWidget(imageData: Images.storeButton, title: 'restaurant'.tr, isSelected: _pageIndex == 2, onTap: () => _setPage(2)),
              BottomNavItemWidget(imageData: Images.walletButton, title: 'wallet'.tr, isSelected: _pageIndex == 3, onTap: () => _setPage(3)),
              BottomNavItemWidget(imageData: Images.menuButton, title: 'menu'.tr, isSelected: _pageIndex == 4, onTap: () {
                Get.bottomSheet(const MenuScreen(), backgroundColor: Colors.transparent, isScrollControlled: true);
              }),
            ]),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    if (!Get.find<SubscriptionController>().isTrialEndModalShown) {
      Get.find<SubscriptionController>().trialEndBottomSheet().then((trialEnd) {
        if (trialEnd) {
          setState(() {
            _pageController!.jumpToPage(pageIndex);
            _pageIndex = pageIndex;
          });
        } else {
          Get.find<SubscriptionController>().setTrialEndModalShown(true);
        }
      });
    }
  }
}