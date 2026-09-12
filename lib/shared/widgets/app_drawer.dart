import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/modules/edit_profile.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/help_support.dart';
import 'package:stylclick/modules/chat/chat_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/modules/order/order_summary.dart';
import 'package:stylclick/modules/admin/admin_dashboard.dart';

class AppDrawer extends StatefulWidget {
  final String? currentScreen;
  const AppDrawer({Key? key, this.currentScreen}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = '';
  String? _profilePicPath;
  bool _isVendor = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final prefFName = prefs.getString('fName') ?? prefs.getString('first_name') ?? getStringAsync('fName');
    final prefLName = prefs.getString('lName') ?? prefs.getString('last_name') ?? getStringAsync('lName');
    final prefName = prefs.getString('name') ?? prefs.getString('full_name') ?? getStringAsync('name');

    String full = '$prefFName $prefLName'.trim();
    if (full.isEmpty && prefName.isNotEmpty) {
      full = prefName;
    }

    final email = prefs.getString('email') ?? getStringAsync('email');
    if (full.isEmpty && email.isNotEmpty) {
      final emailPrefix = email.split('@').first;
      full = emailPrefix.replaceAll('.', ' ').replaceAll('_', ' ').capitalizeFirstLetter();
    }

    final pic = prefs.getString('profile_picture') ?? getStringAsync('profile_picture');

    setState(() {
      _userName = full.isNotEmpty ? full : 'User Profile';
      _isVendor = prefs.getBool('is_vendor') ?? getBoolAsync('is_vendor');
      if (pic.isNotEmpty) _profilePicPath = pic;
    });
  }

  bool _shouldShowItem(BuildContext context, String title) {
    final currentRoute = widget.currentScreen ?? ModalRoute.of(context)?.settings.name ?? '';
    final String routeStr = currentRoute.toLowerCase();

    // 1. Navigation bar tabs logic (Home = index 0, Catalogue = index 1, Profile/Account = index 2)
    final bool isNavContext = routeStr.isEmpty || routeStr == '/' || routeStr.contains('nav');

    if (title == 'Home' && isNavContext && currentIndex == 0) return false;
    if (title == 'Catalogue' && isNavContext && currentIndex == 1) return false;
    if ((title == 'Profile' || title == 'Account') && isNavContext && currentIndex == 2) return false;

    // 2. Specific sub-screen hiding rules
    if ((title == 'My Shop' || title == 'Become a Vendor') && (routeStr.contains('vendor') || routeStr.contains('shop'))) return false;
    if (title == 'Cart' && (routeStr.contains('ordersummary') || routeStr.contains('cart'))) return false;
    if (title == 'My Invoices' && routeStr.contains('transaction')) return false;
    if (title == 'My Orders' && routeStr.contains('savedorder')) return false;
    if (title == 'Saved Items' && routeStr.contains('saveditems')) return false;
    if (title == 'Wallet' && routeStr.contains('wallet')) return false;
    if (title == 'Share & Earn' && routeStr.contains('share')) return false;
    if (title == 'Settings' && routeStr.contains('settings')) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: cream),
        child: Column(
          children: [
            60.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primary.withOpacity(0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 35.r,
                      backgroundColor: white,
                      backgroundImage: (_profilePicPath != null && _profilePicPath!.isNotEmpty && File(_profilePicPath!).existsSync())
                          ? FileImage(File(_profilePicPath!)) as ImageProvider
                          : const AssetImage(defaultUserImage),
                    ),
                  ),
                  20.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cinta',
                            color: ink,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        4.height,
                        InkWell(
                          onTap: () {
                            if (ModalRoute.of(context)?.settings.name == '/EditProfile') {
                              Navigator.pop(context);
                            } else {
                              const EditProfile().launch(context);
                            }
                          },
                          child: Text(
                            'UPDATE PROFILE',
                            style: GoogleFonts.montserrat(
                              color: primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            30.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Divider(color: sand, thickness: 1),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 10.h, bottom: 120.h),
                children: [

                  // Section 1: Home, Catalogue, Profile/Account
                  // Section 1: Home
                  if (_shouldShowItem(context, 'Home'))
                    _buildDrawerItem(context, 'Home', () {
                      currentIndex = 0;
                      const Nav().launch(context, isNewTask: true);
                    }),

                  // Section 2: Main Ordered Items
                  if (_shouldShowItem(context, _isVendor ? 'My Shop' : 'Become a Vendor'))
                    _buildDrawerItem(
                      context,
                      _isVendor ? 'My Shop' : 'Become a Vendor',
                      () {
                        if (_isVendor) {
                          const VendorProfilePage().launch(context);
                        } else {
                          const VendorPage().launch(context);
                        }
                      },
                    ),
                  if (_shouldShowItem(context, 'Catalogue'))
                    _buildDrawerItem(context, 'Catalogue', () {
                      currentIndex = 1;
                      const Nav().launch(context, isNewTask: true);
                    }),
                  if (_shouldShowItem(context, 'Cart'))
                    _buildDrawerItem(context, 'Cart', () => const OrderSummary().launch(context)),
                  if (_shouldShowItem(context, 'Saved Items'))
                    _buildDrawerItem(context, 'Saved Items', () => const SavedItemsPage().launch(context)),
                  if (_shouldShowItem(context, 'My Orders'))
                    _buildDrawerItem(context, 'My Orders', () => const SavedOrderPage().launch(context)),
                  if (_shouldShowItem(context, 'My Invoices'))
                    _buildDrawerItem(context, 'My Invoices', () => const TransactionHistory().launch(context)),
                  if (_shouldShowItem(context, 'Wallet'))
                    _buildDrawerItem(context, 'Wallet', () => const WalletPage().launch(context)),
                  if (_shouldShowItem(context, 'Chat'))
                    _buildDrawerItem(context, 'Chat', () => const ChatListPage().launch(context)),
                  if (_shouldShowItem(context, _isVendor ? 'Profile' : 'Account'))
                    _buildDrawerItem(context, _isVendor ? 'Profile' : 'Account', () {
                      currentIndex = 2;
                      const Nav().launch(context, isNewTask: true);
                    }),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(color: sand, thickness: 1),
                  ),

                  // Section 3: Share & Earn
                  if (_shouldShowItem(context, 'Share & Earn')) ...[
                    _buildDrawerItem(context, 'Share & Earn', () => const ShareEarnPage().launch(context)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Divider(color: sand, thickness: 1),
                    ),
                  ],

                  // Section 4: Admin & Settings
                  _buildDrawerItem(context, 'Admin Console', () => const AdminDashboard().launch(context)),
                  if (_shouldShowItem(context, 'Settings'))
                    _buildDrawerItem(context, 'Settings', () => const SettingsPage().launch(context)),
                  _buildDrawerItem(context, 'Help & Support', () => const HelpSupportPage().launch(context)),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(color: sand, thickness: 1),
                  ),

                  // Section 5: Logout
                  _buildDrawerItem(context, 'Logout', () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted) const LoginScreen().launch(context, isNewTask: true);
                  }),
                  60.height,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 16.sp,
                color: ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centralized Notifications Drawer consistent with AppDrawer UI/UX
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
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(FeatherIcons.arrowLeft, color: ink, size: 22.sp),
                ),
                16.width,
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Cinta',
                    fontSize: 22.sp,
                    color: primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          20.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Divider(color: sand, thickness: 1),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 10.h, bottom: 120.h),
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
    padding: EdgeInsets.symmetric(vertical: 14.h),
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
