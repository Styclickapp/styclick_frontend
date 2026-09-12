import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/details.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylclick/core/services/saved_items_service.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({Key? key}) : super(key: key);

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    SavedItemsService.instance.itemsNotifier.addListener(_onSavedItemsChanged);
  }

  @override
  void dispose() {
    SavedItemsService.instance.itemsNotifier.removeListener(_onSavedItemsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSavedItemsChanged() {
    if (mounted) setState(() {});
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = SavedItemsService.instance.items;
    final savedItems = _searchQuery.isEmpty
        ? allItems
        : allItems.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            i.storeName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: buildNotificationDrawer(context),
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
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        finish(context);
                      }
                    },
                    child: Icon(
                      FeatherIcons.arrowLeft,
                      color: ink,
                      size: 24.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Saved Items',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 18.sp,
                      color: ink,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
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
            32.height,
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: sand),
                ),
                child: Row(
                  children: [
                    Icon(FeatherIcons.search, color: sand, size: 20.sp),
                    12.width,
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                        decoration: InputDecoration(
                          hintText: 'Search your favorites...',
                          hintStyle: TextStyle(fontFamily: 'Cinta', color: ink.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            24.height,
            // Grid
            Expanded(
              child: savedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FeatherIcons.heart, size: 48.sp, color: textLight.withOpacity(0.4)),
                          16.height,
                          Text(
                            _searchQuery.isNotEmpty ? 'No items match "$_searchQuery"' : 'No Saved Items Yet',
                            style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: ink, fontWeight: FontWeight.bold),
                          ),
                          8.height,
                          Text(
                            'Items you save will appear here.',
                            style: TextStyle(fontFamily: 'Cinta', fontSize: 13.sp, color: textLight),
                          ),
                        ],
                      ),
                    )
                  : MasonryGridView.count(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.w,
                      crossAxisSpacing: 8.w,
                      itemCount: savedItems.length,
                      itemBuilder: (context, index) {
                        final item = savedItems[index];
                        double imageHeight = index.isEven ? 200.h : 260.h;
                        final img = item.imagePath;

                        return InkWell(
                          onTap: () {
                            CategoryDetails(
                              name: item.name,
                              price: item.price,
                              storeName: item.storeName,
                              imagePaths: [img],
                              category: item.category,
                              vendorType: item.vendorType,
                              vendorId: item.vendorId,
                              vendorEmail: item.vendorEmail,
                              vendorPhone: item.vendorPhone,
                              vendorAddress: item.vendorAddress,
                              vendorBio: item.vendorBio,
                              vendorSpecialization: item.vendorSpecialization,
                              vendorBanner: item.vendorBanner,
                              vendorAvatar: item.vendorAvatar,
                              description: item.description,
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: img.startsWith('http://') || img.startsWith('https://')
                                      ? CachedNetworkImage(
                                          imageUrl: img,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: imageHeight,
                                          placeholder: (_, __) => Container(height: imageHeight, color: sand),
                                          errorWidget: (_, __, ___) => Image.asset(catFemaleAsoEbi, fit: BoxFit.cover, height: imageHeight),
                                        )
                                      : (img.startsWith('assets/')
                                          ? Image.asset(img, fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                          : (File(img).existsSync()
                                              ? Image.file(File(img), fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                              : Image.asset(catFemaleAsoEbi, fit: BoxFit.cover, width: double.infinity, height: imageHeight))),
                                ),
                                12.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
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
                                        SavedItemsService.instance.removeSavedItem(item.id);
                                        toast('Removed from Saved Items');
                                      },
                                      child: Image.asset(
                                        favoriteIcon,
                                        height: 18.h,
                                        width: 18.w,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                                6.height,
                                 Row(
                                   children: [
                                     Icon(
                                       Icons.star_rounded,
                                       color: (item.rating != null && item.rating != '0.0 (0)' && item.rating != '0' && item.rating != '0.0') ? Colors.amber : textLight.withOpacity(0.3),
                                       size: 14.sp,
                                     ),
                                     2.width,
                                     Text(
                                       (item.rating != null && item.rating != '0.0 (0)' && item.rating != '0' && item.rating != '0.0')
                                           ? item.rating!
                                           : '0.0 (0)',
                                       style: GoogleFonts.montserrat(
                                         fontSize: 11.sp,
                                         fontWeight: FontWeight.w700,
                                         color: (item.rating != null && item.rating != '0.0 (0)' && item.rating != '0' && item.rating != '0.0') ? ink : textLight,
                                       ),
                                     ),
                                   ],
                                 ),
                                8.height,
                                Text(
                                  'NGN ${item.price.toStringAsFixed(0)}',
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
                  _buildNotificationItem('Order Confirmed', 'Your Aso-ebi order #4290 has been received.', '2m ago', FeatherIcons.checkCircle),
                  _buildNotificationItem('Promotion', 'Get 20% off on all Ankara materials this weekend!', '1h ago', FeatherIcons.tag),
                  _buildNotificationItem('Update', 'Your measurements have been successfully updated.', '5h ago', FeatherIcons.user),
                  _buildNotificationItem('Payment Successful', 'Wallet top-up of NGN 50,000 successful.', 'Yesterday', FeatherIcons.creditCard),
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
                        style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.width,
                    Text(time, style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight)),
                  ],
                ),
                4.height,
                Text(sub, style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
