import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/modules/vendor/become_rider.dart';
import 'package:stylclick/modules/vendor/become_vendor.dart';
import 'package:stylclick/modules/vendor/become_seller.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/widgets/notification_drawer.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/shared/constants/strings.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({Key? key}) : super(key: key);

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: SingleChildScrollView(
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
                      'Become a Vendor',
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
              16.height,
              // Welcome Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.height,
                    Text(
                      'Join our curated ecosystem of creators, suppliers, and logistics experts. Select your path below.',
                      style: TextStyle(fontFamily: 'Cinta', 
                        fontSize: 15.sp,
                        color: textLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              40.height,
              // Options
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  children: [
                    _buildPartnerCard(
                      title: 'Tailor',
                      desc: 'Create & sell custom garments, fabrics, or ready-made clothes.',
                      iconAsset: sewingMachine,
                      onTap: () => const BecomeVendor().launch(context),
                    ),
                    20.height,
                    _buildPartnerCard(
                      title: 'Fabrics Seller',
                      desc: 'Sell premium fabrics and raw materials only.',
                      iconAsset: fabric,
                      onTap: () => const BecomeSeller().launch(context),
                    ),
                    20.height,
                    _buildPartnerCard(
                      title: 'Dispatch Rider',
                      desc: 'Deliver orders and perform dispatches only.',
                      iconAsset: dispatchRider,
                      onTap: () => const BecomeRider().launch(context),
                      disabled: true,
                    ),
                    40.height,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCard({
    required String title,
    required String desc,
    required String iconAsset,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? () => toast('Coming soon') : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: disabled ? Colors.transparent : sand),
          boxShadow: [
            BoxShadow(
              color: ink.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            16.width,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: (disabled ? Colors.grey : primary).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Image.asset(
                iconAsset,
                height: 40.h,
                width: 40.w,
                color: disabled ? Colors.grey : primary,
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 18.sp,
                      color: disabled ? Colors.grey : ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  4.height,
                  Text(
                    desc,
                    style: TextStyle(
                      fontFamily: cinta,
                      fontSize: 12.sp,
                      color: disabled ? Colors.grey.shade400 : textLight,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            16.width,
            Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: (disabled ? Colors.grey : primary).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(FeatherIcons.arrowRight, color: disabled ? Colors.grey : primary, size: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationDrawer(BuildContext context) {
    return const NotificationDrawer();
  }
}
