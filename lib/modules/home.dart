import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stylclick/modules/details.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/core/services/vendor_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/modules/buy-fabrics/buy_fabrics.dart';
import 'package:stylclick/modules/edit_profile.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/select-tailor/select_tailor.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/modules/vendor/become_rider.dart';
import 'package:stylclick/modules/catalogue/catalogue.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/core/services/saved_items_service.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/utils/helpers.dart';

import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/account.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';
import '../shared/widgets/custom_textfield.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'details.dart';
import 'package:stylclick/modules/admin/admin_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      log('[HOME] Failed to load cached products: $e');
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
      log('[HOME] Failed to load products: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    SavedItemsService.instance.itemsNotifier.addListener(_onSavedItemsChanged);
    _scrollController.addListener(() {
      if (_scrollController.offset > 15) {
        if (!_isScrolled) {
          setState(() {
            _isScrolled = true;
          });
        }
      } else {
        if (_isScrolled) {
          setState(() {
            _isScrolled = false;
          });
        }
      }
    });
  }

  void _onSavedItemsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SavedItemsService.instance.itemsNotifier.removeListener(_onSavedItemsChanged);
    _scrollController.dispose();
    super.dispose();
  }

  // Easter egg: 10-tap counter for admin dashboard
  int _carouselTapCount = 0;
  DateTime _lastTapTime = DateTime.now();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  final List<String> images = [
    catFemaleAsoEbi,
    catMaleAsoEbi,
    catAnkara,
    catReadyToWear,
    catMaterials,
    catSenator,
    catLace,
  ];

  final List<String> categoriesText = [
    'Female\nAso-ebi',
    'Male\nAso-ebi',
    'Ankara',
    'Ready to\nWear',
    'Materials',
    'Senator\nStyles',
    'Lace\nStyles'
  ];

  final List<String> categoriesImages = [
    catFemaleAsoEbi,
    catMaleAsoEbi,
    catAnkara,
    catReadyToWear,
    catMaterials,
    catSenator,
    catLace,
  ];

  final List<Map<String, String>> carouselData = [
    {'title': 'Premium Tailoring', 'sub': 'Expert hands for your perfect fit.'},
    {'title': 'Quality Fabrics', 'sub': 'Sourced from the finest collections.'},
    {'title': 'Swift Logistics', 'sub': 'Delivered to your doorstep on time.'},
    {'title': 'Traditional Styles', 'sub': 'Celebrating heritage with every stitch.'},
    {'title': 'Modern Cuts', 'sub': 'Contemporary fashion for the bold.'},
    {'title': 'Asoebi Special', 'sub': 'Look stunning at your next event.'},
    {'title': 'Ready to Wear', 'sub': 'Instant elegance for any occasion.'},
    {'title': 'Fabric Sourcing', 'sub': 'Discover unique prints and textures.'},
    {'title': 'Design Your Fit', 'sub': 'Your measurements, our masterpiece.'},
    {'title': 'Style Consulting', 'sub': 'Talk to our fashion experts today.'},
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> carouselImages = List.generate(10, (index) => categoriesImages[index % categoriesImages.length]);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: buildNotificationDrawer(context),
      backgroundColor: cream,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadProducts,
              color: primary,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header
                Container(
                  width: double.infinity,
                  color: cream,
                  padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                      ),
                      const Spacer(),
                      Image.asset(
                        homeLogo,
                        height: 24.h,
                      ),
                      const Spacer(),
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
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
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
                            hintText: 'Search for tailors or fabrics...',
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
              24.height,
              // Carousel
              Center(
                child: CarouselSlider(
                  items: List.generate(10, (index) {
                    final data = carouselData[index];
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            final now = DateTime.now();
                            // Reset counter if more than 3 seconds since last tap
                            if (now.difference(_lastTapTime).inSeconds > 3) {
                              _carouselTapCount = 0;
                            }
                            _lastTapTime = now;
                            _carouselTapCount++;
                            if (_carouselTapCount >= 10) {
                              _carouselTapCount = 0;
                              const AdminDashboard().launch(context);
                            }
                          },
                          child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 17.w),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primary, primaryGradient],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(16.r),
                                      bottomRight: Radius.circular(16.r),
                                    ),
                                    child: Image.asset(
                                      carouselImages[index],
                                      width: 150.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 24.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        data['title']!,
                                        style: TextStyle(fontFamily: 'Cinta', 
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      4.height,
                                      SizedBox(
                                        width: 160.w,
                                        child: Text(
                                          data['sub']!,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 120.h,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
              24.height,
              // Quick Access
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickAccessItem(
                        context,
                        'Tailors',
                        sewingMachine,
                        () => const SelectTailor().launch(context),
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: _buildQuickAccessItem(
                        context,
                        'Fabrics',
                        fabric,
                        () => const BuyFabrics().launch(context),
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: _buildQuickAccessItem(
                        context,
                        'Logistics',
                        dispatchRider,
                        () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                              title: Row(
                                children: [
                                  Image.asset(dispatchRider, width: 28.w, height: 28.h),
                                  10.width,
                                  Text(
                                    'StyClick Express',
                                    style: TextStyle(fontFamily: cinta, fontSize: 18.sp, fontWeight: FontWeight.bold, color: ink),
                                  ),
                                ],
                              ),
                              content: Text(
                                'Doorstep delivery is automatically handled on every fabric and custom tailor order.\n\nWant to partner with us as a delivery rider?',
                                style: GoogleFonts.montserrat(fontSize: 13.sp, color: textLight, height: 1.5),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Close', style: GoogleFonts.montserrat(color: textLight, fontWeight: FontWeight.w600)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    const BecomeRider().launch(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text('Become a Rider', style: GoogleFonts.montserrat(color: white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              24.height,
              // Categories
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontFamily: 'Cinta',
                    fontSize: 20.sp,
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              14.height,
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 17.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: categoriesImages.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        // Navigate to catalogue with this category pre-filtered
                        final categoryMap = {
                          'Female\nAso-ebi': 'Lace Asoebi',
                          'Male\nAso-ebi':   'Lace Asoebi',
                          'Ankara':          'Ankara Styles',
                          'Ready to\nWear':  'Casual Wears',
                          'Materials':       'Bespoke Wears',
                          'Senator\nStyles': 'Senator & Kaftans',
                          'Lace\nStyles':    'Lace Asoebi',
                        };
                        final filter = categoryMap[categoriesText[index]] ?? categoriesText[index].replaceAll('\n', ' ');
                        CataloguePage(initialCategory: filter).launch(context);
                      },
                      child: Container(
                        width: 110.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: sand),
                          boxShadow: [
                            BoxShadow(
                              color: ink.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(categoriesImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                ink.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                categoriesText[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Cinta', 
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              24.height,
              // Featured Section Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Row(
                  children: [
                    Text(
                      'Featured',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 20.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Cinta',
                          fontSize: 12.sp,
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    4.width,
                    const Icon(Icons.arrow_forward_ios, color: primary, size: 10),
                  ],
                ),
              ),
              14.height,
              // Featured Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
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
                                    'No products available yet',
                                    style: TextStyle(fontFamily: 'Cinta', fontSize: 15.sp, color: textLight, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : MasonryGridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 8.w,
                            crossAxisSpacing: 8.w,
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                          double imageHeight = index.isEven ? 180.h : 220.h;
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
                                          final isAdded = SavedItemsService.instance.toggleFavorite(
                                            SavedItemModel(
                                              id: 'fav_${product.name}_${DateTime.now().millisecondsSinceEpoch}',
                                              name: product.name,
                                              price: product.price,
                                              storeName: product.vendorName ?? 'Vendor',
                                              imagePath: firstImage ?? femaleAsoebi,
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
                                       RatingBar.builder(
                                         initialRating: (product.rating != null && product.rating! > 0) ? product.rating!.toDouble() : 0.0,
                                         minRating: 0,
                                         direction: Axis.horizontal,
                                         allowHalfRating: true,
                                         itemCount: 5,
                                         itemSize: 12.sp,
                                         itemPadding: EdgeInsets.only(right: 2.w),
                                         itemBuilder: (context, _) => const Icon(
                                           Icons.star_rounded,
                                           color: Colors.amber,
                                         ),
                                         onRatingUpdate: (rating) {},
                                       ),
                                       if (product.rating == null || product.rating == 0.0) ...[
                                         4.width,
                                         Text(
                                           '(0)',
                                           style: GoogleFonts.montserrat(
                                             fontSize: 10.sp,
                                             fontWeight: FontWeight.w600,
                                             color: textLight,
                                           ),
                                         ),
                                       ],
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
              100.height, // Space for floating nav bar
                ],
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            left: 13.w,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _isScrolled ? cream.withValues(alpha: 0.9) : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: _isScrolled
                    ? [
                        BoxShadow(
                          color: ink.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: InkWell(
                onTap: _openDrawer,
                child: Image.asset(
                  menuIcon,
                  height: 24.h,
                  width: 24.w,
                  color: ink,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuickAccessItem(BuildContext context, String title, String asset, VoidCallback onTap, {bool disabled = false}) {
    return InkWell(
      onTap: disabled ? () => toast('Coming soon') : onTap,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: white,
          border: Border.all(color: disabled ? Colors.transparent : sand),
          boxShadow: [
            BoxShadow(
              color: ink.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              height: 40.h,
              width: 40.h,
              fit: BoxFit.contain,
              color: disabled ? Colors.grey : primary,
            ),
            12.height,
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 13.sp,
                color: disabled ? Colors.grey : ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
                style: GoogleFonts.montserrat(
                  fontSize: 24.sp,
                  color: primary,
                  fontWeight: FontWeight.w900,
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
