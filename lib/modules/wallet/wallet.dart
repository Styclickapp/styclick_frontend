import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/core/services/wallet_service.dart';
import 'package:stylclick/modules/wallet/request_withdrawal.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/wallet/add_funds.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/notification_drawer.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/shared/utils/helpers.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isBalanceVisible = false;

  // ── State ─────────────────────────────────────────────────────────────
  bool _loadingBalance = true;
  String _balance = '—';

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();
  void _openEndDrawer() => _scaffoldKey.currentState?.openEndDrawer();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() => _loadingBalance = true);
    final res = await WalletService.instance.getBalance();
    if (mounted) {
      setState(() {
        _loadingBalance = false;
        if (res.status == true && res.data != null) {
          final raw = res.data!['balance'] ?? res.data!['amount'] ?? res.data!['wallet_balance'];
          _balance = raw != null ? 'NGN ${formatPrice(raw)}' : 'NGN 0.00';
        } else {
          _balance = 'Unavailable';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: buildNotificationDrawer(context),
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
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          finish(context);
                        }
                      },
                      child: Icon(FeatherIcons.arrowLeft, color: ink, size: 24.sp),
                    ),
                    const Spacer(),
                    Text(
                      'Wallet',
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
                      child: Image.asset(notificationIcon, height: 24.h, width: 24.w, color: ink),
                    ),
                  ],
                ),
              ),
              32.height,
              // Balance Card
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
                      opacity: 0.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ink.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                            'Current Balance',
                            style: TextStyle(
                              fontFamily: 'Cinta',
                              color: white.withOpacity(0.5),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Row(
                            children: [
                              if (_loadingBalance)
                                SizedBox(
                                  height: 14.sp,
                                  width: 14.sp,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: white.withOpacity(0.5)),
                                )
                              else
                                InkWell(
                                  onTap: _fetchBalance,
                                  child: Icon(FeatherIcons.refreshCw, color: white.withOpacity(0.4), size: 14.sp),
                                ),
                              8.width,
                              Image.asset('assets/images/logo/appIconAndroid.png', height: 24.h, width: 24.w),
                            ],
                          ),
                        ],
                      ),
                      12.height,
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _isBalanceVisible ? _balance : '••••••••',
                                style: TextStyle(
                                  fontFamily: 'Cinta',
                                  color: white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isBalanceVisible ? FeatherIcons.eyeOff : FeatherIcons.eye,
                              color: white.withOpacity(0.5),
                              size: 20.sp,
                            ),
                            onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                          ),
                        ],
                      ),
                      32.height,
                      Row(
                        children: [
                          _buildWalletAction(
                            label: 'Add Funds',
                            icon: FeatherIcons.plus,
                            onTap: () async {
                              await const AddFundsPage().launch(context);
                              _fetchBalance(); // refresh after returning
                            },
                            isPrimary: true,
                          ),
                          16.width,
                          _buildWalletAction(
                            label: 'Withdraw',
                            icon: FeatherIcons.arrowUpRight,
                            onTap: () async {
                              await const RequestWithdrawal().launch(context);
                              _fetchBalance();
                            },
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                      'Payment Methods',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    20.height,
                    _buildPaymentMethodTile('Credit/Debit Card', cardIcon),
                    _buildPaymentMethodTile('USSD Transfer', ussdIcon),
                    _buildPaymentMethodTile('Bank Transfer', transferIcon),
                    _buildPaymentMethodTile('Cash on Delivery', cashIcon),
                  ],
                ),
              ),
              40.height,
              // History Shortcut
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: InkWell(
                  onTap: () => const TransactionHistory().launch(context),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: sand),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(FeatherIcons.list, color: primary, size: 20.sp),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transaction History',
                                style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: ink, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'View all your recent activities',
                                style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: textLight),
                              ),
                            ],
                          ),
                        ),
                        Icon(FeatherIcons.chevronRight, color: sand, size: 20.sp),
                      ],
                    ),
                  ),
                ),
              ),
              40.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletAction({required String label, required IconData icon, required VoidCallback onTap, required bool isPrimary}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: isPrimary ? primary : white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: isPrimary ? null : Border.all(color: white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: white, size: 16.sp),
              8.width,
              Text(label, style: GoogleFonts.montserrat(color: white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, String iconAsset) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: sand),
        ),
        child: Row(
          children: [
            Image.asset(iconAsset, height: 24.h, width: 24.w),
            16.width,
            Text(title, style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(FeatherIcons.chevronRight, color: sand, size: 18.sp),
          ],
        ),
      ),
    );
  }



  Widget buildNotificationDrawer(BuildContext context) {
    return const NotificationDrawer();
  }
}
