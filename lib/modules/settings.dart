import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/modules/edit_profile.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/modules/privacy_policy.dart';
import 'package:stylclick/modules/terms_of_service.dart';
import 'package:stylclick/modules/delete_account.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.height,
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => pop(context),
                      child: Icon(FeatherIcons.arrowLeft, color: ink, size: 24.sp),
                    ),
                    20.width,
                    Text(
                      'Settings',
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
              32.height,
              // Account Section
              _buildSectionHeader('ACCOUNT'),
              _buildSettingTile(
                icon: FeatherIcons.user,
                title: 'Personal Information',
                subtitle: 'Name, Email, Phone Number',
                onTap: () => const EditProfile().launch(context),
              ),
              _buildSettingTile(
                icon: FeatherIcons.lock,
                title: 'Password & Security',
                subtitle: 'Manage your security settings',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: FeatherIcons.bell,
                title: 'Notifications',
                subtitle: 'Control your alert preferences',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: FeatherIcons.users,
                title: 'Change Vendor Role',
                subtitle: 'Switch between Tailor, Fabrics Seller, or Rider',
                onTap: () => const VendorPage().launch(context),
              ),
              
              32.height,
              // Preferences Section
              _buildSectionHeader('PREFERENCES'),
              _buildToggleTile(
                icon: FeatherIcons.messageCircle,
                title: 'Push Notifications',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              _buildToggleTile(
                icon: FeatherIcons.mail,
                title: 'Email Updates',
                value: _emailUpdates,
                onChanged: (v) => setState(() => _emailUpdates = v),
              ),
              _buildSettingTile(
                icon: FeatherIcons.globe,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () {},
              ),

              32.height,
              // Legal Section
              _buildSectionHeader('LEGAL'),
              _buildSettingTile(
                icon: FeatherIcons.fileText,
                title: 'Privacy Policy',
                onTap: () => const PrivacyPolicyPage().launch(context),
              ),
              _buildSettingTile(
                icon: FeatherIcons.helpCircle,
                title: 'Terms of Service',
                onTap: () => const TermsOfServicePage().launch(context),
              ),

              32.height,
              // Danger Zone Section
              _buildSectionHeader('DANGER ZONE'),
              _buildDangerTile(
                icon: FeatherIcons.trash2,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account and data',
                onTap: () => const DeleteAccountPage().launch(context),
              ),
              
              40.height,
              // Logout
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: AppButton(
                  width: double.infinity,
                  text: 'Log Out',
                  textStyle: GoogleFonts.montserrat(color: white, fontWeight: FontWeight.w700),
                  color: primary,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('access_token');
                    await prefs.setBool('home', false);
                    setValue('access_token', '');
                    setValue('home', false);
                    if (context.mounted) const LoginScreen().launch(context, isNewTask: true);
                  },
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
              60.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(17.w, 0, 17.w, 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cinta',
          fontSize: 12.sp,
          color: textLight,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: sand),
          ),
          child: Row(
            children: [
              Icon(icon, color: primary, size: 20.sp),
              20.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontFamily: 'Cinta', 
                        fontSize: 15.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      4.height,
                      Text(
                        subtitle,
                        style: TextStyle(fontFamily: 'Cinta', 
                          fontSize: 12.sp,
                          color: textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(FeatherIcons.chevronRight, color: sand, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: sand),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 20.sp),
            20.width,
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontFamily: 'Cinta', 
                  fontSize: 15.sp,
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: primary,
              activeTrackColor: primary.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFFFD8D8)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFEF3F53), size: 20.sp),
              20.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 15.sp,
                        color: const Color(0xFFC53030),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    4.height,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: const Color(0xFFEF3F53).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(FeatherIcons.chevronRight, color: const Color(0xFFFFC5C5), size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }
}
