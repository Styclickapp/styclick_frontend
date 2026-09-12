import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/modules/privacy_policy.dart';
import 'package:stylclick/modules/terms_of_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I place an order?',
      'a': 'Browse through our catalogue or select a tailor, choose a style or fabric, provide your measurements, and proceed to checkout. You can pay via your Stylclick wallet, card, bank transfer, or USSD.',
    },
    {
      'q': 'How do I track my order?',
      'a': 'Go to "My Orders" from your account page or the side menu. Each order shows its current status — from confirmed, to in-progress, to dispatched, and delivered.',
    },
    {
      'q': 'How do I become a vendor?',
      'a': 'Tap "Become a Vendor" from the side menu, select your role (Tailor, Fabric Seller, or Dispatch Rider), fill in your business details and complete KYC verification. Once approved, your shop will be live on the marketplace.',
    },
    {
      'q': 'How does the wallet work?',
      'a': 'Your Stylclick wallet lets you store funds for quick purchases. You can top up via card or bank transfer. Vendors receive payouts to their wallet after order completion. You can withdraw funds to your linked bank account at any time.',
    },
    {
      'q': 'Can I negotiate prices?',
      'a': 'Yes! Use the in-app chat to message vendors directly. You can discuss pricing, make offers, and agree on custom terms before placing your order.',
    },
    {
      'q': 'What is the refund policy?',
      'a': 'If an order does not match the agreed specifications, you can raise a dispute within 48 hours of delivery. Our support team will review and mediate. Refunds, when approved, are credited to your Stylclick wallet within 5 business days.',
    },
    {
      'q': 'How do I update my measurements?',
      'a': 'Go to your Account page, tap "Edit Profile & Settings", and scroll to the measurements section. You can update your body measurements at any time — they will be used for future orders.',
    },
    {
      'q': 'Is my payment information secure?',
      'a': 'Absolutely. We use PCI-DSS compliant payment processors (Paystack, Flutterwave) and encrypt all sensitive data. We never store your full card details on our servers.',
    },
  ];

  int _expandedIndex = -1;
  bool _reportSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
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
                    'Help & Support',
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primary, primaryGradient],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(FeatherIcons.helpCircle, color: white, size: 32.sp),
                          14.height,
                          Text(
                            'How can we help you?',
                            style: TextStyle(
                              fontFamily: 'Cinta',
                              fontSize: 22.sp,
                              color: white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          8.height,
                          Text(
                            'Find answers to common questions or reach out to our support team.',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              color: white.withOpacity(0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    28.height,

                    // Contact Options
                    Text(
                      'CONTACT US',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    14.height,
                    Row(
                      children: [
                        Expanded(child: _buildContactCard(FeatherIcons.mail, 'Email', 'support@\nstylclick.com', () => _launchUrl('mailto:support@stylclick.com'))),
                        12.width,
                        Expanded(child: _buildContactCard(FeatherIcons.phone, 'Phone', '+234 800\nSTYLCLICK', () => _launchUrl('tel:+2348001234567'))),
                        12.width,
                        Expanded(child: _buildContactCard(FeatherIcons.messageCircle, 'WhatsApp', 'Chat with\nus', () => _launchUrl('https://wa.me/2348001234567'))),
                      ],
                    ),
                    28.height,

                    // FAQ Section
                    Text(
                      'FREQUENTLY ASKED QUESTIONS',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    14.height,
                    ...List.generate(_faqs.length, (i) => _buildFaqItem(i)),
                    24.height,

                    // Report a Problem
                    Text(
                      'REPORT A PROBLEM',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    14.height,
                    _buildReportSection(),
                    28.height,

                    // Legal links
                    Text(
                      'LEGAL',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    14.height,
                    _buildLegalTile('Privacy Policy', FeatherIcons.fileText, () => const PrivacyPolicyPage().launch(context)),
                    8.height,
                    _buildLegalTile('Terms of Service', FeatherIcons.helpCircle, () => const TermsOfServicePage().launch(context)),
                    80.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: sand),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 20.sp),
            ),
            10.height,
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 13.sp,
                color: ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            4.height,
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10.sp,
                color: textLight,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final isExpanded = _expandedIndex == index;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isExpanded ? primary.withOpacity(0.3) : sand),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _faqs[index]['q']!,
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 14.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  8.width,
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(FeatherIcons.chevronDown, color: isExpanded ? primary : textLight, size: 18.sp),
                  ),
                ],
              ),
              if (isExpanded) ...[
                12.height,
                Divider(color: sand, thickness: 0.8),
                10.height,
                Text(
                  _faqs[index]['a']!,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    color: textLight,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSection() {
    if (_reportSubmitted) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: successColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(FeatherIcons.checkCircle, color: successColor, size: 36.sp),
            12.height,
            Text(
              'Report Submitted',
              style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: ink, fontWeight: FontWeight.w700),
            ),
            6.height,
            Text(
              'Thank you! Our team will review your report and get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 12.sp, color: textLight, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us what went wrong and we\'ll help fix it.',
            style: GoogleFonts.montserrat(fontSize: 12.sp, color: textLight, height: 1.5),
          ),
          16.height,
          CustomTextField(
            label: 'Subject',
            labelColor: ink,
            hintText: 'e.g. Payment issue, Order problem',
            hintTextColor: textLight.withOpacity(0.5),
          ),
          12.height,
          CustomTextField(
            label: 'Description',
            labelColor: ink,
            hintText: 'Describe the issue in detail...',
            hintTextColor: textLight.withOpacity(0.5),
            maxLines: 4,
          ),
          20.height,
          InkWell(
            onTap: () => setState(() => _reportSubmitted = true),
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                gradient: const LinearGradient(colors: [primary, primaryGradient]),
              ),
              child: Center(
                child: Text(
                  'Submit Report',
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 15.sp,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: sand),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 20.sp),
            16.width,
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(FeatherIcons.chevronRight, color: sand, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
