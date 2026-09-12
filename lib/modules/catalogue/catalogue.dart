import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/account.dart';
import 'package:stylclick/modules/edit_profile.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/core/services/saved_items_service.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/modules/details.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/core/services/vendor_service.dart';

class CataloguePage extends StatefulWidget {
  final String? initialCategory;
  const CataloguePage({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  List<VendorProduct> _products = [];
  bool _isLoading = false;

  List<VendorProduct> _parseProducts(List list) {
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return VendorProduct.fromJson(m);
    }).toList();
  }

  Future<void> _loadProducts() async {
    try {
      final cachedData = await VendorService.instance.getCachedProducts();
      if (cachedData != null) {
        List? cachedList;
        if (cachedData is List) {
          cachedList = cachedData;
        } else if (cachedData is Map && cachedData['data'] is List) {
          cachedList = cachedData['data'] as List;
        }
        if (cachedList != null) {
          final loaded = _parseProducts(cachedList);
          if (mounted) {
            setState(() {
              _products = loaded;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      log('[CATALOGUE] Failed to load cached products: $e');
    }

    if (_products.isEmpty && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final res = await VendorService.instance.getPublicProducts();
      List? list;
      if (res.data is List) {
        list = res.data as List;
      } else if (res.data is Map && (res.data as Map)['data'] is List) {
        list = (res.data as Map)['data'] as List;
      }
      if (list != null) {
        final loaded = _parseProducts(list);
        if (mounted) setState(() => _products = loaded);
      }
    } catch (e) {
      log('[CATALOGUE] Failed to load products: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    _loadProducts();
    SavedItemsService.instance.itemsNotifier.addListener(_onSavedItemsChanged);
    if (widget.initialCategory != null) {
      selectedCategories = [widget.initialCategory!];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        filterCategories(context);
      });
    }
  }

  void _onSavedItemsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SavedItemsService.instance.itemsNotifier.removeListener(_onSavedItemsChanged);
    super.dispose();
  }

  final List<String> images = [
    catFemaleAsoEbi,
    catMaleAsoEbi,
    catAnkara,
    catReadyToWear,
    catMaterials,
    catSenator,
    catLace,
    catFemaleAsoEbi,
    catMaleAsoEbi,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: buildNotificationDrawer(context),
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: cream,
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _openDrawer,
                    child: Image.asset(
                      menuIcon,
                      height: 24.h,
                      width: 24.w,
                      color: ink,
                    ),
                  ),
                  InkWell(
                    onTap: _openEndDrawer,
                    child: Image.asset(
                      notificationIcon,
                      height: 24.h,
                      width: 24.w,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
            24.height,
            // Search & Filter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: sand),
                        boxShadow: [
                          BoxShadow(
                            color: ink.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: ink.withOpacity(0.5), size: 20.sp),
                          12.width,
                          Expanded(
                            child: TextField(
                              style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                              decoration: InputDecoration(
                                hintText: 'Search styles...',
                                hintStyle: TextStyle(fontFamily: 'Cinta', 
                                  color: ink.withOpacity(0.4),
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  12.width,
                  InkWell(
                    onTap: () => filterCategories(context),
                    child: Container(
                      height: 52.h,
                      width: 52.h,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: sand),
                      ),
                      child: Icon(Icons.tune, color: primary, size: 24.sp),
                    ),
                  ),
                ],
              ),
            ),
            24.height,
            // Staggered Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                color: primary,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: primary))
                    : _products.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 48.sp, color: textLight.withOpacity(0.5)),
                                  12.height,
                                  Text(
                                    'No products in catalogue',
                                    style: TextStyle(fontFamily: 'Cinta', fontSize: 15.sp, color: textLight, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : MasonryGridView.count(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(left: 17.w, right: 17.w, bottom: 120.h),
                            crossAxisCount: 2,
                            mainAxisSpacing: 8.w,
                            crossAxisSpacing: 8.w,
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                        double imageHeight = index.isEven ? 200.h : 260.h;
                        final String? firstImage = product.imagePaths.isNotEmpty ? product.imagePaths.first : null;
                        
                        return GestureDetector(
                          onTap: () => CategoryDetails(
                            name: product.name,
                            price: product.price,
                            description: product.description,
                            imagePaths: product.imagePaths,
                            category: product.category,
                            stock: product.stock,
                            isOwner: false,
                            storeName: product.vendorName,
                            vendorId: product.vendorId,
                            vendorType: product.vendorType,
                            vendorEmail: product.vendorEmail,
                            vendorPhone: product.vendorPhone,
                            vendorAddress: product.vendorAddress,
                            vendorBio: product.vendorBio,
                            vendorSpecialization: product.vendorSpecialization,
                            vendorBanner: product.vendorBanner,
                            vendorAvatar: product.vendorAvatar,
                            rating: product.rating,
                          ).launch(context),
                          onDoubleTap: () {
                            final firstImg = product.imagePaths.isNotEmpty ? product.imagePaths.first : femaleAsoebi;
                            final isAdded = SavedItemsService.instance.toggleFavorite(
                              SavedItemModel(
                                id: 'fav_${product.name}_${DateTime.now().millisecondsSinceEpoch}',
                                name: product.name,
                                price: product.price,
                                storeName: product.vendorName ?? 'Vendor',
                                imagePath: firstImg,
                                category: product.category,
                                rating: (product.rating != null && product.rating! > 0) ? product.rating!.toStringAsFixed(1) : '0.0 (0)',
                                vendorId: product.vendorId,
                                vendorType: product.vendorType,
                                vendorEmail: product.vendorEmail,
                                vendorPhone: product.vendorPhone,
                                vendorAddress: product.vendorAddress,
                                vendorBio: product.vendorBio,
                                vendorSpecialization: product.vendorSpecialization,
                                vendorBanner: product.vendorBanner,
                                vendorAvatar: product.vendorAvatar,
                                description: product.description,
                              ),
                            );
                            setState(() {});
                            toast(isAdded ? 'Added to Saved Items!' : 'Removed from Saved Items');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: white,
                              border: Border.all(color: sand),
                              boxShadow: [
                                BoxShadow(
                                  color: ink.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: firstImage == null
                                      ? Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                      : (firstImage.startsWith('http://') || firstImage.startsWith('https://')
                                          ? CachedNetworkImage(
                                              imageUrl: firstImage,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: imageHeight,
                                              placeholder: (_, __) => Shimmer.fromColors(
                                                baseColor: sand,
                                                highlightColor: Colors.white,
                                                child: Container(width: double.infinity, height: imageHeight, color: sand),
                                              ),
                                              errorWidget: (_, __, ___) => Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: imageHeight),
                                            )
                                          : (firstImage.startsWith('assets/')
                                              ? Image.asset(firstImage, fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                              : (File(firstImage).existsSync()
                                                  ? Image.file(File(firstImage), fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                                  : Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: imageHeight)))),
                                ),
                                12.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Cinta', 
                                          fontSize: 14.sp,
                                          color: ink,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                     GestureDetector(
                                       onTap: () {
                                         final firstImg = product.imagePaths.isNotEmpty ? product.imagePaths.first : femaleAsoebi;
                                         final isAdded = SavedItemsService.instance.toggleFavorite(
                                           SavedItemModel(
                                             id: 'fav_${product.name}_${DateTime.now().millisecondsSinceEpoch}',
                                             name: product.name,
                                             price: product.price,
                                             storeName: product.vendorName ?? 'Vendor',
                                             imagePath: firstImg,
                                             category: product.category,
                                             rating: (product.rating != null && product.rating! > 0) ? product.rating!.toStringAsFixed(1) : '0.0 (0)',
                                             vendorId: product.vendorId,
                                             vendorType: product.vendorType,
                                             vendorEmail: product.vendorEmail,
                                             vendorPhone: product.vendorPhone,
                                             vendorAddress: product.vendorAddress,
                                             vendorBio: product.vendorBio,
                                             vendorSpecialization: product.vendorSpecialization,
                                             vendorBanner: product.vendorBanner,
                                             vendorAvatar: product.vendorAvatar,
                                             description: product.description,
                                           ),
                                         );
                                         setState(() {});
                                         toast(isAdded ? 'Added to Saved Items!' : 'Removed from Saved Items');
                                       },
                                       child: Image.asset(
                                         favoriteIcon,
                                         height: 18.h,
                                         width: 18.w,
                                         color: SavedItemsService.instance.isFavorited(product.name) ? primary : ink.withOpacity(0.3),
                                       ),
                                     ),
                                   ],
                                 ),
                                 6.height,
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: (product.rating != null && product.rating! > 0) ? Colors.amber : textLight.withOpacity(0.3),
                                        size: 14.sp,
                                      ),
                                      2.width,
                                      Text(
                                        (product.rating != null && product.rating! > 0)
                                            ? product.rating!.toStringAsFixed(1)
                                            : '0.0 (0)',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          color: (product.rating != null && product.rating! > 0) ? ink : textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                8.height,
                                Text(
                                  'NGN ${formatPriceNoDecimal(product.price)}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13.sp,
                                    color: primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> selectedCategories = [];
  final List<String> categories = [
    'Ankara Styles',
    'Lace Asoebi',
    'Senator & Kaftans',
    'Corporate Suits',
    'Wedding Gowns',
    'Agbada Sets',
    'Casual Wears',
    'Kids Collection',
    'Bespoke Wears'
  ];

  filterCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: logicalHeight() * 0.75,
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: sand,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  24.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Selection',
                        style: TextStyle(
                          fontFamily: 'Cinta',
                          fontSize: 24.sp,
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedCategories.clear();
                          });
                        },
                        child: Text(
                          'CLEAR',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            color: textLight,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  12.height,
                  Text(
                    'Select categories to personalize your feed',
                    style: TextStyle(fontFamily: 'Cinta', 
                      fontSize: 14.sp,
                      color: textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  32.height,
                  Text(
                    'CATEGORIES',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 12.sp,
                      color: ink,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  16.height,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: categories.map((category) {
                          bool isSelected = selectedCategories.contains(category);
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedCategories.remove(category);
                                } else {
                                  selectedCategories.add(category);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isSelected ? primary : white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected ? primary : sand,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primary.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                category,
                                style: TextStyle(fontFamily: 'Cinta', 
                                  fontSize: 13.sp,
                                  color: isSelected ? white : ink,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  24.height,
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          colors: [primary, primaryGradient],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.montserrat(
                            color: white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  10.height,
                ],
              ),
            );
          },
        );
      },
    );
  }



  Widget buildNotificationDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: cream),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            60.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Cinta',
                  fontSize: 24.sp,
                  color: primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            20.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Divider(color: sand, thickness: 1),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                children: [
                  _buildNotificationItem(
                    'Order Confirmed',
                    'Your Aso-ebi order #4290 has been received.',
                    '2m ago',
                    FeatherIcons.checkCircle,
                  ),
                  _buildNotificationItem(
                    'Promotion',
                    'Get 20% off on all Ankara materials this weekend!',
                    '1h ago',
                    FeatherIcons.tag,
                  ),
                  _buildNotificationItem(
                    'Update',
                    'Your measurements have been successfully updated.',
                    '5h ago',
                    FeatherIcons.user,
                  ),
                  _buildNotificationItem(
                    'Payment Successful',
                    'Wallet top-up of NGN 50,000 successful.',
                    'Yesterday',
                    FeatherIcons.creditCard,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String sub, String time, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: white,
              shape: BoxShape.circle,
              border: Border.all(color: sand),
            ),
            child: Icon(icon, color: primary, size: 20.sp),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontFamily: 'Cinta', 
                          fontSize: 14.sp,
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.width,
                    Text(
                      time,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
                4.height,
                Text(
                  sub,
                  style: TextStyle(fontFamily: 'Cinta', 
                    fontSize: 12.sp,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
