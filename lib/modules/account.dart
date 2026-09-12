import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylclick/modules/edit_profile.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/core/services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylclick/modules/help_support.dart';
import 'package:stylclick/modules/chat/chat_list.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isVendor = false;
  String _vendorType = '';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userState = '';
  String _userAddress = '';
  String? _profilePicPath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_picture', image.path);
        setValue('profile_picture', image.path);
        setState(() {
          _profilePicPath = image.path;
        });
        toast('Profile picture updated successfully!');
      }
    } catch (e) {
      log('[ACCOUNT] Error picking image: $e');
    }
  }

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String fName = prefs.getString('fName') ?? prefs.getString('first_name') ?? getStringAsync('fName');
    String lName = prefs.getString('lName') ?? prefs.getString('last_name') ?? getStringAsync('lName');
    String name = prefs.getString('name') ?? prefs.getString('full_name') ?? getStringAsync('name');
    String email = prefs.getString('email') ?? getStringAsync('email');
    String phone = prefs.getString('phone') ?? prefs.getString('phone_number') ?? getStringAsync('phone');
    String state = prefs.getString('state') ?? getStringAsync('state');
    String address = prefs.getString('address') ?? getStringAsync('address');
    String pic = prefs.getString('profile_picture') ?? getStringAsync('profile_picture');

    String full = '$fName $lName'.trim();
    if (full.isEmpty && name.isNotEmpty) full = name;

    setState(() {
      if (pic.isNotEmpty) _profilePicPath = pic;
      _isVendor = prefs.getBool('is_vendor') ?? getBoolAsync('is_vendor');
      _vendorType = prefs.getString('vendor_type') ?? getStringAsync('vendor_type');
      _userName = full.isNotEmpty ? full : 'User Profile';
      _userEmail = email.isNotEmpty ? email : 'Not provided';
      _userPhone = phone.isNotEmpty ? phone : 'Not provided';
      _userState = state.isNotEmpty ? state : 'Not provided';
      _userAddress = address.isNotEmpty ? address : 'Not provided';
    });

    // Fetch real user account from API to guarantee user owns the house
    try {
      final res = await ProfileService.instance.fetchProfile();
      if (res.status == true && res.data != null) {
        final pData = res.data!['data'] ?? res.data!['user'] ?? res.data!;
        if (pData is Map) {
          final apiFn = pData['first_name'] ?? pData['firstname'] ?? pData['fName'] ?? '';
          final apiLn = pData['last_name'] ?? pData['lastname'] ?? pData['lName'] ?? '';
          final apiEm = pData['email'] ?? '';
          final apiPh = pData['phone'] ?? pData['phone_number'] ?? '';
          final apiAddr = pData['address'] ?? pData['state'] ?? '';

          String apiFull = '$apiFn $apiLn'.trim();
          if (apiFull.isEmpty && pData['name'] != null) apiFull = pData['name'].toString();

          if (apiFull.isNotEmpty) {
            full = apiFull;
            await prefs.setString('fName', apiFn.toString());
            await prefs.setString('lName', apiLn.toString());
            setValue('fName', apiFn.toString());
            setValue('lName', apiLn.toString());
          }
          if (apiEm.toString().isNotEmpty) {
            email = apiEm.toString();
            await prefs.setString('email', email);
            setValue('email', email);
          }
          if (apiPh.toString().isNotEmpty) {
            phone = apiPh.toString();
            await prefs.setString('phone', phone);
            setValue('phone', phone);
          }
          if (apiAddr.toString().isNotEmpty) {
            address = apiAddr.toString();
            await prefs.setString('address', address);
            setValue('address', address);
          }

          final String userType = pData['type']?.toString() ?? '';
          final bool isV = userType == 'vendor' || pData['is_vendor'] == true || pData['is_vendor'] == 1 || pData['is_vendor'] == '1';
          await prefs.setBool('is_vendor', isV);
          setValue('is_vendor', isV);

          String? vType;
          if (pData['vendor_type'] != null) {
            vType = pData['vendor_type'].toString();
            await prefs.setString('vendor_type', vType);
            setValue('vendor_type', vType);
          }

          if (pData['vendor_status'] != null) {
            final String vStatus = pData['vendor_status'].toString();
            await prefs.setString('vendor_status', vStatus);
            setValue('vendor_status', vStatus);
          }

          if (mounted) {
            setState(() {
              _isVendor = isV;
              if (vType != null) {
                _vendorType = vType;
              }
              _userName = full.isNotEmpty ? full : _userName;
              _userEmail = email.isNotEmpty ? email : _userEmail;
              _userPhone = phone.isNotEmpty ? phone : _userPhone;
              _userAddress = address.isNotEmpty ? address : _userAddress;
            });
          }
        }
      }
    } catch (e) {
      log('[ACCOUNT] Non-critical profile load log: $e');
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  String _vendorTypeLabel() {
    switch (_vendorType) {
      case 'tailor':
      case 'designer':
        return 'Tailor Profile';
      case 'seller': return 'Fabric Seller Profile';
      case 'rider':  return 'Rider Profile';
      default:       return 'Vendor Profile';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: buildNotificationDrawer(context),
      backgroundColor: cream, // Pure white
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                    color: cream,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                        ),
                        const Spacer(),
                        Text(
                          _isVendor ? _vendorTypeLabel() : 'Account',
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
              8.height,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Profile Row (User Information)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                height: 76.h,
                                width: 76.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: sand, width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(38.r),
                                  child: (_profilePicPath != null && _profilePicPath!.isNotEmpty && File(_profilePicPath!).existsSync())
                                      ? Image.file(
                                          File(_profilePicPath!),
                                          height: 76.h,
                                          width: 76.w,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          defaultUserImage,
                                          height: 76.h,
                                          width: 76.w,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cream, width: 2),
                                  ),
                                  child: Icon(FeatherIcons.camera, color: white, size: 12.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: TextStyle(
                                  fontFamily: 'Cinta',
                                  color: ink,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              6.height,
                              InkWell(
                                onTap: () => const EditProfile().launch(context),
                                child: Text(
                                  'Edit Profile & Settings',
                                  style: GoogleFonts.montserrat(
                                    color: primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isVendor) ...[
                      8.height,
                      // Star Rating Container (Only visible for Vendors)
                      Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(color: sand),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14.sp,
                            ),
                            4.width,
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: cinta,
                                color: ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    24.height,
                    // Quick Action Cards Row (Wallet & Chat)
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            'Wallet',
                            wallet,
                            () => const WalletPage().launch(context),
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: _buildQuickActionCard(
                            'Chat',
                            chats,
                            () => const ChatListPage().launch(context),
                          ),
                        ),
                      ],
                    ),
                    24.height,
                    // User Information Card (Signup Details Visible)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: sand),
                        boxShadow: [
                          BoxShadow(
                            color: ink.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'USER INFORMATION',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textLight,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              InkWell(
                                onTap: () => const EditProfile().launch(context),
                                child: Text(
                                  'Edit',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          14.height,
                          _buildInfoRow(FeatherIcons.user, 'Full Name', _userName),
                          10.height,
                          Divider(color: sand.withOpacity(0.6), thickness: 0.8),
                          10.height,
                          _buildInfoRow(FeatherIcons.mail, 'Email Address', _userEmail),
                          10.height,
                          Divider(color: sand.withOpacity(0.6), thickness: 0.8),
                          10.height,
                          _buildInfoRow(FeatherIcons.phone, 'Phone Number', _userPhone),
                          10.height,
                          Divider(color: sand.withOpacity(0.6), thickness: 0.8),
                          10.height,
                          _buildInfoRow(FeatherIcons.globe, 'State', _userState),
                          10.height,
                          Divider(color: sand.withOpacity(0.6), thickness: 0.8),
                          10.height,
                          _buildInfoRow(FeatherIcons.mapPin, 'Address', _userAddress),
                          10.height,
                          Divider(color: sand.withOpacity(0.6), thickness: 0.8),
                          10.height,
                          InkWell(
                            onTap: () => const SettingsPage().launch(context),
                            child: Row(
                              children: [
                                Icon(FeatherIcons.settings, size: 18.sp, color: primary),
                                12.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Settings',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.sp,
                                        color: textLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    2.height,
                                    Text(
                                      'App Preferences & Security',
                                      style: TextStyle(
                                        fontFamily: 'Cinta',
                                        fontSize: 13.sp,
                                        color: ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(FeatherIcons.chevronRight, size: 16.sp, color: textLight),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.height,
                    // Help & Support Card (Below User Information Card)
                    InkWell(
                      onTap: () {
                        const HelpSupportPage().launch(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: sand),
                          boxShadow: [
                            BoxShadow(
                              color: ink.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(helpIcon, height: 22.h, width: 22.w, color: primary),
                            ),
                            14.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Help & Support',
                                    style: TextStyle(
                                      fontFamily: 'Cinta',
                                      fontSize: 14.sp,
                                      color: ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  2.height,
                                  Text(
                                    'Need help or have questions? Contact support',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.sp,
                                      color: textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(FeatherIcons.chevronRight, size: 18.sp, color: textLight),
                          ],
                        ),
                      ),
                    ),
                    120.height,
                  ],
                ),
              ),
            ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: primary),
        12.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10.sp,
                color: textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            2.height,
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 13.sp,
                color: ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, String iconAsset, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: sand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconAsset,
              height: 32.h,
              width: 32.w,
              color: primary,
            ),
            12.height,
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: ink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String iconAsset, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(
              iconAsset,
              height: 24.h,
              width: 24.w,
              color: ink,
            ),
            16.width,
            Text(
              title,
              style: TextStyle(
                fontFamily: cinta,
                fontSize: 16.sp,
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: sand, size: 14.sp),
          ],
        ),
      ),
    );
  }
}
