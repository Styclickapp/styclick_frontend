import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

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
                    'Terms of Service',
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
                    _buildLastUpdated(),
                    24.height,
                    _buildIntro(),
                    32.height,
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By creating an account, accessing, or using the Stylclick mobile application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you must not use the App.\n\n'
                      'These Terms constitute a legally binding agreement between you and Stylclick Technologies Limited ("Stylclick", "we", "us", or "our"), a company incorporated under the laws of the Federal Republic of Nigeria.',
                    ),
                    _buildSection(
                      '2. Eligibility',
                      'To use Stylclick, you must:\n\n'
                      '• Be at least 18 years of age or the age of majority in your jurisdiction\n'
                      '• Have the legal capacity to enter into a binding agreement\n'
                      '• Provide accurate and complete registration information\n'
                      '• Not have been previously suspended or removed from the platform\n\n'
                      'By using the App, you represent and warrant that you meet all eligibility requirements.',
                    ),
                    _buildSection(
                      '3. Account Registration & Security',
                      'You are responsible for:\n\n'
                      '• Maintaining the confidentiality of your account credentials\n'
                      '• All activities that occur under your account\n'
                      '• Notifying us immediately of any unauthorized access or security breach\n'
                      '• Keeping your profile information accurate and up to date\n\n'
                      'We reserve the right to suspend or terminate accounts that violate these Terms or engage in fraudulent activity.',
                    ),
                    _buildSection(
                      '4. Marketplace Services',
                      'Stylclick operates as a marketplace platform connecting:\n\n'
                      '• Buyers seeking tailoring services, fabrics, and ready-to-wear fashion\n'
                      '• Tailors offering sewing and alteration services\n'
                      '• Fabric sellers offering materials and textiles\n'
                      '• Dispatch riders providing delivery services\n\n'
                      'Stylclick facilitates transactions between buyers and vendors but is not a party to the underlying sale or service agreement. We do not guarantee the quality, safety, or legality of items listed, the accuracy of vendor listings, or the ability of vendors to complete orders.',
                    ),
                    _buildSection(
                      '5. Vendor Terms',
                      'If you register as a vendor (tailor, fabric seller, or dispatch rider), you agree to:\n\n'
                      '• Provide accurate descriptions of your products and services\n'
                      '• Fulfill orders in a timely manner as agreed with buyers\n'
                      '• Maintain professional communication with buyers\n'
                      '• Comply with all applicable Nigerian laws and regulations, including consumer protection laws\n'
                      '• Not list counterfeit, stolen, or prohibited items\n'
                      '• Accept the commission structure and payout terms as specified in your vendor agreement\n\n'
                      'Stylclick reserves the right to remove listings, suspend vendor accounts, or withhold payments in cases of fraud, misrepresentation, or policy violations.',
                    ),
                    _buildSection(
                      '6. Buyer Terms',
                      'As a buyer, you agree to:\n\n'
                      '• Provide accurate measurements and style specifications when placing orders\n'
                      '• Make payment for orders through the approved payment methods on the platform\n'
                      '• Inspect delivered items promptly and report any issues within 48 hours\n'
                      '• Engage respectfully with vendors through the platform\n'
                      '• Not engage in chargebacks or payment disputes without first attempting resolution through Stylclick\'s support team',
                    ),
                    _buildSection(
                      '7. Payments & Wallet',
                      'All financial transactions on Stylclick are processed through our integrated payment system:\n\n'
                      '• Payments are processed securely via third-party providers (e.g., Paystack, Flutterwave)\n'
                      '• Funds from buyer payments are held in escrow until order completion is confirmed\n'
                      '• The Stylclick Wallet allows you to store funds for future purchases and receive refunds\n'
                      '• Wallet withdrawals are subject to identity verification (KYC) requirements\n'
                      '• All prices are displayed in Nigerian Naira (NGN) unless otherwise stated\n'
                      '• Stylclick charges a service fee on transactions, which will be clearly disclosed before purchase\n\n'
                      'Refunds are processed according to our Refund Policy, which is available upon request.',
                    ),
                    _buildSection(
                      '8. Chat & Communication',
                      'The in-app chat feature is provided for buyers and vendors to:\n\n'
                      '• Discuss product details, customizations, and pricing\n'
                      '• Negotiate and make offers on products\n'
                      '• Coordinate delivery arrangements\n\n'
                      'You agree not to use the chat feature to:\n\n'
                      '• Send spam, unsolicited promotions, or malicious content\n'
                      '• Share personal contact information to circumvent the platform\n'
                      '• Harass, threaten, or abuse other users\n'
                      '• Engage in transactions outside of the Stylclick platform',
                    ),
                    _buildSection(
                      '9. Intellectual Property',
                      'All content, design, logos, trademarks, and software associated with Stylclick are the property of Stylclick Technologies Limited and are protected by Nigerian and international intellectual property laws.\n\n'
                      'Vendors retain ownership of their product images and descriptions but grant Stylclick a non-exclusive, royalty-free license to display and promote their listings on the platform.\n\n'
                      'You may not copy, modify, distribute, or create derivative works from any Stylclick content without prior written permission.',
                    ),
                    _buildSection(
                      '10. Prohibited Activities',
                      'You agree not to:\n\n'
                      '• Use the App for any unlawful purpose\n'
                      '• Attempt to gain unauthorized access to other users\' accounts or our systems\n'
                      '• Interfere with the proper functioning of the App\n'
                      '• Upload viruses, malware, or other harmful code\n'
                      '• Create multiple accounts to evade suspensions or restrictions\n'
                      '• Engage in price manipulation, fake reviews, or market fraud\n'
                      '• Use automated tools (bots, scrapers) to access the platform',
                    ),
                    _buildSection(
                      '11. Dispute Resolution',
                      'In the event of a dispute between buyers and vendors:\n\n'
                      '1. Parties should first attempt to resolve the issue through in-app chat\n'
                      '2. If unresolved, either party may escalate to Stylclick\'s support team\n'
                      '3. Stylclick will review the dispute and make a determination within 14 business days\n'
                      '4. Stylclick\'s determination is final and binding for disputes involving amounts under NGN 100,000\n'
                      '5. For disputes exceeding NGN 100,000, parties may seek resolution through mediation or the appropriate Nigerian court\n\n'
                      'We encourage all users to maintain clear communication and documentation throughout transactions.',
                    ),
                    _buildSection(
                      '12. Limitation of Liability',
                      'To the maximum extent permitted by Nigerian law:\n\n'
                      '• Stylclick is not liable for any indirect, incidental, special, consequential, or punitive damages\n'
                      '• Our total liability for any claim shall not exceed the amount you paid to Stylclick in the 12 months preceding the claim\n'
                      '• We are not responsible for the actions, products, or services of third-party vendors\n'
                      '• We do not guarantee uninterrupted or error-free operation of the App',
                    ),
                    _buildSection(
                      '13. Termination',
                      'We may suspend or terminate your access to Stylclick at any time, with or without cause, and with or without notice. You may also delete your account at any time through the App settings.\n\n'
                      'Upon termination:\n\n'
                      '• Any outstanding wallet balance will be refunded to your linked bank account within 30 business days\n'
                      '• Your data will be handled in accordance with our Privacy Policy\n'
                      '• Sections of these Terms that are intended to survive termination will remain in effect',
                    ),
                    _buildSection(
                      '14. Governing Law',
                      'These Terms are governed by and construed in accordance with the laws of the Federal Republic of Nigeria. Any legal proceedings arising from these Terms shall be subject to the exclusive jurisdiction of the courts in Lagos, Nigeria.',
                    ),
                    _buildSection(
                      '15. Changes to These Terms',
                      'We reserve the right to modify these Terms at any time. We will provide notice of material changes through the App or via email at least 14 days before the changes take effect. Your continued use of Stylclick after the effective date constitutes your acceptance of the updated Terms.',
                    ),
                    _buildSection(
                      '16. Contact Us',
                      'If you have any questions about these Terms, please contact us:\n\n'
                      '• Email: legal@stylclick.com\n'
                      '• Phone: +234 800 STYLCLICK\n'
                      '• Address: Lagos, Nigeria',
                    ),
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

  Widget _buildLastUpdated() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(FeatherIcons.calendar, size: 16.sp, color: primary),
          10.width,
          Text(
            'Last updated: July 2026',
            style: GoogleFonts.montserrat(
              fontSize: 12.sp,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Text(
      'Welcome to Stylclick. These Terms of Service govern your use of our mobile application and services. Please read them carefully before using the platform.',
      style: TextStyle(
        fontFamily: 'Cinta',
        fontSize: 14.sp,
        color: ink,
        height: 1.6,
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cinta',
              fontSize: 16.sp,
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          12.height,
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Cinta',
              fontSize: 13.sp,
              color: textLight,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
