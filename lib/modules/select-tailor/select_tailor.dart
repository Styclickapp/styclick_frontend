import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/modules/select-tailor/tailor_details.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/core/services/vendor_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylclick/shared/utils/helpers.dart';

class SelectTailor extends StatefulWidget {
  const SelectTailor({Key? key}) : super(key: key);

  @override
  State<SelectTailor> createState() => _SelectTailorState();
}

class _SelectTailorState extends State<SelectTailor> {
  final List<String> images = [maleAsoebi, femaleAsoebi, femaleAsoebi];
  List<VendorProduct> _tailors = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTailors();
  }

  Future<void> _loadTailors() async {
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

        // Extract products that have a tailor vendor
        final tailorsOnly = loaded.where((p) {
          final type = p.vendorType?.toLowerCase();
          final name = p.vendorName?.toLowerCase() ?? '';
          return type == 'designer' || type == 'tailor' || name.contains('stitches') || name.contains('tailor');
        }).toList();

        // Get unique vendors by shop name
        final Map<String, VendorProduct> uniqueTailors = {};
        for (var t in tailorsOnly) {
          if (t.vendorName != null && !uniqueTailors.containsKey(t.vendorName)) {
            uniqueTailors[t.vendorName!] = t;
          }
        }

        if (mounted) {
          setState(() {
            _tailors = uniqueTailors.values.toList();
          });
        }
      }
    } catch (e) {
      log('[SELECT_TAILOR] Failed to load tailors: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: black,
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
                    'Select Tailor',
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
                        decoration: InputDecoration(
                          hintText: 'Search for a tailor around you',
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
                      : _tailors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.content_cut_outlined, size: 48.sp, color: textLight.withOpacity(0.5)),
                                  12.height,
                                  Text(
                                    'No tailors available yet',
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
                              itemCount: _tailors.length,
                              itemBuilder: (BuildContext context, int index) {
                                final tailor = _tailors[index];
                                final firstImage = tailor.imagePaths.isNotEmpty ? tailor.imagePaths.first : null;
                                return GestureDetector(
                                  onTap: () {
                                    TailorDetails(
                                      businessName: tailor.vendorName ?? tailor.name,
                                      vendorEmail: tailor.vendorEmail,
                                      vendorPhone: tailor.vendorPhone,
                                      vendorAddress: tailor.vendorAddress,
                                      vendorBio: tailor.vendorBio,
                                      vendorSpecialization: tailor.vendorSpecialization,
                                      vendorBanner: tailor.vendorBanner,
                                      vendorAvatar: tailor.vendorAvatar,
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
                                          tailor.vendorName ?? tailor.name,
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
                                                tailor.vendorAddress ?? 'Nigeria',
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
                                              (tailor.rating != null && tailor.rating! > 0) ? tailor.rating!.toStringAsFixed(1) : '5.0',
                                              style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ink),
                                            ),
                                          ],
                                        ),
                                        8.height,
                                        Text(
                                          'From NGN ${formatPriceNoDecimal(tailor.price)}',
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
