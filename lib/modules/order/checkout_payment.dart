import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/core/services/wallet_service.dart';
import 'package:stylclick/core/services/cart_service.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/modules/success_page.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';
import 'package:stylclick/modules/wallet/add_funds.dart';

class CheckoutPaymentPage extends StatefulWidget {
  final bool isPayment;
  const CheckoutPaymentPage({Key? key, required this.isPayment}) : super(key: key);

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  bool isLoading = false;

  Widget _buildStepIndicator(int currentStep) {
    return Container(
      color: cream,
      padding: EdgeInsets.only(left: 17.w, right: 17.w, bottom: 16.h, top: 4.h),
      child: Row(
        children: [
          _buildStepItem('Delivery', 0, currentStep),
          _buildStepLine(0, currentStep),
          _buildStepItem('Payment', 1, currentStep),
          _buildStepLine(1, currentStep),
          _buildStepItem('Summary', 2, currentStep),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, int stepIndex, int currentStep) {
    bool isActive = stepIndex == currentStep;
    bool isCompleted = stepIndex < currentStep;

    return Container(
      height: 32.h,
      width: 90.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, primaryGradient],
              )
            : null,
        color: isActive ? null : (isCompleted ? primary.withOpacity(0.1) : const Color(0xfff4f4f5)),
        border: Border.all(
          color: isActive ? Colors.transparent : (isCompleted ? primary.withOpacity(0.3) : sand),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? white : (isCompleted ? primary : textLight),
            fontSize: 12.sp,
            fontFamily: cinta,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(int afterStep, int currentStep) {
    bool isCompleted = afterStep < currentStep;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        height: 2.h,
        color: isCompleted ? primary : sand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItemModel>>(
      valueListenable: CartService.instance.itemsNotifier,
      builder: (context, cartItems, child) {
        final selectedItems = cartItems.where((item) => item.isSelected).toList();
        final itemsToDisplay = selectedItems.isNotEmpty ? selectedItems : cartItems;
        final subtotal = itemsToDisplay.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
        final deliveryFee = subtotal > 0 ? 2500.0 : 0.0;
        final grandTotal = subtotal + deliveryFee;

        return Scaffold(
          backgroundColor: cream,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 17.w, right: 17.w, bottom: 17.h, top: 8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            try {
                              final res = await WalletService.instance.getBalance().timeout(const Duration(seconds: 15));
                              if (!mounted) return;
                              if (res.status == true && res.data != null) {
                                final raw = res.data!['balance'] ??
                                    res.data!['amount'] ??
                                    res.data!['wallet_balance'];
                                final double balance =
                                    double.tryParse(raw?.toString() ?? '0') ?? 0.0;
                                final double totalCost = grandTotal;

                                if (balance < totalCost) {
                                  showMessage(context,
                                      'Insufficient wallet balance. Please add funds to your wallet.');
                                } else {
                                  CartService.instance.clearCart();
                                  SuccessPage(
                                    message:
                                        'Your order for the custom garments has been successfully placed! NGN ${formatPriceNoDecimal(totalCost.toInt())} has been deducted from your wallet.',
                                  ).launch(context, isNewTask: true);
                                }
                              } else {
                                showMessage(context,
                                    res.message ?? 'Wallet service is currently unavailable. Please try again.');
                              }
                            } catch (e) {
                              if (!mounted) return;
                              log('[CHECKOUT_PAYMENT] Error verifying wallet balance: $e');
                              showMessage(context,
                                  'An unexpected error occurred while processing payment. Please try again.');
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primary, primaryGradient],
                        ),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: white)
                            : Text(
                                'Confirm & Pay (NGN ${formatPriceNoDecimal(grandTotal.toInt())})',
                                style: TextStyle(
                                  fontFamily: cinta,
                                  fontSize: 16.sp,
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  10.height,
                  InkWell(
                    onTap: () {
                      const AddFundsPage().launch(context);
                    },
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: primary, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: primary, size: 18.sp),
                          8.width,
                          Text(
                            'Fund / Top Up Wallet',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 14.sp,
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(110.h),
            child: AppBar(
              elevation: 0,
              backgroundColor: cream,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.height,
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: white,
                              shape: BoxShape.circle,
                              border: Border.all(color: sand),
                            ),
                            child: Icon(Icons.arrow_back, color: ink, size: 20.sp),
                          ),
                        ),
                        16.width,
                        Text(
                          'Checkout',
                          style: TextStyle(
                            fontFamily: cinta,
                            color: ink,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: _buildStepIndicator(1), // Payment screen is step index 1
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    paymentIcon,
                    height: 207.h,
                    width: 224.w,
                    fit: BoxFit.contain,
                  ),
                ),
                16.height,
                Text(
                  'The total amount listed below will be\ndeducted from your wallet system',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 14.sp,
                    color: textLight,
                    height: 1.4,
                  ),
                ),
                24.height,
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: sand),
                    boxShadow: [
                      BoxShadow(
                        color: ink.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                            'Subtotal',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 14.sp,
                              color: textLight,
                            ),
                          ),
                          Text(
                            'NGN ${formatPriceNoDecimal(subtotal.toInt())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                      12.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery fee',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 14.sp,
                              color: textLight,
                            ),
                          ),
                          Text(
                            'NGN ${formatPriceNoDecimal(deliveryFee.toInt())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(color: sand, thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontFamily: cinta,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          Text(
                            'NGN ${formatPriceNoDecimal(grandTotal.toInt())}',
                            style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
