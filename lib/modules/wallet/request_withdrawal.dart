import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/core/services/wallet_service.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';
import 'package:stylclick/shared/widgets/nav.dart';

class RequestWithdrawal extends StatefulWidget {
  const RequestWithdrawal({Key? key}) : super(key: key);

  @override
  State<RequestWithdrawal> createState() => _RequestWithdrawalState();
}

class _RequestWithdrawalState extends State<RequestWithdrawal> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  String _selectedBank = 'Select Bank';
  bool _isLoading = false;

  final List<String> _banks = [
    'Access Bank',
    'First Bank',
    'GTBank',
    'Kuda Bank',
    'Opay',
    'United Bank for Africa (UBA)',
    'Zenith Bank',
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
                      'Withdraw Funds',
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
              // Balance Indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: ink.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: sand),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available to Withdraw',
                        style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: textLight),
                      ),
                      Text(
                        'NGN 9,500.00',
                        style: GoogleFonts.montserrat(fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              32.height,
              // Amount Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdrawal Amount',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    16.height,
                    _buildInputField(
                      controller: _amountController,
                      hint: '0.00',
                      prefix: 'NGN',
                      isNumeric: true,
                    ),
                  ],
                ),
              ),
              32.height,
              // Bank Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Details',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    20.height,
                    // Bank Selector
                    InkWell(
                      onTap: _showBankPicker,
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: sand),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedBank,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontFamily: 'Cinta', 
                                  fontSize: 15.sp,
                                  color: _selectedBank == 'Select Bank' ? sand : ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(FeatherIcons.chevronDown, color: sand, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                    16.height,
                    _buildInputField(
                      controller: _accountNumberController,
                      hint: 'Account Number',
                      isNumeric: true,
                    ),
                    16.height,
                    _buildInputField(
                      controller: _accountNameController,
                      hint: 'Account Name',
                    ),
                  ],
                ),
              ),
              60.height,
              // Submit Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: AppButton(
                  width: double.infinity,
                  text: _isLoading ? 'Submitting...' : 'Confirm Withdrawal',
                  textStyle: GoogleFonts.montserrat(
                    color: white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  color: primary,
                  onTap: _isLoading
                      ? null
                      : () async {
                          if (_amountController.text.isEmpty ||
                              _selectedBank == 'Select Bank' ||
                              _accountNumberController.text.isEmpty ||
                              _accountNameController.text.isEmpty) {
                            toast('Please complete all fields');
                            return;
                          }
                          setState(() => _isLoading = true);

                          log('[WITHDRAW] Requesting withdrawal — amount: ${_amountController.text}, bank: $_selectedBank, acct: ${_accountNumberController.text}');
                          final res = await WalletService.instance.requestWithdrawal(
                            amount: _amountController.text.trim(),
                            bank: _selectedBank,
                            accountNumber: _accountNumberController.text.trim(),
                            accountName: _accountNameController.text.trim(),
                          );

                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (res.status == true) {
                              showMessage(context, res.message ?? 'Withdrawal request submitted successfully!');
                              Navigator.pop(context);
                            } else {
                              showMessage(context, res.message ?? 'Withdrawal failed. Please try again.');
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

  Widget _buildInputField({required TextEditingController controller, required String hint, String? prefix, bool isNumeric = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sand),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[
            Text(prefix, style: GoogleFonts.montserrat(color: sand, fontWeight: FontWeight.w700)),
            16.width,
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
              style: TextStyle(fontFamily: 'Cinta', fontSize: 15.sp, color: ink, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontFamily: 'Cinta', color: sand),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Bank',
                style: TextStyle(
                  fontFamily: 'Cinta',
                  fontSize: 20.sp,
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              20.height,
              Expanded(
                child: ListView.builder(
                  itemCount: _banks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _banks[index],
                        style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: ink),
                      ),
                      onTap: () {
                        setState(() => _selectedBank = _banks[index]);
                        pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
