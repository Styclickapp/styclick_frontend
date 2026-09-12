import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/custom_bottom_sheet.dart';
import 'package:stylclick/modules/order/order_summary.dart';
import 'package:stylclick/modules/buy-fabrics/buy_fabrics_details.dart';
import 'package:stylclick/modules/select-tailor/tailor_details.dart';
import 'package:stylclick/modules/chat/chat_detail.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/core/services/vendor_service.dart';
import 'package:stylclick/core/services/cart_service.dart';
import 'package:stylclick/core/services/saved_items_service.dart';

class CategoryDetails extends StatefulWidget {
  final String? name;
  final double? price;
  final String? description;
  final List<String>? imagePaths;
  final String? category;
  final int? stock;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? storeName;
  final String? vendorId;
  final String? vendorType; // 'tailor' or 'seller'
  final String? vendorEmail;
  final String? vendorPhone;
  final String? vendorAddress;
  final String? vendorBio;
  final String? vendorSpecialization;
  final String? vendorBanner;
  final String? vendorAvatar;
  final double? rating;

  CategoryDetails({
    Key? key,
    this.name,
    this.price,
    this.description,
    this.imagePaths,
    this.category,
    this.stock,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
    this.storeName,
    this.vendorId,
    this.vendorType,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorAddress,
    this.vendorBio,
    this.vendorSpecialization,
    this.vendorBanner,
    this.vendorAvatar,
    this.rating,
  }) : super(key: key);

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  int _quantity = 1;
  String _selectedSize = '';

  List<VendorProduct> _similarProducts = [];
  bool _loadingSimilar = false;

  // ─── Context-aware option helpers ─────────────────────────────────────────
  String _getOptionLabel() {
    final cat = (widget.category ?? '').toLowerCase();
    if (cat.contains('fabric') || cat.contains('ankara') || cat.contains('lace') ||
        cat.contains('guinea') || cat.contains('aso') || cat.contains('damask') ||
        cat.contains('silk') || cat.contains('chiffon') || cat.contains('velvet')) {
      return 'Select Yards';
    } else if (cat.contains('tailor') || cat.contains('sew') || cat.contains('design') ||
        cat.contains('bespoke')) {
      return 'Select Sessions';
    } else if (cat.contains('repair') || cat.contains('fix') || cat.contains('alter') ||
        cat.contains('mend')) {
      return 'Select Items';
    } else {
      return 'Select Size';
    }
  }

  List<String> _getOptions() {
    final cat = (widget.category ?? '').toLowerCase();
    if (cat.contains('fabric') || cat.contains('ankara') || cat.contains('lace') ||
        cat.contains('guinea') || cat.contains('aso') || cat.contains('damask') ||
        cat.contains('silk') || cat.contains('chiffon') || cat.contains('velvet')) {
      return ['1 yd', '2 yds', '3 yds', '5 yds', '10 yds', 'Custom'];
    } else if (cat.contains('tailor') || cat.contains('sew') || cat.contains('design') ||
        cat.contains('bespoke')) {
      return ['1 Session', '2 Sessions', '3 Sessions', 'Package'];
    } else if (cat.contains('repair') || cat.contains('fix') || cat.contains('alter') ||
        cat.contains('mend')) {
      return ['1 Item', '2 Items', '3 Items', '5 Items'];
    } else {
      return ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Custom'];
    }
  }

  @override
  void initState() {
    super.initState();
    final opts = _getOptions();
    _selectedSize = opts.isNotEmpty ? opts[1] : opts.first;
    _loadSimilarProducts();
  }

