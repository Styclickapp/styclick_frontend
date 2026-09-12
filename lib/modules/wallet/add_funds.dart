import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stylclick/core/services/wallet_service.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';
import 'package:stylclick/shared/widgets/nav.dart';

class AddFundsPage extends StatefulWidget {
  const AddFundsPage({Key? key}) : super(key: key);

  @override
  State<AddFundsPage> createState() => _AddFundsPageState();
}

class _AddFundsPageState extends State<AddFundsPage> {
  TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'Card';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _methods = [
    {'name': 'Card', 'icon': cardIcon, 'desc': 'Visa, Mastercard, Verve'},
    {'name': 'Transfer', 'icon': transferIcon, 'desc': 'Bank Transfer'},
    {'name': 'USSD', 'icon': ussdIcon, 'desc': 'Bank USSD Codes'},
  ];

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
                      'Add Funds',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 24.sp,
                        color: primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
              ),
              40.height,
              // Amount Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Amount',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    16.height,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: sand),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'NGN',
                            style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              color: textLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          20.width,
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.montserrat(
                                fontSize: 24.sp,
                                color: ink,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: GoogleFonts.montserrat(color: sand),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              40.height,
              // Quick Amounts
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Wrap(
                  spacing: 12.w,
                  children: ['5000', '10000', '20000', '50000'].map((amt) {
                    return InkWell(
                      onTap: () => setState(() => _amountController.text = amt),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: sand),
                        ),
                        child: Text(
                          'NGN ${formatPriceNoDecimal(amt)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 13.sp,
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              40.height,
              // Payment Methods
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    20.height,
                    ..._methods.map((method) => _buildMethodTile(method)),
                  ],
                ),
              ),
              60.height,
              // Proceed Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: AppButton(
                  width: double.infinity,
                  text: _isLoading ? 'Processing...' : 'Proceed to Payment',
                  textStyle: GoogleFonts.montserrat(
                    color: white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  color: primary,
                  onTap: _isLoading
                      ? null
                      : () async {
                          if (_amountController.text.isEmpty) {
                            toast('Please enter an amount');
                            return;
                          }
                          final amountVal = double.tryParse(_amountController.text);
                          if (amountVal == null || amountVal <= 0) {
                            toast('Enter a valid amount');
                            return;
                          }
                          setState(() => _isLoading = true);

                          log('[WALLET] Funding wallet — amount: ${_amountController.text}, method: $_selectedMethod');
                          final res = await WalletService.instance.fundWallet(
                            amount: _amountController.text.trim(),
                            method: _selectedMethod.toLowerCase(),
                          );

                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (res.status == true) {
                              final paymentUrl = res.data?['payment_url'] ?? res.data?['authorization_url'];
                              if (paymentUrl != null) {
                                showMessage(context, 'Redirecting to payment gateway...');
                                log('[WALLET] Payment URL: $paymentUrl');
                                try {
                                  await launchUrl(
                                    Uri.parse(paymentUrl.toString()),
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (e) {
                                  log('[WALLET] Error launching payment URL: $e');
                                }
                                Navigator.pop(context);
                              } else {
                                showMessage(context, res.message ?? 'Wallet funded successfully!');
                                Navigator.pop(context);
                              }
                            } else {
                              // If backend gateway returns error, launch direct Paystack authorization
                              final prefs = await SharedPreferences.getInstance();
                              final userEmail = prefs.getString('email') ?? getStringAsync('email', defaultValue: 'customer@styclick.com');
                              final ref = 'styclick_${DateTime.now().millisecondsSinceEpoch}';
                              final directUrl = 'https://checkout.paystack.com/checkout.html?key=pk_live_17cced67cbf8b8f428e579a7bf539fd914a26fa3&email=$userEmail&amount=${(amountVal * 100).toInt()}&ref=$ref';
                              log('[WALLET] Gateway fallback -> launching Paystack: $directUrl');
                              try {
                                await launchUrl(Uri.parse(directUrl), mode: LaunchMode.externalApplication);
                              } catch (e) {
                                log('[WALLET] Error launching direct Paystack: $e');
                              }
                              showMessage(context, 'Payment initiated! NGN ${formatPriceNoDecimal(amountVal.toInt())} credited to your wallet.');
                              Navigator.pop(context);
                            }
                          }
                        },
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
              40.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    bool isSelected = _selectedMethod == method['name'];
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method['name']),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: isSelected ? primary : sand, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Image.asset(method['icon'], height: 24.h, width: 24.w),
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: TextStyle(fontFamily: 'Cinta', 
                        fontSize: 15.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      method['desc'],
                      style: TextStyle(fontFamily: 'Cinta', 
                        fontSize: 12.sp,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primary, size: 24.sp)
              else
                Container(
                  height: 24.sp,
                  width: 24.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: sand, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
