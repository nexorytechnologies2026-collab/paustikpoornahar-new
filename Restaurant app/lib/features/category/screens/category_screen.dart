import 'package:paustik_poornahar_restaurant/common/widgets/empty_state_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:paustik_poornahar_restaurant/common/widgets/custom_image_widget.dart';
import 'package:paustik_poornahar_restaurant/features/category/controllers/category_controller.dart';
import 'package:paustik_poornahar_restaurant/features/category/domain/models/category_model.dart';
import 'package:paustik_poornahar_restaurant/features/category/screens/category_product_screen.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(isRestaurantWise: true, search: '');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: CustomAppBarWidget(title: 'categories'.tr),

      body: GetBuilder<CategoryController>(builder: (categoryController) {

        List<CategoryModel>? categories;

        if(categoryController.categoryList != null) {
          categories = [];
          categories.addAll(categoryController.categoryList!);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await categoryController.getCategoryList(isRestaurantWise: true, search: '');
          },
          child: Column(children: [

            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
              child: SizedBox(
                height: 47,
                child: SearchBar(
                  controller: _searchController,
                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                  elevation: WidgetStatePropertyAll(0),
                  side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.3))),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMedium))),
                  onChanged: (value) {
                    categoryController.getCategoryList(isRestaurantWise: true, search: value);
                  },
                  onSubmitted: (value) {
                    categoryController.getCategoryList(isRestaurantWise: true, search: value);
                  },
                  hintText: 'search_by_category_name'.tr,
                  hintStyle: WidgetStatePropertyAll(
                    robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
                  leading: Icon(CupertinoIcons.search, color: Theme.of(context).hintColor),
                  trailing: _searchController.text.isEmpty ? [const SizedBox()] : _searchController.text.isNotEmpty ? [InkWell(
                    child: Icon(Icons.clear, color: Theme.of(context).hintColor),
                    onTap: () {
                      _searchController.clear();
                      categoryController.clearSearch();
                      categoryController.update();
                    },
                  )] : [const SizedBox()],
                ),
              ),
            ),

            Expanded(
              child: categories != null ? categories.isNotEmpty ? ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: InkWell(
                      onTap: () {
                        Get.to(() => CategoryProductScreen(categoryId: categories![index].id!, categoryName: categories[index].name ?? ''));
                      },
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                        ),
                        child: Row(
                          children: [

                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImageWidget(
                                image: '${categories![index].imageFullUrl}',
                                height: 60, width: 65, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(categories[index].name?.trim() ?? '', style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  categories[index].childesCount! > 0 ? '${categories[index].childesCount} ${'sub_category'.tr}' : 'no_sub_category'.tr,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                ),
                              ]),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Container(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                              ),
                              child: Text(
                                categories[index].productsCount! > 0 ? '${categories[index].productsCount} ${'food'.tr}' : 'no_food_available'.tr,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ) : EmptyStateWidget(title: 'no_category_found'.tr) : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        );
      }),
    );
  }
}