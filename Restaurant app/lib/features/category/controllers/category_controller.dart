import 'package:paustik_poornahar_restaurant/features/category/domain/models/category_model.dart';
import 'package:paustik_poornahar_restaurant/features/category/domain/services/categoty_service_interface.dart';
import 'package:paustik_poornahar_restaurant/features/restaurant/domain/models/product_model.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController implements GetxService {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  List<CategoryModel>? _subCategoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;

  String? _selectedCategoryID;
  String? get selectedCategoryID => _selectedCategoryID;

  String? _selectedSubCategoryID;
  String? get selectedSubCategoryID => _selectedSubCategoryID;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  int? _selectedCategoryIndex = 0;
  int? get selectedCategoryIndex => _selectedCategoryIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;

  List<Product>? _itemList;
  List<Product>? get itemList => _itemList;

  int? _selectedSubCategoryId;
  int? get selectedSubCategoryId => _selectedSubCategoryId;

  int? _isSubCategory = 0;
  int? get isSubCategory => _isSubCategory;

  int? _selectedSubCategoryIndex = 0;
  int? get selectedSubCategoryIndex => _selectedSubCategoryIndex;

  Future<void> getCategoryList({bool isRestaurantWise = false, String? search}) async {
    _categoryList = null;
    List<CategoryModel>? categoryList = await categoryServiceInterface.getCategoryList(isRestaurantWise: isRestaurantWise, search: search);
    if(categoryList != null) {
      _categoryList = [];
      _categoryList = categoryList;
    }
    update();
  }

  Future<void> getSubCategoryList(int categoryID, {bool isRestaurantWise = false}) async {
    List<CategoryModel>? subCategoryList = await categoryServiceInterface.getSubCategoryList(categoryID, isRestaurantWise: isRestaurantWise);
    if(subCategoryList != null){
      _subCategoryList = [];
      _subCategoryList = subCategoryList;
    }
    update();
  }

  Future<void> initCategoryData(Product? product) async {
    _subCategoryList = null;
    _selectedCategoryID = null;
    await getCategoryList();
    if (product != null && product.categoryIds?.isNotEmpty == true) {
      final mainId = product.categoryIds![0].id;
      if (mainId != null) {
        _selectedCategoryID = mainId;
        // setSelectedCategory(mainId, isUpdate: false);

        if (product.categoryIds!.length > 1) {
          final subId = product.categoryIds![1].id;
          if (subId != null) {
            await getSubCategoryList(int.parse(mainId));
            setSelectedSubCategory(subId, isUpdate: false);
          }
        } else {
          await getSubCategoryList(int.parse(mainId));
        }
      }
    }
    update();
  }

  void setSelectedCategory(String? id, {bool isUpdate = true}) {
    _selectedCategoryID = id;
    _selectedSubCategoryID = null;
    if(id != null) getSubCategoryList(int.parse(id));
    if (isUpdate) update();
  }

  void setSelectedSubCategory(String id, {bool isUpdate = true}) {
    _selectedSubCategoryID = id;
    if (isUpdate) update();
  }

  Future<void> setCategoryAndSubCategoryForAiData({String? categoryId, String? subCategoryId}) async {
    if(categoryId != null){
      _selectedCategoryID = categoryId;
      await getSubCategoryList(int.parse(categoryId)).then((value) {
        if(_subCategoryList != null && _subCategoryList!.isNotEmpty){
          if(subCategoryId != null && _subCategoryList!.any((element) => element.id == int.parse(subCategoryId))){
            _selectedSubCategoryID = subCategoryId;
          }
          update();
        }
      });
    }
    update();
  }

  void expandedUpdate(bool status){
    _isExpanded = status;
    update();
  }

  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    update();
  }

  Future<void> getCategoryItemList({required String offset, required int id, bool willUpdate = true}) async {
    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _itemList = null;
      if(willUpdate) {
        update();
      }
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      ProductModel? itemModel = await categoryServiceInterface.getCategoryItemList(offset: offset, id: id, isSubCategory: _isSubCategory!);
      if (itemModel != null) {
        if (offset == '1') {
          _itemList = [];
        }
        _itemList!.addAll(itemModel.products!);
        _pageSize = itemModel.totalSize;
        _isLoading = false;
        update();
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void setSelectedSubCategoryIndex(int? index, bool notify) {
    _selectedSubCategoryIndex = index;
    if (notify) {
      update();
    }
  }

  void clearSelectedSubCategoryId() {
    _selectedSubCategoryId = null;
    _isSubCategory = 0;
  }

  void setSelectedSubCategoryId(int? subCategoryId) {
    _selectedSubCategoryId = subCategoryId;
    _isSubCategory = 1;
    if( _selectedSubCategoryId != null) {
      getCategoryItemList(offset: '1', id: _selectedSubCategoryId!);
    }
    update();
  }

  void clearSearch({bool isUpdate = true}) {
    getCategoryList(isRestaurantWise: true, search: '');
    if(isUpdate) {
      update();
    }
  }

}