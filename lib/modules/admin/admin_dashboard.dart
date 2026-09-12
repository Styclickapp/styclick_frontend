import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/constants/strings.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All'; // 'All', 'Tailor', 'Seller', 'Rider'
  String _searchQuery = '';

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  final List<Map<String, dynamic>> _pendingVendors = [];
  final List<Map<String, dynamic>> _approvedVendors = [];
  final List<Map<String, dynamic>> _flaggedContent = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    return list.where((item) {
      final nameMatches = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['owner'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedFilter == 'All') return nameMatches;
      return nameMatches && item['type'].toString().contains(_selectedFilter);
    }).toList();
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
          children: [
            20.height,
            // Styled StyClick Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
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
                    child: Image.asset(
                      backIcon,
                      color: ink,
                      width: 24.w,
                    ),
                  ),
                  16.width,
                  Text(
                    'Vendor Verification',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 22.sp,
                      color: primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
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
            20.height,
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // StyClick Gradient Summary Card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primary, primaryGradient],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Moderation Dashboard',
                                      style: TextStyle(
                                        fontFamily: 'Cinta',
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    4.height,
                                    Text(
                                      'Review & verify vendor applications',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    FeatherIcons.shield,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                ),
                              ],
                            ),
                            20.height,
                            // Stat Pills inside Banner
                            Row(
                              children: [
                                _buildBannerStatItem('Pending', '${_pendingVendors.length}'),
                                _buildVerticalDivider(),
                                _buildBannerStatItem('Approved', '${_approvedVendors.length}'),
                                _buildVerticalDivider(),
                                _buildBannerStatItem('Flagged', '${_flaggedContent.length}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    24.height,

                    // Search Bar styled exact with StyClick Search Input
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      child: Container(
                        height: 52.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: sand),
                          boxShadow: [
                            BoxShadow(
                              color: ink.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: ink.withOpacity(0.5), size: 20.sp),
                            12.width,
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                                decoration: InputDecoration(
                                  hintText: 'Search vendors by name, ID or location...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Cinta',
                                    color: ink.withOpacity(0.4),
                                    fontSize: 14.sp,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: Icon(FeatherIcons.x, color: textLight, size: 18.sp),
                              ),
                          ],
                        ),
                      ),
                    ),
                    16.height,

                    // Category Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 17.w, right: 8.w),
                      child: Row(
                        children: ['All', 'Tailor', 'Fabric Seller', 'Dispatch Rider'].map((filter) {
                          bool isSelected = _selectedFilter == filter;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSelected ? primary : white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: isSelected ? primary : sand),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontFamily: 'Cinta',
                                  fontSize: 12.sp,
                                  color: isSelected ? Colors.white : ink,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    20.height,

                    // Segment Tabs Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: sand),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: textLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Cinta',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontFamily: 'Cinta',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          labelPadding: EdgeInsets.zero,
                          padding: EdgeInsets.all(4.w),
                          tabs: [
                            Tab(text: 'Pending (${_pendingVendors.length})'),
                            Tab(text: 'Approved (${_approvedVendors.length})'),
                            Tab(text: 'Flagged (${_flaggedContent.length})'),
                          ],
                        ),
                      ),
                    ),
                    16.height,

                    // Tab View Contents
                    SizedBox(
                      height: 520.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildVendorListView(_filterList(_pendingVendors), 'pending'),
                          _buildVendorListView(_filterList(_approvedVendors), 'approved'),
                          _buildVendorListView(_filterList(_flaggedContent), 'flagged'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerStatItem(String label, String count) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          2.height,
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30.h,
      width: 1.w,
      color: Colors.white.withOpacity(0.3),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }

  Widget _buildVendorListView(List<Map<String, dynamic>> items, String listType) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              catalogue,
              height: 60.h,
              color: textLight.withOpacity(0.4),
            ),
            16.height,
            Text(
              'No items found',
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 16.sp,
                color: ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            4.height,
            Text(
              'No applications match your search criteria.',
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 12.sp,
                color: textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildStyledVendorCard(item, listType);
      },
    );
  }

  Widget _buildStyledVendorCard(Map<String, dynamic> item, String listType) {
    final typeIconMap = {
      'Tailor': sewingMachine,
      'Fabric Seller': fabric,
      'Dispatch Rider': dispatchRider,
    };

    final String? iconAsset = typeIconMap[item['type']];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sand),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Vendor Icon + Name + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: iconAsset != null
                    ? Image.asset(
                        iconAsset,
                        height: 32.h,
                        width: 32.w,
                        color: primary,
                      )
                    : Icon(FeatherIcons.alertTriangle, color: primary, size: 28.sp),
              ),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: TextStyle(
                              fontFamily: 'Cinta',
                              fontSize: 16.sp,
                              color: ink,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    Text(
                      'Owner: ${item['owner'] ?? 'N/A'} • ID: ${item['id']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.sp,
                        color: textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.height,
          Divider(color: sand, thickness: 1),
          8.height,

          // Location & Contact info
          Row(
            children: [
              Icon(FeatherIcons.mapPin, size: 13.sp, color: primary),
              6.width,
              Expanded(
                child: Text(
                  item['location'] ?? 'Not specified',
                  style: TextStyle(
                    fontFamily: 'Cinta',
                    fontSize: 13.sp,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          6.height,
          Row(
            children: [
              Icon(FeatherIcons.mail, size: 13.sp, color: textLight),
              6.width,
              Expanded(
                child: Text(
                  item['email'] ?? '',
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: textLight),
                ),
              ),
              Icon(FeatherIcons.phone, size: 13.sp, color: textLight),
              6.width,
              Text(
                item['phone'] ?? '',
                style: GoogleFonts.montserrat(fontSize: 11.sp, color: textLight),
              ),
            ],
          ),
          12.height,

          // Tags / Credentials (CAC & NIN)
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: sand.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAC Reg:',
                      style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight, fontWeight: FontWeight.w600),
                    ),
                    2.height,
                    Text(
                      item['cacNumber'] ?? 'N/A',
                      style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: ink, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Container(height: 24.h, width: 1.w, color: sand),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NIN Verification:',
                      style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight, fontWeight: FontWeight.w600),
                    ),
                    2.height,
                    Text(
                      item['nin'] ?? 'Verified',
                      style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: ink, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Container(height: 24.h, width: 1.w, color: sand),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category:',
                      style: GoogleFonts.montserrat(fontSize: 10.sp, color: textLight, fontWeight: FontWeight.w600),
                    ),
                    2.height,
                    Text(
                      item['type'],
                      style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (item['reason'] != null) ...[
            10.height,
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(FeatherIcons.info, size: 14.sp, color: primary),
                  8.width,
                  Expanded(
                    child: Text(
                      'Report Reason: ${item['reason']}',
                      style: GoogleFonts.montserrat(fontSize: 11.sp, color: primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          16.height,

          // Action Buttons styled with StyClick theme
          Row(
            children: [
              if (listType == 'pending') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openReviewBottomSheet(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Review Documents',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                10.width,
                InkWell(
                  onTap: () => _showConfirmationDialog(
                    title: 'Approve Vendor',
                    content: 'Grant vendor verification badge to "${item['name']}"?',
                    actionText: 'Approve & Verify',
                    onConfirm: () {
                      setState(() {
                        _pendingVendors.remove(item);
                        item['status'] = 'approved';
                        _approvedVendors.add(item);
                      });
                      toast('${item['name']} approved successfully!');
                    },
                  ),
                  child: Container(
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: const Color(0xff10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xff10B981).withOpacity(0.3)),
                    ),
                    child: Icon(FeatherIcons.check, color: const Color(0xff10B981), size: 18.sp),
                  ),
                ),
                8.width,
                InkWell(
                  onTap: () => _showConfirmationDialog(
                    title: 'Reject Application',
                    content: 'Reject the vendor application for "${item['name']}"?',
                    actionText: 'Reject Application',
                    isDestructive: true,
                    onConfirm: () {
                      setState(() {
                        _pendingVendors.remove(item);
                      });
                      toast('Application rejected.');
                    },
                  ),
                  child: Container(
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: primary.withOpacity(0.3)),
                    ),
                    child: Icon(FeatherIcons.x, color: primary, size: 18.sp),
                  ),
                ),
              ] else if (listType == 'approved') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openReviewBottomSheet(item),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: sand),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'View Profile Details',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 13.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                10.width,
                ElevatedButton(
                  onPressed: () => _showConfirmationDialog(
                    title: 'Revoke Verification',
                    content: 'Temporarily revoke verification status for "${item['name']}"?',
                    actionText: 'Revoke Status',
                    isDestructive: true,
                    onConfirm: () {
                      setState(() {
                        _approvedVendors.remove(item);
                        item['status'] = 'pending';
                        _pendingVendors.add(item);
                      });
                      toast('Vendor verification revoked.');
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF59E0B),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Suspend',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else if (listType == 'flagged') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openReviewBottomSheet(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Investigate Report',
                      style: TextStyle(
                        fontFamily: 'Cinta',
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                10.width,
                InkWell(
                  onTap: () => _showConfirmationDialog(
                    title: 'Dismiss Report',
                    content: 'Clear flagged warning for "${item['name']}"?',
                    actionText: 'Clear Flag',
                    onConfirm: () {
                      setState(() {
                        _flaggedContent.remove(item);
                      });
                      toast('Report dismissed.');
                    },
                  ),
                  child: Container(
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: const Color(0xff10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(FeatherIcons.check, color: const Color(0xff10B981), size: 18.sp),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _openReviewBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            12.height,
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: sand,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            16.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Text(
                    'Application Dossier',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 20.sp,
                      color: ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(FeatherIcons.x, color: ink, size: 20.sp),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Divider(color: sand, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor Card Header
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: sand),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(FeatherIcons.briefcase, color: primary, size: 24.sp),
                          ),
                          14.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontFamily: 'Cinta',
                                    fontSize: 16.sp,
                                    color: ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                4.height,
                                Text(
                                  'Application ID: ${item['id']}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.height,

                    Text(
                      'VERIFICATION DOCUMENTS',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    12.height,

                    // Document Placeholders
                    _buildDocumentTile('CAC Certificate', item['cacNumber'] ?? 'CAC-Certificate.pdf', true),
                    8.height,
                    _buildDocumentTile('National Identification (NIN)', item['nin'] ?? 'NIN-Slip.pdf', true),
                    8.height,
                    _buildDocumentTile('Proof of Address / Utility Bill', 'Utility_Bill_Verified.pdf', true),
                    24.height,

                    if (item['specializations'] != null) ...[
                      Text(
                        'SPECIALIZATIONS & SERVICES',
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          color: textLight,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      12.height,
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: (item['specializations'] as List).map((spec) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: primary.withOpacity(0.2)),
                            ),
                            child: Text(
                              spec,
                              style: TextStyle(
                                fontFamily: 'Cinta',
                                fontSize: 12.sp,
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      24.height,
                    ],

                    Text(
                      'PORTFOLIO PREVIEW',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        color: textLight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    12.height,

                    Row(
                      children: [catFemaleAsoEbi, catMaleAsoEbi, catAnkara].map((img) {
                        return Expanded(
                          child: Container(
                            height: 100.h,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              image: DecorationImage(
                                image: AssetImage(img),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    30.height,
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _pendingVendors.remove(item);
                          item['status'] = 'approved';
                          _approvedVendors.add(item);
                        });
                        toast('${item['name']} approved and verified!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Approve Application',
                        style: TextStyle(
                          fontFamily: 'Cinta',
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildDocumentTile(String title, String subtitle, bool isVerified) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: sand),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xff10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(FeatherIcons.fileText, color: const Color(0xff10B981), size: 18.sp),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontFamily: 'Cinta', fontSize: 13.sp, color: ink, fontWeight: FontWeight.w700),
                ),
                2.height,
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: textLight),
                ),
              ],
            ),
          ),
          Icon(FeatherIcons.checkCircle, color: const Color(0xff10B981), size: 18.sp),
        ],
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required String actionText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cinta',
            fontSize: 18.sp,
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontFamily: 'Cinta',
            fontSize: 14.sp,
            color: textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 14.sp,
                color: textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? primary : const Color(0xff10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                  _buildNotificationItem('Vendor Application', 'New vendor application received from Adebayo Couture.', '10m ago', FeatherIcons.userCheck),
                  _buildNotificationItem('KYC Document Alert', 'Kemi Fabrics submitted updated CAC certificates.', '1h ago', FeatherIcons.fileText),
                  _buildNotificationItem('Flagged Content', 'Suspicious listing reported by 4 buyers.', '3h ago', FeatherIcons.alertTriangle),
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
