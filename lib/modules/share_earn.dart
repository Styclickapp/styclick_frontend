import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';

class ShareEarnPage extends StatefulWidget {
  const ShareEarnPage({Key? key}) : super(key: key);

  @override
  State<ShareEarnPage> createState() => _ShareEarnPageState();
}

class _ShareEarnPageState extends State<ShareEarnPage> {
  final String _referralCode = 'STY-WAL-99X';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onTap: () => pop(context),
                      child: Icon(FeatherIcons.arrowLeft, color: ink, size: 24.sp),
                    ),
                    20.width,
                    Text(
                      'Share & Earn',
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
              // Hero Illustration/Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(24.r),
                    image: const DecorationImage(
                      image: AssetImage(walletBg),
                      fit: BoxFit.cover,
                      opacity: 0.15,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Earn NGN 1,000',
                        style: TextStyle(fontFamily: 'Cinta', 
                          fontSize: 28.sp,
                          color: white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      8.height,
                      Text(
                        'For every friend who registers and makes their first purchase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Cinta', 
                          fontSize: 14.sp,
                          color: white.withOpacity(0.7),
                        ),
                      ),
                      32.height,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _referralCode,
                              style: GoogleFonts.montserrat(
                                fontSize: 20.sp,
                                color: white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            20.width,
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _referralCode));
                                showMessage(context, 'Referral code copied!');
                              },
                              child: Icon(FeatherIcons.copy, color: primary, size: 20.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              40.height,
              // Earnings Summary
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Row(
                  children: [
                    _buildEarningStat('PENDING', 'NGN 2,500'),
                    16.width,
                    _buildEarningStat('TOTAL EARNED', 'NGN 15,000'),
                  ],
                ),
              ),
              40.height,
              // How it works
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOW IT WORKS',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    24.height,
                    _buildStep(1, 'Share your code', 'Send your unique referral code to your friends.'),
                    _buildStep(2, 'Friend registers', 'They use your code during signup on Styclick.'),
                    _buildStep(3, 'Get rewarded', 'Receive NGN 1,000 in your wallet after their first order.'),
                  ],
                ),
              ),
              40.height,
              // Social Sharing
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUICK SHARE',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSocialBtn('WhatsApp', FeatherIcons.messageCircle, Colors.green),
                        _buildSocialBtn('Instagram', FeatherIcons.instagram, Colors.purple),
                        _buildSocialBtn('Twitter', FeatherIcons.twitter, Colors.blue),
                        _buildSocialBtn('Others', FeatherIcons.share2, ink),
                      ],
                    ),
                  ],
                ),
              ),
              60.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: sand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight, fontWeight: FontWeight.w700),
            ),
            8.height,
            Text(
              value,
              style: GoogleFonts.montserrat(fontSize: 16.sp, color: ink, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: GoogleFonts.montserrat(color: primary, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          20.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: ink, fontWeight: FontWeight.w700),
                ),
                4.height,
                Text(
                  desc,
                  style: TextStyle(fontFamily: 'Cinta', fontSize: 13.sp, color: textLight, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: white,
            shape: BoxShape.circle,
            border: Border.all(color: sand),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        8.height,
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
