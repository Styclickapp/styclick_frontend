import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/core/services/wallet_service.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/modules/settings.dart';
import 'package:stylclick/modules/share_earn.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/order/saved_items.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/utils/helpers.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _filterType = "All";

  bool _isLoading = true;
  List<Map<String, dynamic>> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    final res = await WalletService.instance.getTransactions();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.status == true && res.data != null) {
          _allTransactions = res.data!.map((tx) {
            final isCredit = (tx['type'] ?? tx['transaction_type'] ?? '') == 'credit';
            return {
              'title': tx['title'] ?? tx['description'] ?? 'Transaction',
              'subtitle': tx['subtitle'] ?? tx['reference'] ?? '',
              'time': tx['created_at'] ?? tx['date'] ?? '',
              'amount': (isCredit ? '+ ' : '- ') + 'NGN ${formatPrice(tx['amount'])}',
              'isCredit': isCredit,
              'status': tx['status'] ?? 'Successful',
            };
          }).toList();
        } else {
          _allTransactions = [];
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return _allTransactions.where((tx) {
      final matchesSearch = tx['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterType == "All" ||
          (_filterType == "Credits" && tx['isCredit']) ||
          (_filterType == "Debits" && !tx['isCredit']);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32.r))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter by Type', style: TextStyle(fontFamily: 'Cinta', fontSize: 20.sp, fontWeight: FontWeight.w700, color: primary)),
                  20.height,
                  _buildFilterOption(setModalState, 'All'),
                  _buildFilterOption(setModalState, 'Credits'),
                  _buildFilterOption(setModalState, 'Debits'),
                  30.height,
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(StateSetter setModalState, String type) {
    bool isSelected = _filterType == type;
    return InkWell(
      onTap: () {
        setState(() => _filterType = type);
        setModalState(() {});
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Text(type, style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: isSelected ? primary : ink, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      endDrawer: buildNotificationDrawer(context),
      backgroundColor: cream,
      body: SafeArea(
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
                    child: Icon(
                      FeatherIcons.arrowLeft,
                      color: ink,
                      size: 24.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'My Invoices',
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
                    child: Image.asset(
                      notificationIcon,
                      height: 24.h,
                      width: 24.w,
                      color: ink,
                    ),
                  ),
                ],
              ),
            ),
            32.height,
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: sand),
                ),
                child: Row(
                  children: [
                    Icon(FeatherIcons.search, color: sand, size: 20.sp),
                    12.width,
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                        decoration: InputDecoration(
                          hintText: 'Search invoices...',
                          hintStyle: TextStyle(fontFamily: 'Cinta', color: ink.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _showFilterModal,
                      child: Icon(FeatherIcons.sliders, color: _filterType == "All" ? primary : successColor, size: 18.sp),
                    ),
                  ],
                ),
              ),
            ),
            24.height,
            // Section Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Row(
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 12.sp,
                      color: textLight,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (_filterType != "All")
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)),
                      child: Text(_filterType, style: GoogleFonts.montserrat(fontSize: 9.sp, color: primary, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            16.height,
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primary))
                  : _filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FeatherIcons.fileText, size: 48.sp, color: sand),
                              16.height,
                              Text('No transactions yet', style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: textLight)),
                              8.height,
                              TextButton(
                                onPressed: _fetchTransactions,
                                child: Text('Refresh', style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: primary, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: primary,
                          onRefresh: _fetchTransactions,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 17.w),
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _filteredTransactions[index];
                              return _buildTransactionItem(
                                title: tx['title'],
                                subtitle: tx['subtitle'],
                                time: tx['time'],
                                amount: tx['amount'],
                                isCredit: tx['isCredit'],
                                status: tx['status'],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String time,
    required String amount,
    required bool isCredit,
    required String status,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sand),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xffe8ffed) : const Color(0xfffff3e8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? FeatherIcons.arrowDownLeft : FeatherIcons.arrowUpRight,
              color: isCredit ? successColor : primary,
              size: 20.sp,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontFamily: 'Cinta', 
                    fontSize: 14.sp,
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.height,
                Text(
                  subtitle,
                  style: TextStyle(fontFamily: 'Cinta', 
                    fontSize: 12.sp,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: isCredit ? successColor : ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              4.height,
              Text(
                time,
                style: GoogleFonts.montserrat(
                  fontSize: 9.sp,
                  color: textLight.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget buildNotificationDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(color: cream),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            60.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Cinta',
                  fontSize: 24.sp,
                  color: primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            20.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Divider(color: sand, thickness: 1),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                children: [
                  _buildNotificationItem('Order Confirmed', 'Your Aso-ebi order #4290 has been received.', '2m ago', FeatherIcons.checkCircle),
                  _buildNotificationItem('Promotion', 'Get 20% off on all Ankara materials this weekend!', '1h ago', FeatherIcons.tag),
                  _buildNotificationItem('Update', 'Your measurements have been successfully updated.', '5h ago', FeatherIcons.user),
                  _buildNotificationItem('Payment Successful', 'Wallet top-up of NGN 50,000 successful.', 'Yesterday', FeatherIcons.creditCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String sub, String time, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: white,
              shape: BoxShape.circle,
              border: Border.all(color: sand),
            ),
            child: Icon(icon, color: primary, size: 20.sp),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.width,
                    Text(time, style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight)),
                  ],
                ),
                4.height,
                Text(sub, style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
