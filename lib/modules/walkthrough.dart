import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WalkthroughItem> _items = [
    WalkthroughItem(
      title: 'Discover Unique Style',
      description: 'Explore a world of custom fashion tailored specifically for you.',
      image: loginLogo, // Using logo as placeholder since walkthrough images are missing
    ),
    WalkthroughItem(
      title: 'Connect with Tailors',
      description: 'Find the best tailors to bring your visions to life.',
      image: loginLogo,
    ),
    WalkthroughItem(
      title: 'Seamless Experience',
      description: 'From fabric selection to delivery, we handle everything with care.',
      image: loginLogo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    log('[WALKTHROUGH] WalkthroughScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  log('[WALKTHROUGH] SKIP tapped. Navigating to LoginScreen.');
                  setValue('onboarding', false);
                  const LoginScreen().launch(context, isNewTask: true);
                },
                child: Text(
                  'Skip',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    color: textLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  log('[WALKTHROUGH] Page transitioned to index: $index');
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 220.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white,
                            shape: BoxShape.circle,
                            border: Border.all(color: sand, width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: ink.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              item.image,
                              height: 100.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        32.height,
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cinta',
                            fontSize: 28.sp,
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        16.height,
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Cinta', 
                            fontSize: 15.sp,
                            color: textLight,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(40.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _items.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 4.h,
                      dotWidth: 12.w,
                      activeDotColor: terracotta,
                      dotColor: sand,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _items.length - 1) {
                        log('[WALKTHROUGH] Finished last page. Navigating to LoginScreen.');
                        setValue('onboarding', false);
                        const LoginScreen().launch(context, isNewTask: true);
                      } else {
                        log('[WALKTHROUGH] NEXT tapped. Animating to page: ${_currentPage + 1}');
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: terracotta,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: terracotta.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkthroughItem {
  final String title;
  final String description;
  final String image;

  WalkthroughItem({
    required this.title,
    required this.description,
    required this.image,
  });
}