  Future<void> _loadSimilarProducts() async {
    if (widget.isOwner) return;
    setState(() => _loadingSimilar = true);
    try {
      // Try cache first (already loaded by the home/catalogue feed — no extra network hit)
      dynamic cached = await VendorService.instance.getCachedProducts();
      List? list;
      if (cached is List) {
        list = cached;
      } else if (cached is Map && cached['data'] is List) {
        list = cached['data'] as List;
      }
      // Fallback to network only if no cache
      if (list == null) {
        final res = await VendorService.instance.getPublicProducts();
        if (res.data is List) {
          list = res.data as List;
        } else if (res.data is Map && (res.data as Map)['data'] is List) {
          list = (res.data as Map)['data'] as List;
        }
      }
      if (list != null) {
        final all = list
            .map((e) => VendorProduct.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        // Prefer same category, fallback to all others
        final sameCategory = all
            .where((p) => p.category == (widget.category ?? '') && p.name != (widget.name ?? ''))
            .take(8)
            .toList();
        final others = all
            .where((p) => p.name != (widget.name ?? ''))
            .take(8)
            .toList();
        if (mounted) {
          setState(() {
            _similarProducts = sameCategory.isNotEmpty ? sameCategory : others;
            _loadingSimilar = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingSimilar = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSimilar = false);
    }
  }

  void _navigateToVendorProfile() {
    final name = widget.storeName ?? 'Styclick Vendor';
    if (widget.vendorType == 'tailor' || widget.vendorType == 'designer' || name.toLowerCase().contains('tailor') || name.toLowerCase().contains('stitches')) {
      TailorDetails(
        businessName: name,
        vendorId: widget.vendorId,
        vendorEmail: widget.vendorEmail,
        vendorPhone: widget.vendorPhone,
        vendorAddress: widget.vendorAddress,
        vendorBio: widget.vendorBio,
        vendorSpecialization: widget.vendorSpecialization,
        vendorBanner: widget.vendorBanner,
        vendorAvatar: widget.vendorAvatar,
      ).launch(context);
    } else {
      FabricSellerDetails(
        businessName: name,
        vendorId: widget.vendorId,
        vendorEmail: widget.vendorEmail,
        vendorPhone: widget.vendorPhone,
        vendorAddress: widget.vendorAddress,
        vendorBio: widget.vendorBio,
        vendorSpecialization: widget.vendorSpecialization,
        vendorBanner: widget.vendorBanner,
        vendorAvatar: widget.vendorAvatar,
      ).launch(context);
    }
  }

  void _openChatWithVendor() {
    final name = widget.storeName ?? 'Styclick Vendor';
    ChatDetailPage(
      vendorName: name,
      vendorType: widget.vendorType ?? 'seller',
      productName: widget.name ?? 'Product Item',
      productPrice: widget.price != null ? 'NGN ${widget.price!.toStringAsFixed(0)}' : null,
      productImage: widget.imagePaths != null && widget.imagePaths!.isNotEmpty ? widget.imagePaths!.first : null,
      vendorAvatar: widget.vendorAvatar,
    ).launch(context);
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.name != null && SavedItemsService.instance.isFavorited(widget.name!);
    return Scaffold(
      backgroundColor: cream,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          elevation: 0,
          backgroundColor: cream,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                      border: Border.all(color: sand),
                    ),
                    child: Icon(FeatherIcons.arrowLeft, color: ink, size: 20.sp),
                  ),
                ),
                const Spacer(),
                if (widget.isOwner) ...[
                  IconButton(
                    icon: Icon(FeatherIcons.edit2, color: ink, size: 20.sp),
                    onPressed: widget.onEdit,
                  ),
                  IconButton(
                    icon: Icon(FeatherIcons.trash2, color: primary, size: 20.sp),
                    onPressed: widget.onDelete,
                  ),
                ] else ...[
                  InkWell(
                    onTap: () {
                      final firstImg = (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
                          ? widget.imagePaths!.first
                          : femaleAsoebi;
                      final isAdded = SavedItemsService.instance.toggleFavorite(
                        SavedItemModel(
                          id: 'fav_${widget.name}_${DateTime.now().millisecondsSinceEpoch}',
                          name: widget.name ?? 'Product Item',
                          price: widget.price ?? 0.0,
                          storeName: widget.storeName ?? 'Styclick Vendor',
                          imagePath: firstImg,
                          category: widget.category,
                          rating: (widget.rating != null && widget.rating! > 0) ? widget.rating!.toStringAsFixed(1) : '0.0 (0)',
                          vendorId: widget.vendorId,
                          vendorType: widget.vendorType,
                          vendorEmail: widget.vendorEmail,
                          vendorPhone: widget.vendorPhone,
                          vendorAddress: widget.vendorAddress,
                          vendorBio: widget.vendorBio,
                          vendorSpecialization: widget.vendorSpecialization,
                          vendorBanner: widget.vendorBanner,
                          vendorAvatar: widget.vendorAvatar,
                          description: widget.description,
                        ),
                      );
                      setState(() {});
                      toast(isAdded ? 'Added to Saved Items!' : 'Removed from Saved Items');
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                        border: Border.all(color: sand),
                      ),
                      child: Image.asset(
                        favoriteIcon,
                        height: 20.h,
                        width: 20.w,
                        color: isFav ? primary : ink.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  child: widget.imagePaths!.length == 1
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: _buildImage(widget.imagePaths!.first, width: double.infinity, height: 300.h),
                        )
                      : SizedBox(
                          height: 300.h,
                          child: PageView.builder(
                            itemCount: widget.imagePaths!.length,
                            controller: PageController(viewportFraction: 0.9),
                            itemBuilder: (context, idx) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: _buildImage(widget.imagePaths![idx], width: double.infinity, height: 300.h),
                              ),
                            ),
                          ),
                        ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  child: Container(
                    width: double.infinity,
                    height: 300.h,
                    decoration: BoxDecoration(
                      color: sand,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: sand),
                    ),
                    child: Center(
                      child: Icon(FeatherIcons.image, color: textLight, size: 48.sp),
                    ),
                  ),
                ),
              24.height,
              // Title and Price
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name ?? 'Female lace aso ebi',
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: ink,
                          fontFamily: cinta,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    16.width,
                    Text(
                      widget.price != null ? 'NGN ${widget.price!.toStringAsFixed(0)}' : 'NGN 50,000',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: cinta,
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              16.height,
              // Seller Info (Tapping opens vendor page)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: InkWell(
                  onTap: _navigateToVendorProfile,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: sand),
                    ),
                    child: Row(
                      children: [
                        Builder(builder: (_) {
                          final avatarUrl = widget.vendorAvatar;
                          final hasImage = avatarUrl != null && avatarUrl.isNotEmpty &&
                              (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));
                          return CircleAvatar(
                            radius: 20.r,
                            backgroundColor: primary.withOpacity(0.1),
                            backgroundImage: hasImage ? CachedNetworkImageProvider(avatarUrl ?? '') : null,
                            child: hasImage
                                ? null
                                : Text(
                                    (widget.storeName ?? 'S')[0].toUpperCase(),
                                    style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 16.sp),
                                  ),
                          );
                        }),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.storeName ?? 'Styclick Seller',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: cinta,
                                      fontWeight: FontWeight.w700,
                                      color: ink,
                                    ),
                                  ),
                                  4.width,
                                  Icon(Icons.arrow_forward_ios, size: 10.sp, color: textLight),
                                ],
                              ),
                              2.height,
                              Text(
                                'Verified Vendor • Tap to view profile',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontFamily: cinta,
                                  color: successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Icon(FeatherIcons.chevronRight, color: textLight, size: 20.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              24.height,
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: cinta,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    8.height,
                    Text(
                      (widget.description != null && widget.description!.isNotEmpty)
                          ? widget.description!
                          : 'No description provided by the seller.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: cinta,
                        height: 1.5,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
              ),
              24.height,
              // Details Table
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: cinta,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    12.height,
                    _buildDetailRow('Category', widget.category ?? 'Uncategorized'),
                    _buildDetailRow('Stock Available', '${widget.stock ?? 0} pieces'),
                  ],
                ),
              ),
              // ─── You Might Also Like ──────────────────────────────────────
              if (!widget.isOwner) ...[
                32.height,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  child: Text(
                    'You might also like',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: cinta,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                12.height,
                SizedBox(
                  height: 220.h,
                  child: _loadingSimilar
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 17.w),
                          itemCount: 4,
                          itemBuilder: (_, __) => Shimmer.fromColors(
                            baseColor: sand,
                            highlightColor: Colors.white,
                            child: Container(
                              width: 140.w,
                              margin: EdgeInsets.only(right: 12.w),
                              decoration: BoxDecoration(
                                color: sand,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                          ),
                        )
                      : _similarProducts.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 17.w),
                              itemCount: _similarProducts.length,
                              itemBuilder: (context, index) {
                                final p = _similarProducts[index];
                                final img = p.imagePaths.isNotEmpty ? p.imagePaths.first : null;
                                return GestureDetector(
                                  onTap: () => CategoryDetails(
                                    name: p.name,
                                    price: p.price,
                                    description: p.description,
                                    imagePaths: p.imagePaths,
                                    category: p.category,
                                    stock: p.stock,
                                    isOwner: false,
                                    storeName: p.vendorName,
                                    vendorId: p.vendorId,
                                    vendorType: p.vendorType,
                                    vendorEmail: p.vendorEmail,
                                    vendorPhone: p.vendorPhone,
                                    vendorAddress: p.vendorAddress,
                                    vendorBio: p.vendorBio,
                                    vendorSpecialization: p.vendorSpecialization,
                                    vendorBanner: p.vendorBanner,
                                    vendorAvatar: p.vendorAvatar,
                                    rating: p.rating,
                                  ).launch(context),
                                  child: Container(
                                    width: 140.w,
                                    margin: EdgeInsets.only(right: 12.w),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(color: sand),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ink.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                                          child: img == null
                                              ? Container(
                                                  height: 130.h,
                                                  color: sand,
                                                  child: Center(child: Icon(FeatherIcons.image, color: textLight)),
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: img,
                                                  height: 130.h,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  placeholder: (_, __) => Shimmer.fromColors(
                                                    baseColor: sand,
                                                    highlightColor: Colors.white,
                                                    child: Container(height: 130.h, color: sand),
                                                  ),
                                                  errorWidget: (_, __, ___) => Container(
                                                    height: 130.h,
                                                    color: sand,
                                                    child: Center(child: Icon(FeatherIcons.image, color: textLight)),
                                                  ),
                                                ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontFamily: cinta,
                                                  fontWeight: FontWeight.w600,
                                                  color: ink,
                                                ),
                                              ),
                                              4.height,
                                              Text(
                                                'NGN ${p.price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontFamily: cinta,
                                                  color: primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
              40.height,
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 32.h),
        decoration: BoxDecoration(
          color: white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chat Button
            InkWell(
              onTap: _openChatWithVendor,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 52.h,
                width: 52.h,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: const Icon(FeatherIcons.messageCircle, color: primary),
              ),
            ),
            12.width,
            // Add to Cart Button
            Expanded(
              child: InkWell(
                onTap: () {
                  addToCartSheet(context);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primaryGradient],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path, {double? width, double? height}) {
    final w = width ?? 280.w;
    final h = height ?? 280.h;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: w,
        height: h,
        fit: BoxFit.contain,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: sand,
          highlightColor: Colors.white,
          child: Container(width: w, height: h, color: sand),
        ),
        errorWidget: (_, __, ___) => Container(
          width: w,
          height: h,
          color: sand,
          child: Icon(FeatherIcons.image, color: textLight, size: 40.sp),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: w,
        height: h,
        fit: BoxFit.contain,
      );
    } else if (File(path).existsSync()) {
      return Image.file(
        File(path),
        width: w,
        height: h,
        fit: BoxFit.contain,
      );
    } else {
      return Container(
        width: w,
        height: h,
        color: sand,
        child: Icon(FeatherIcons.image, color: textLight, size: 40.sp),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: cinta,
              color: textLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: cinta,
              color: ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void addToCartSheet(BuildContext screenContext) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      context: screenContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, StateSetter setModalState) {
          final unitPrice = widget.price ?? 50000.0;
          final totalPrice = unitPrice * _quantity;

          return CustomBottomSheet(
            height: deviceHeight(context) * 0.52,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Options',
                    style: TextStyle(
                      fontFamily: cinta,
                      fontSize: 18.sp,
                      color: ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(FeatherIcons.x, size: 20.sp, color: textLight),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              16.height,
              // Context-aware option selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getOptionLabel(),
                    style: TextStyle(
                      fontFamily: cinta,
                      fontSize: 14.sp,
                      color: ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  10.height,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getOptions().map((option) {
                        final isSelected = option == _selectedSize;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedSize = option;
                            });
                            setState(() {
                              _selectedSize = option;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected ? primary : cream,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSelected ? primary : sand,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontFamily: cinta,
                                fontSize: 13.sp,
                                color: isSelected ? white : ink,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              20.height,
              // Quantity & Price Row
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 12.sp,
                          color: textLight,
                        ),
                      ),
                      4.height,
                      Text(
                        'NGN ${totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 18.sp,
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Decrement Button
                  GestureDetector(
                    onTap: () {
                      if (_quantity > 1) {
                        setModalState(() {
                          _quantity--;
                        });
                      }
                    },
                    child: Container(
                      height: 36.h,
                      width: 36.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: sand),
                        color: cream,
                      ),
                      child: const Center(
                        child: Icon(Icons.remove, color: ink),
                      ),
                    ),
                  ),
                  16.width,
                  Text(
                    '$_quantity',
                    style: TextStyle(
                      fontFamily: cinta,
                      fontSize: 18.sp,
                      color: ink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  16.width,
                  // Increment Button
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _quantity++;
                      });
                    },
                    child: Container(
                      height: 36.h,
                      width: 36.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: sand),
                        color: cream,
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: ink),
                      ),
                    ),
                  ),
                ],
              ),
              30.height,
              InkWell(
                onTap: () {
                  CartService.instance.addToCart(
                    CartItemModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: widget.name ?? 'Product Item',
                      storeName: widget.storeName ?? 'Styclick Vendor',
                      price: widget.price ?? 50000.0,
                      size: _selectedSize.isNotEmpty ? _selectedSize : 'Standard',
                      quantity: _quantity,
                      image: (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
                          ? widget.imagePaths!.first
                          : femaleAsoebi,
                      isSelected: true,
                      vendorType: widget.vendorType ?? 'seller',
                      vendorId: widget.vendorId,
                      vendorEmail: widget.vendorEmail,
                      vendorPhone: widget.vendorPhone,
                      vendorAddress: widget.vendorAddress,
                      vendorBio: widget.vendorBio,
                      vendorSpecialization: widget.vendorSpecialization,
                      vendorBanner: widget.vendorBanner,
                      vendorAvatar: widget.vendorAvatar,
                      category: widget.category,
                      description: widget.description,
                    ),
                  );
                  Navigator.pop(sheetCtx);
                  addedToCartSheet(screenContext);
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                  child: Container(
                    height: 52.h,
                    width: logicalWidth(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primaryGradient],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _selectedSize.isNotEmpty
                            ? 'Add to Cart — $_selectedSize, Qty: $_quantity'
                            : 'Add to Cart — Qty: $_quantity',
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 14.sp,
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Chat with vendor button
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _openChatWithVendor();
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 48.h,
                  width: logicalWidth(),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FeatherIcons.messageCircle, color: primary, size: 18.sp),
                      8.width,
                      Text(
                        'Chat with Vendor',
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 14.sp,
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void addedToCartSheet(BuildContext screenContext) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      context: screenContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, StateSetter setState) {
          return CustomBottomSheet(
            height: deviceHeight(context) * 0.45,
            children: [
              24.height,
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(FeatherIcons.check, color: successColor, size: 32.sp),
              ),
              16.height,
              Text(
                'Successfully Added!',
                style: TextStyle(
                  fontFamily: cinta,
                  fontSize: 20.sp,
                  color: ink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.height,
              Text(
                _selectedSize.isNotEmpty
                    ? '$_quantity x $_selectedSize added to cart.'
                    : '$_quantity item(s) added to cart.',
                style: TextStyle(
                  fontFamily: cinta,
                  fontSize: 14.sp,
                  color: textLight,
                ),
                textAlign: TextAlign.center,
              ),
              30.height,
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  const OrderSummary().launch(screenContext);
                },
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primary, width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'View Cart & Checkout',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              12.height,
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: cream,
                    border: Border.all(color: sand, width: 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              24.height,
            ],
          );
        },
      ),
    );
  }
}
