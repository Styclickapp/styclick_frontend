import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylclick/modules/buy-fabrics/buy_fabrics_details.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/core/services/vendor_service.dart';

class BuyFabrics extends StatefulWidget {
  const BuyFabrics({Key? key}) : super(key: key);

  @override
  State<BuyFabrics> createState() => _BuyFabricsState();
}

class _BuyFabricsState extends State<BuyFabrics> {
  List<VendorProduct> _sellers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFabrics();
  }

  Future<void> _loadFabrics() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final res = await VendorService.instance.getPublicProducts();
      List? list;
      if (res.data is List) {
        list = res.data as List;
      } else if (res.data is Map && (res.data as Map)['data'] is List) {
        list = (res.data as Map)['data'] as List;
      }
      if (list != null) {
        final loaded = list.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return VendorProduct.fromJson(m);
        }).toList();

        // Filter for fabric sellers and fabric-related listings
        final sellersOnly = loaded.where((p) {
          final type = p.vendorType?.toLowerCase() ?? '';
          final cat = p.category.toLowerCase();
          final name = p.name.toLowerCase();
          final vName = p.vendorName?.toLowerCase() ?? '';
          return type == 'seller' ||
              type == 'fabric-seller' ||
              cat.contains('fabric') ||
              cat.contains('material') ||
              cat.contains('lace') ||
              cat.contains('ankara') ||
              vName.contains('fabric') ||
              name.contains('fabric');
        }).toList();

        final Map<String, VendorProduct> uniqueSellers = {};
        for (var s in sellersOnly) {
          final key = s.vendorName ?? s.name;
          if (!uniqueSellers.containsKey(key)) {
            uniqueSellers[key] = s;
          }
        }

        if (mounted) {
          setState(() {
            _sellers = uniqueSellers.values.toList();
          });
        }
      }
    } catch (e) {
      log('[BUY_FABRICS] Failed to load fabric sellers: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<VendorProduct> get _filteredSellers {
    if (_searchQuery.isEmpty) return _sellers;
    return _sellers.where((s) {
      final name = (s.vendorName ?? s.name).toLowerCase();
      final cat = s.category.toLowerCase();
      final loc = (s.vendorAddress ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || cat.contains(q) || loc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
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
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      backIcon,
                      color: ink,
                      width: 24.w,
                    ),
                  ),
                  20.width,
                  Text(
                    'Buy Fabrics',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 18.sp,
                      color: ink,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            24.height,
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
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for a fabrics seller',
                          hintStyle: TextStyle(
                            fontFamily: 'Cinta',
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
            16.height,
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 17.0.w, right: 17.w),
                child: SizedBox(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: primary))
                      : _filteredSellers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.storefront_outlined, size: 48.sp, color: textLight.withOpacity(0.5)),
                                  12.height,
                                  Text(
                                    'No fabric sellers available yet',
                                    style: TextStyle(
                                      fontFamily: 'Cinta',
                                      fontSize: 15.sp,
                                      color: textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 16,
                                childAspectRatio: 9 / 16,
                              ),
                              itemCount: _filteredSellers.length,
                              itemBuilder: (BuildContext context, int index) {
                                final seller = _filteredSellers[index];
                                final firstImage = seller.imagePaths.isNotEmpty ? seller.imagePaths.first : null;
                                return GestureDetector(
                                  onTap: () {
                                    FabricSellerDetails(
                                      businessName: seller.vendorName ?? seller.name,
                                      vendorEmail: seller.vendorEmail,
                                      vendorPhone: seller.vendorPhone,
                                      vendorAddress: seller.vendorAddress,
                                      vendorBio: seller.vendorBio,
                                      vendorSpecialization: seller.vendorSpecialization,
                                      vendorBanner: seller.vendorBanner,
                                      vendorAvatar: seller.vendorAvatar,
                                    ).launch(context);
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
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12.r),
                                            child: firstImage == null
                                                ? Container(color: sand.withOpacity(0.3), child: const Center(child: Icon(Icons.store, color: textLight)))
                                                : (firstImage.startsWith('http')
                                                    ? CachedNetworkImage(
                                                        imageUrl: firstImage,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: primary)),
                                                        errorWidget: (_, __, ___) => Container(color: sand.withOpacity(0.3), child: const Center(child: Icon(Icons.store, color: textLight))),
                                                      )
                                                    : Image.asset(firstImage, fit: BoxFit.cover, width: double.infinity)),
                                          ),
                                        ),
                                        12.height,
                                        Text(
                                          seller.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Cinta',
                                            fontSize: 14.sp,
                                            color: ink,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        4.height,
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, color: locationIconColor, size: 12.sp),
                                            2.width,
                                            Expanded(
                                              child: Text(
                                                seller.vendorAddress ?? 'Nigeria',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Cinta',
                                                  fontSize: 11.sp,
                                                  color: textLight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        6.height,
                                        Row(
                                          children: [
                                            Icon(Icons.star_rounded, color: Colors.amber, size: 12.sp),
                                            2.width,
                                            Text(
                                              (seller.rating != null && seller.rating! > 0) ? seller.rating!.toStringAsFixed(1) : '5.0',
                                              style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ink),
                                            ),
                                          ],
                                        ),
                                        8.height,
                                        Text(
                                          'NGN ${formatPrice(seller.price)}',
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
            ),
          ],
        ),
      ),
    );
  }
}
