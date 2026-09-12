import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/modules/account.dart';
import 'package:stylclick/modules/catalogue/catalogue.dart';
import 'package:stylclick/modules/home.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/utils/helpers.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

int currentIndex = 0;
List<Widget> children = [];

final tabs = [const HomePage(), const CataloguePage(), const AccountPage()];

class _NavState extends State<Nav> {
  bool _isVendor = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isVendor = prefs.getBool('is_vendor') ?? getBoolAsync('is_vendor');
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    _isVendor = getBoolAsync('is_vendor');
    return Scaffold(
      backgroundColor: cream,
      body: Stack(
        children: [
          tabs[currentIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ink.withOpacity(0),
                    ink.withOpacity(0.05),
                    ink.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: Container(
              height: 72.h,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: sand, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: ink.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.dashboard_rounded, 'Catalogue'),
                  _buildNavItem(2, Icons.person_rounded, _isVendor ? 'Profile' : 'Account'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isActive ? primary : textLight.withOpacity(0.4),
            ),
            if (isActive) ...[
              8.width,
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void tabItem(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}
