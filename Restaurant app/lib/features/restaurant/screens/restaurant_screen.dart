import 'package:paustik_poornahar_restaurant/common/widgets/status_chip_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_image_widget.dart';
import 'package:paustik_poornahar_restaurant/features/profile/controllers/profile_controller.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/controllers/restaurant_controller.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/widgets/announcement_bottom_sheet.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/widgets/filter_data_bottom_sheet.dart';
import 'package:paustik_poornahar_restaurant/features/profile/domain/models/profile_model.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/widgets/product_view_widget.dart';
import 'package:paustik_poornahar_restaurant/helper/date_converter_helper.dart';
import 'package:paustik_poornahar_restaurant/helper/price_converter_helper.dart';
import 'package:paustik_poornahar_restaurant/helper/route_helper.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/images.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;
  final bool? _review = Get.find<ProfileController>().profileModel!.restaurants![0].reviewsSection;

  @override
  void initState() {
    super.initState();


    _tabController = TabController(length: _review! ? 2 : 1, initialIndex: 0, vsync: this);
    _tabController!.addListener(() {
      Get.find<RestaurantController>().setTabIndex(_tabController!.index);
    });
    Get.find<RestaurantController>().resetCategorySelection();
    Get.find<RestaurantController>().getProductList(offset: '1', foodType: 'all', stockType: 'all', categoryId: 0, isUpdate: false);
    Get.find<RestaurantController>().getRestaurantReviewList(Get.find<ProfileController>().profileModel!.restaurants![0].id, '');
    Get.find<RestaurantController>().getRestaurantCategories();

    _scrollController.addListener(_scrollListener);

  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!Get.find<RestaurantController>().isTitleVisible && _scrollController.offset > 100) {
        Get.find<RestaurantController>().showTitle();
      }
    } else if(_scrollController.position.userScrollDirection == ScrollDirection.forward && _scrollController.offset < 100) {
      if (Get.find<RestaurantController>().isTitleVisible) {
        Get.find<RestaurantController>().hideTitle();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        Restaurant? restaurant = profileController.profileModel != null ? profileController.profileModel!.restaurants![0] : null;
        bool isFilterActive = restController.selectedFoodType != 'all' || restController.selectedStockType != 'all';

        return Get.find<ProfileController>().modulePermission == null ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : Get.find<ProfileController>().modulePermission!.myRestaurant! ? Scaffold(
          appBar: CustomAppBarWidget(title: 'my_restaurant'.tr, isBackButtonExist: false),

          body: restaurant != null ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            slivers: [

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.08)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Stack(clipBehavior: Clip.none, children: [
                      SizedBox(
                        height: 130, width: double.infinity,
                        child: Stack(fit: StackFit.expand, children: [
                          CustomImageWidget(fit: BoxFit.cover, placeholder: Images.restaurantCover, image: '${restaurant.coverPhotoFullUrl}'),
                          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.35)],
                          ))),
                        ]),
                      ),

                      Positioned(
                        top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                        child: Material(
                          color: Theme.of(context).cardColor, shape: const CircleBorder(), elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Get.toNamed(RouteHelper.getRestaurantEditRoute(restaurant)),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Icon(Icons.edit_rounded, size: 18, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: Dimensions.paddingSizeDefault, bottom: -36,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
                          ),
                          child: ClipOval(child: CustomImageWidget(image: '${restaurant.logoFullUrl}', height: 76, width: 76, fit: BoxFit.cover)),
                        ),
                      ),
                    ]),

                    Padding(
                      padding: const EdgeInsets.only(left: 108, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(restaurant.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Theme.of(context).hintColor),
                          const SizedBox(width: 4),
                          Flexible(child: Text(
                            '${'created_at'.tr} ${DateConverter.utcToDate(restaurant.createdAt ?? '')}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          )),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                      child: Row(children: [
                        Expanded(child: CountCardWidget(title: 'products'.tr, iconData: Icons.fastfood_rounded, count: profileController.profileModel?.productCount ?? 0, color: Theme.of(context).primaryColor)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: CountCardWidget(title: 'orders'.tr, iconData: Icons.receipt_long_rounded, count: profileController.profileModel?.orderCount ?? 0, color: const Color(0xFFF08A24))),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(child: CountCardWidget(title: 'reviews'.tr, iconData: Icons.star_rounded, count: profileController.profileModel?.reviewCount ?? 0, color: Theme.of(context).colorScheme.tertiary)),
                      ]),
                    ),
                  ]),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [
                        Color.alphaBlend(Theme.of(context).primaryColor.withValues(alpha: 0.03), Theme.of(context).cardColor),
                        Color.alphaBlend(Theme.of(context).primaryColor.withValues(alpha: 0.10), Theme.of(context).cardColor),
                      ],
                    ),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.18)),
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  child: Row(children: [
                    Container(
                      height: 44, width: 44, alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor.withValues(alpha: 0.8)),
                      child: Icon(Icons.campaign_rounded, size: 26, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('make_an_announcement'.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        Text(
                          'this_will_be_shown_in_the_user_app_web'.tr,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                        ),
                      ]),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    ElevatedButton(
                      onPressed: () {
                        showCustomBottomSheet(child: AnnouncementBottomSheet(announcementStatus: restaurant.isAnnouncementActive!, announcementMessage: restaurant.announcementMessage ?? ''));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 6),
                        minimumSize: const Size(0, 32), tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
                      ),
                      child: Text('create'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white)),
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeDefault)),

              SliverToBoxAdapter(child: Center(child: Container(
                width: 1170,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  restaurant.discount != null ? Container(
                    width: context.width,
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                      Text(
                        '${restaurant.discount!.discount}% ${'off'.tr}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                        textDirection: TextDirection.ltr,
                      ),

                      Text(
                        '${'enjoy'.tr} ${restaurant.discount!.discount}% ${'off_on_all_categories'.tr}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                        textDirection: TextDirection.ltr,
                      ),
                      SizedBox(height: (restaurant.discount!.minPurchase != 0 || restaurant.discount!.maxDiscount != 0) ? 5 : 0),

                      restaurant.discount!.minPurchase != 0 ? Text(
                        '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.minPurchase)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        textDirection: TextDirection.ltr,
                      ) : const SizedBox(),

                      restaurant.discount!.maxDiscount != 0 ? Text(
                        '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.maxDiscount)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        textDirection: TextDirection.ltr,
                      ) : const SizedBox(),

                    ]),
                  ) : const SizedBox(),

                  (restaurant.delivery! && restaurant.freeDelivery!) ? Text(
                    'free_delivery'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  ) : const SizedBox(),

                ]),
              ))),

              Get.find<ProfileController>().modulePermission!.food! ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                  child: Container(
                    color: Theme.of(context).cardColor,
                    child: Column(children: [
                      SizedBox(height: restController.isTitleVisible ? 10 : 0),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                          Text('all_foods'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                          const SizedBox(width: 20),

                          InkWell(
                            onTap: () {
                              showCustomBottomSheet(child: const FilterDataBottomSheet());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: isFilterActive ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: isFilterActive ? 1 : 0.3)),
                              ),
                              child: Icon(Icons.tune, color:isFilterActive ? Theme.of(context).cardColor : Theme.of(context).primaryColor),
                            ),
                          ),

                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      restController.categoryNameList != null ? SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: restController.categoryNameList!.length,
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return StatusChipWidget(
                              title: index == 0 ? 'all'.tr : restController.categoryNameList![index].trim(),
                              isSelected: index == restController.categoryIndex,
                              onTap: () => restController.setCategory(index: index, foodType: 'all', stockType: 'all'),
                            );
                          },
                        ),
                      ) : SizedBox(
                        height: 30,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
                                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  height: 10, width: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),

                    ]),
                  ),
                ),
              ) : const SliverToBoxAdapter(child: SizedBox()),

              Get.find<ProfileController>().modulePermission!.food! ? SliverToBoxAdapter(
                child: ProductViewWidget(scrollController: _scrollController, type: restController.selectedFoodType, onVegFilterTap: (String type) {
                  Get.find<RestaurantController>().getProductList(offset: '1', foodType: type, stockType: restController.selectedStockType, categoryId: restController.categoryId);
                }),
              ) : const SliverToBoxAdapter(child: SizedBox()),

            ],
          ) : const Center(child: CircularProgressIndicator()),
        ) : Scaffold(
          body: Center(child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium)),
        );
      });
    });
  }
}

class CountCardWidget extends StatelessWidget {
  final String title;
  final IconData iconData;
  final int count;
  final Color color;
  const CountCardWidget({super.key, required this.title, required this.iconData, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.06), Theme.of(context).cardColor),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FittedBox(
          fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(count.toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge + 4, height: 1.1, color: color)),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(children: [
          Expanded(child: FittedBox(
            fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text(title, maxLines: 1, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          )),
          const SizedBox(width: 4),
          Container(
            height: 24, width: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            child: Icon(iconData, size: 14, color: color),
          ),
        ]),
      ]),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 112;

  @override
  double get minExtent => 112;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 100 || oldDelegate.minExtent != 100 || child != oldDelegate.child;
  }
}