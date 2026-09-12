import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';

class ApplicationPreviewPage extends StatefulWidget {
  const ApplicationPreviewPage({Key? key}) : super(key: key);

  @override
  State<ApplicationPreviewPage> createState() => _ApplicationPreviewPageState();
}

class _ApplicationPreviewPageState extends State<ApplicationPreviewPage> {
  String _shopName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _vendorType = '';
  String _specializations = '';
  String _cacImagePath = '';
  List<String> _portfolioImages = [];

  @override
  void initState() {
    super.initState();
    _loadApplicationData();
  }

  Future<void> _loadApplicationData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopName = prefs.getString('shop_name') ?? prefs.getString('fName') ?? 'Not specified';
      _email = prefs.getString('email') ?? 'Not specified';
      _phone = prefs.getString('phone') ?? 'Not specified';
      _address = prefs.getString('address') ?? 'Not specified';
      _vendorType = prefs.getString('vendor_type') ?? 'tailor';
      _specializations = prefs.getString('specializations') ?? '';
      _cacImagePath = prefs.getString('cac_image_path') ?? '';
      _portfolioImages = prefs.getStringList('portfolio_images') ?? [];
    });
  }

  String _getRoleTitle() {
    switch (_vendorType) {
      case 'tailor':
        return 'Tailor / Designer Application';
      case 'seller':
        return 'Fabric Seller Application';
      case 'rider':
        return 'Dispatch Rider Application';
      default:
        return 'Vendor Application';
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = _specializations.isNotEmpty ? _specializations.split(',').where((s) => s.trim().isNotEmpty).toList() : <String>[];

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FeatherIcons.arrowLeft, color: ink, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Application Preview',
          style: GoogleFonts.montserrat(color: ink, fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card / Status
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primary, primaryGradient],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _getRoleTitle(),
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                      10.width,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Under Review',
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  12.height,
                  Text(
                    'Application Reference: #APP-${DateTime.now().year}-${(_shopName.hashCode % 10000).abs()}',
                    style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            20.height,

            // Business Information
            _buildSectionTitle('Business Information'),
            _buildCard([
              _buildDetailRow(FeatherIcons.shoppingBag, 'Shop / Business Name', _shopName),
              _buildDetailRow(FeatherIcons.mail, 'Email Address', _email),
              _buildDetailRow(FeatherIcons.phone, 'Phone Number', _phone),
              _buildDetailRow(FeatherIcons.mapPin, 'Business Address', _address),
            ]),
            20.height,

            // Specialization / Categories if present
            if (specs.isNotEmpty) ...[
              _buildSectionTitle('Specializations'),
              _buildCard([
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: specs
                      .map((s) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: primary.withOpacity(0.2)),
                            ),
                            child: Text(s.trim(), style: GoogleFonts.montserrat(fontSize: 12.sp, color: primary, fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ]),
              20.height,
            ],

            // Verification Document
            _buildSectionTitle('Verification Documents & Media'),
            _buildCard([
              Row(
                children: [
                  Icon(FeatherIcons.fileText, color: primary, size: 20.sp),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CAC / Business Registration Proof', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: ink)),
                        2.height,
                        Text(_cacImagePath.isNotEmpty ? 'Document attached' : 'Uploaded during application', style: TextStyle(fontFamily: cinta, fontSize: 11.sp, color: textLight)),
                      ],
                    ),
                  ),
                  Icon(FeatherIcons.checkCircle, color: successColor, size: 18.sp),
                ],
              ),
              if (_cacImagePath.isNotEmpty) ...[
                12.height,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: sand)),
                  child: Row(
                    children: [
                      Icon(FeatherIcons.file, color: primary, size: 18.sp),
                      10.width,
                      Expanded(
                        child: Text(
                          _cacImagePath.split(RegExp(r'[/\\]')).last,
                          style: GoogleFonts.montserrat(fontSize: 12.sp, color: ink, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_portfolioImages.isNotEmpty) ...[
                16.height,
                Divider(color: sand, height: 1.h),
                14.height,
                Row(
                  children: [
                    Icon(FeatherIcons.image, color: primary, size: 18.sp),
                    8.width,
                    Text('Proof of Craft / Portfolio (${_portfolioImages.length})', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700, color: ink)),
                  ],
                ),
                10.height,
                SizedBox(
                  height: 90.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _portfolioImages.length,
                    separatorBuilder: (_, __) => 10.width,
                    itemBuilder: (context, index) {
                      final path = _portfolioImages[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: File(path).existsSync()
                            ? Image.file(File(path), width: 90.w, height: 90.h, fit: BoxFit.cover)
                            : Container(width: 90.w, height: 90.h, color: sand, child: Icon(FeatherIcons.image, color: textLight, size: 20.sp)),
                      );
                    },
                  ),
                ),
              ],
            ]),
            30.height,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(title, style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w800, color: ink)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: textLight),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontFamily: cinta, fontSize: 11.sp, color: textLight)),
                Text(value, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
