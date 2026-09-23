import 'dart:async';
import 'package:paustik_poornahar/features/auth/controllers/auth_controller.dart';
import 'package:paustik_poornahar/features/cart/controllers/cart_controller.dart';
import 'package:paustik_poornahar/features/language/controllers/localization_controller.dart';
import 'package:paustik_poornahar/features/notification/domain/models/notification_body_model.dart';
import 'package:paustik_poornahar/features/splash/controllers/splash_controller.dart';
import 'package:paustik_poornahar/features/splash/controllers/theme_controller.dart';
import 'package:paustik_poornahar/features/favourite/controllers/favourite_controller.dart';
import 'package:paustik_poornahar/features/splash/domain/models/deep_link_body.dart';
import 'package:paustik_poornahar/helper/notification_helper.dart';
import 'package:paustik_poornahar/helper/responsive_helper.dart';
import 'package:paustik_poornahar/helper/route_helper.dart';
import 'package:paustik_poornahar/theme/dark_theme.dart';
import 'package:paustik_poornahar/theme/light_theme.dart';
import 'package:paustik_poornahar/util/app_constants.dart';
import 'package:paustik_poornahar/util/messages.dart';
import 'package:paustik_poornahar/common/widgets/cookies_view_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'helper/get_di.dart' as di;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  DeepLinkBody? linkBody;

  if(GetPlatform.isWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: "AIzaSyCwExuTburoBNnB1a3W-3y_kLoGWLDEUB4",
      authDomain: "paushtikpoornaahar-576be.firebaseapp.com",
      projectId: "paushtikpoornaahar-576be",
      storageBucket: "paushtikpoornaahar-576be.firebasestorage.app",
      messagingSenderId: "859076248736",
      appId: "1:859076248736:web:7a3a972180d0e636a3f5c5",
      measurementId: "G-71TBYZYXHZ",
    ));
  }else if(GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCe3XtGDcgQs9OGJONh-Qg7saykxhSRSkc',
        appId: '1:859076248736:android:c9fe702c5e8a6274a3f5c5',
        messagingSenderId: '859076248736',
        projectId: 'paushtikpoornaahar-576be',
        storageBucket: 'paushtikpoornaahar-576be.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }catch(_) {}

  runApp(MyApp(languages: languages, body: body, linkBody: linkBody));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  final DeepLinkBody? linkBody;
  const MyApp({super.key, required this.languages, required this.body, required this.linkBody});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    _route();
  }

  Future<void> _route() async {
    if(GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if(!Get.find<AuthController>().isLoggedIn() && !Get.find<AuthController>().isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/) {
        await Get.find<AuthController>().guestLogin();
      }
      if(Get.find<AuthController>().isLoggedIn() || Get.find<AuthController>().isGuestLoggedIn()) {
        Get.find<CartController>().getCartDataOnline();
      }
      Get.find<SplashController>().getConfigData(fromMainFunction: true);
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().updateToken();
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? const SizedBox() : GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? dark : light,
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body, widget.linkBody),
            getPages: RouteHelper.routes,
            defaultTransition: GetPlatform.isWeb ? Transition.fadeIn : Transition.topLevel,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (BuildContext context, widget) {
              return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)), child: Material(
                child: SafeArea(
                  top: false, bottom: GetPlatform.isAndroid,
                  child: Stack(children: [
                    widget!,

                    GetBuilder<SplashController>(builder: (splashController){

                      if(!splashController.savedCookiesData || !splashController.getAcceptCookiesStatus(splashController.configModel?.cookiesText ?? "")){
                        return ResponsiveHelper.isWeb() ? const Align(alignment: Alignment.bottomCenter, child: CookiesViewWidget()) : const SizedBox();
                      }else{
                        return const SizedBox();
                      }
                    })
                  ]),
                )),
              );
            }
          );
        });
      });
    });
  }
}