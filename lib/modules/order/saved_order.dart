import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/details.dart';

class SavedOrderPage extends StatefulWidget {
  const SavedOrderPage({Key? key}) : super(key: key);

  @override
  State<SavedOrderPage> createState() => _SavedOrderPageState();
}

class _SavedOrderPageState extends State<SavedOrderPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _allOrders = [];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_searchQuery.isEmpty) return _allOrders;
    return _allOrders.where((order) {
      return order['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['id'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Order History',
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
                          hintText: 'Search by ID or product...',
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
            // List Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Text(
                'YOUR TRANSACTIONS',
                style: TextStyle(
                  fontFamily: 'Cinta',
                  fontSize: 12.sp,
                  color: textLight,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            16.height,
            // History List
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FeatherIcons.package, size: 48.sp, color: sand),
                          16.height,
                          Text('No orders found', style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: textLight)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryTile(_filteredOrders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> order) {
    Color statusColor;
    IconData statusIcon;

    switch (order['status']) {
      case 'Delivered':
        statusColor = successColor;
        statusIcon = FeatherIcons.checkCircle;
        break;
      case 'Processing':
        statusColor = primary;
        statusIcon = FeatherIcons.clock;
        break;
      case 'Cancelled':
        statusColor = textLight;
        statusIcon = FeatherIcons.xCircle;
        break;
      default:
        statusColor = primary;
        statusIcon = FeatherIcons.package;
    }

    return InkWell(
      onTap: () {
        CategoryDetails(
          name: order['title'],
          storeName: 'Styclick Vendor',
          imagePaths: [order['image']],
        ).launch(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: sand),
          boxShadow: [
            BoxShadow(
              color: ink.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Order Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              order['image'],
              height: 84.h,
              width: 84.w,
              fit: BoxFit.cover,
            ),
          ),
          12.width,
          // Order Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        order['id'],
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    4.width,
                    Text(
                      order['date'],
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        color: textLight.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                4.height,
                Text(
                  order['title'],
                  style: TextStyle(
                    fontFamily: 'Cinta', 
                    fontSize: 14.sp,
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.height,
                Text(
                  order['items'],
                  style: TextStyle(
                    fontFamily: 'Cinta', 
                    fontSize: 11.sp,
                    color: textLight,
                  ),
                ),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        order['price'],
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          color: primary,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    4.width,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 10.sp),
                          4.width,
                          Text(
                            order['status'],
                            style: GoogleFonts.montserrat(
                              color: statusColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
