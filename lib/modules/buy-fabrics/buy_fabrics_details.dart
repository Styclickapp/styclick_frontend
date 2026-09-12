import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/modules/vendor/vendor_profile.dart';
import 'package:stylclick/core/services/vendor_service.dart';

import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/modules/details.dart';
import 'package:stylclick/modules/chat/chat_detail.dart';
import 'package:stylclick/shared/utils/helpers.dart';

class FabricSellerDetails extends StatefulWidget {
  final String businessName;
  final String? vendorId;
  final String? vendorEmail;
  final String? vendorPhone;
  final String? vendorAddress;
  final String? vendorBio;
  final String? vendorSpecialization;
  final String? vendorBanner;
  final String? vendorAvatar;

  const FabricSellerDetails({
    Key? key,
    required this.businessName,
    this.vendorId,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorAddress,
    this.vendorBio,
    this.vendorSpecialization,
    this.vendorBanner,
    this.vendorAvatar,
  }) : super(key: key);

  @override
  State<FabricSellerDetails> createState() => _FabricSellerDetailsState();
}

class _FabricSellerDetailsState extends State<FabricSellerDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VendorProduct> _products = [];
  bool _isLoading = false;

  // Vendor profile loaded from API
  String? _email;
  String? _phone;
  String? _address;
  String? _bio;
  String? _specialization;
  String? _banner;
  String? _avatar;

  Future<void> _loadVendorProfile([String? vendorId]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localShopName = prefs.getString('shop_name') ?? prefs.getString('fName');
      final isOwnShop = localShopName != null && localShopName.toLowerCase().trim() == widget.businessName.toLowerCase().trim();

      if (isOwnShop && mounted) {
        setState(() {
          if ((prefs.getString('email') ?? '').isNotEmpty) _email = prefs.getString('email');
          if ((prefs.getString('phone') ?? '').isNotEmpty) _phone = prefs.getString('phone');
          if ((prefs.getString('address') ?? '').isNotEmpty) _address = prefs.getString('address');
          if ((prefs.getString('vendor_bio') ?? '').isNotEmpty) _bio = prefs.getString('vendor_bio');
          if ((prefs.getString('specializations') ?? '').isNotEmpty) _specialization = prefs.getString('specializations');
          if ((prefs.getString('vendor_banner_path') ?? '').isNotEmpty) _banner = prefs.getString('vendor_banner_path');
          if ((prefs.getString('vendor_avatar_path') ?? '').isNotEmpty) _avatar = prefs.getString('vendor_avatar_path');
        });
      }

      dynamic resData;
      if (isOwnShop) {
        final ownRes = await VendorService.instance.getProfile();
        if (ownRes.status == true) resData = ownRes.data;
      } else if (vendorId != null && vendorId.isNotEmpty) {
        final pubRes = await VendorService.instance.getPublicVendorProfile(vendorId);
        if (pubRes.status == true) resData = pubRes.data;
      } else {
        return;
      }

      if (resData != null && mounted) {
        Map<String, dynamic>? data;
        if (resData is Map) {
          final m = Map<String, dynamic>.from(resData);
          data = m['data'] is Map ? Map<String, dynamic>.from(m['data'] as Map) : m;
        }
        if (data != null) {
          setState(() {
            final em = data!['email']?.toString() ?? data['vendor_email']?.toString();
            if (em != null && em.isNotEmpty) _email = em;
            final ph = data['phone']?.toString() ?? data['phone_number']?.toString();
            if (ph != null && ph.isNotEmpty) _phone = ph;
            final ad = data['address']?.toString() ?? data['shop_address']?.toString() ?? data['location']?.toString();
            if (ad != null && ad.isNotEmpty) _address = ad;
            final bi = data['bio']?.toString() ?? data['vendor_bio']?.toString() ?? data['description']?.toString();
            if (bi != null && bi.isNotEmpty) _bio = bi;
            final sp = data['specialization']?.toString() ?? data['specializations']?.toString() ?? data['fabric_type']?.toString();
            if (sp != null && sp.isNotEmpty) _specialization = sp;
            final bn = data['banner_url']?.toString() ?? data['banner']?.toString() ?? data['vendor_banner_path']?.toString();
            if (bn != null && bn.isNotEmpty) _banner = bn;
            final av = data['avatar_url']?.toString() ?? data['avatar']?.toString() ?? data['vendor_avatar_path']?.toString();
            if (av != null && av.isNotEmpty) _avatar = av;
          });
        }
      }
    } catch (e) {
      log('[FABRIC_DETAILS] Failed to load vendor profile: $e');
    }
  }

  Future<void> _loadProducts() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await _loadVendorProfile(widget.vendorId);
      final res = await VendorService.instance.getPublicProducts();
      List? list;
      if (res.data is List) {
        list = res.data as List;
      } else if (res.data is Map && (res.data as Map)['data'] is List) {
        list = (res.data as Map)['data'] as List;
      }
      if (list != null) {
        final loaded = list.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return VendorProduct.fromJson(m);
        }).toList();

        // Filter products specifically matching this vendor's shop name
        final filtered = loaded.where((p) => p.vendorName?.toLowerCase() == widget.businessName.toLowerCase()).toList();

        if (mounted) setState(() => _products = filtered);

        if (_email == null && filtered.isNotEmpty && filtered.first.vendorId != null) {
          await _loadVendorProfile(filtered.first.vendorId);
        }
      }
    } catch (e) {
      log('[FABRIC_DETAILS] Failed to load products: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Seed from passed-in widget params (may be null if coming from home feed)
    _email = widget.vendorEmail;
    _phone = widget.vendorPhone;
    _address = widget.vendorAddress;
    _bio = widget.vendorBio;
    _specialization = widget.vendorSpecialization;
    _banner = widget.vendorBanner;
    _avatar = widget.vendorAvatar;
    // Fetch full profile immediately if vendorId was passed
    if (widget.vendorId != null) {
      _loadVendorProfile(widget.vendorId!);
    }
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _chatStylist() {
    ChatDetailPage(
      vendorName: widget.businessName,
      vendorType: 'seller',
      productName: 'Fabric Inquiry',
    ).launch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        top: true,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [_buildSliverHeader()],
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildProductsTab(), _buildReviewsTab(), _buildAboutTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    final banner = _banner;
    if (banner == null || banner.isEmpty) {
      return Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: 180.h);
    }
    if (banner.startsWith('http://') || banner.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: banner,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180.h,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: sand,
          highlightColor: Colors.white,
          child: Container(width: double.infinity, height: 180.h, color: sand),
        ),
        errorWidget: (_, __, ___) => Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: 180.h),
      );
    }
    if (banner.startsWith('assets/')) {
      return Image.asset(banner, fit: BoxFit.cover, width: double.infinity, height: 180.h);
    }
    try {
      final file = File(banner);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, width: double.infinity, height: 180.h);
      }
    } catch (_) {}
    return Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: 180.h);
  }

  Widget _buildAvatarWidget() {
    final avatar = _avatar;
    if (avatar == null || avatar.isEmpty) {
      return CircleAvatar(
        radius: 40.r,
        backgroundColor: sand,
        backgroundImage: const AssetImage(profileAvatar),
      );
    }
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatar,
          width: 80.r,
          height: 80.r,
          fit: BoxFit.cover,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: sand,
            highlightColor: Colors.white,
            child: Container(width: 80.r, height: 80.r, color: sand),
          ),
          errorWidget: (_, __, ___) => CircleAvatar(
            radius: 40.r,
            backgroundColor: sand,
            backgroundImage: const AssetImage(profileAvatar),
          ),
        ),
      );
    }
    if (avatar.startsWith('assets/')) {
      return CircleAvatar(
        radius: 40.r,
        backgroundColor: sand,
        backgroundImage: AssetImage(avatar),
      );
    }
    try {
      final file = File(avatar);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 40.r,
          backgroundColor: sand,
          backgroundImage: FileImage(file),
        );
      }
    } catch (_) {}
    return CircleAvatar(
      radius: 40.r,
      backgroundColor: sand,
      backgroundImage: const AssetImage(profileAvatar),
    );
  }

  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background/banner and info text
          Column(
            children: [
              // Banner with Shimmer/File/Asset safety
              SizedBox(
                height: 180.h,
                width: double.infinity,
                child: Stack(
                  children: [
                    _buildBannerImage(),
                    Container(color: Colors.black.withOpacity(0.25)),
                    Positioned(
                      top: 16.h,
                      left: 16.w,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                          child: Icon(FeatherIcons.arrowLeft, color: Colors.white, size: 22.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(20.w, 64.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.businessName, style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: ink)),
                              4.height,
                              Row(children: [
                                _badge('Fabric Seller', primary.withOpacity(0.1), primary),
                                8.width,
                                _badge('● Active', successColor.withOpacity(0.1), successColor),
                              ]),
                              8.height,
                              Text(_bio ?? '',
                                  style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (_address != null && _address!.isNotEmpty) ...[
                                8.height,
                                Row(children: [
                                  Icon(FeatherIcons.mapPin, size: 12.sp, color: textLight),
                                  4.width,
                                  Expanded(child: Text(_address!,
                                      style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: textLight), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ]),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _chatStylist,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20.r)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(FeatherIcons.messageCircle, size: 12.sp, color: Colors.white),
                              6.width,
                              Text('Chat', style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    // Stats
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: sand)),
                      child: Row(children: [
                        _stat('${_products.length}', 'Listings'),
                        _statDivider(),
                        _stat('—', 'Orders'),
                        _statDivider(),
                        _stat('—', 'Reviews'),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Avatar with Shimmer/File/Asset safety
          Positioned(
            top: 130.h,
            left: 20.w,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: _buildAvatarWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
        child: Text(label, style: GoogleFonts.montserrat(fontSize: 10.sp, color: fg, fontWeight: FontWeight.w700)),
      );

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [
          Text(value, style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w800, color: ink)),
          2.height,
          Text(label, style: TextStyle(fontFamily: cinta, fontSize: 11.sp, color: textLight)),
        ]),
      );

  Widget _statDivider() => Container(width: 1, height: 32.h, color: sand);

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        labelColor: primary,
        unselectedLabelColor: textLight,
        indicatorColor: primary,
        indicatorWeight: 2.5,
        labelStyle: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500),
        tabs: const [Tab(text: 'Listings'), Tab(text: 'Reviews'), Tab(text: 'About')],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primary));
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FeatherIcons.package, size: 48.sp, color: textLight),
              12.height,
              Text('No listings yet', style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ink)),
              6.height,
              Text('This seller has not posted any products yet.', style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return MasonryGridView.count(
      padding: EdgeInsets.only(left: 17.w, right: 17.w, top: 16.h, bottom: 120.h),
      crossAxisCount: 2,
      mainAxisSpacing: 8.w,
      crossAxisSpacing: 8.w,
      itemCount: _products.length,
      itemBuilder: (_, i) {
        final product = _products[i];
        final imageHeight = i.isEven ? 200.h : 260.h;
        final String? firstImage = product.imagePaths.isNotEmpty ? product.imagePaths.first : null;

        return GestureDetector(
          onTap: () {
            CategoryDetails(
              name: product.name,
              price: product.price,
              description: product.description,
              imagePaths: product.imagePaths,
              category: product.category,
              stock: product.stock,
              storeName: widget.businessName,
              vendorType: 'seller',
              vendorEmail: widget.vendorEmail ?? product.vendorEmail,
              vendorPhone: widget.vendorPhone ?? product.vendorPhone,
              vendorAddress: widget.vendorAddress ?? product.vendorAddress,
              vendorBio: widget.vendorBio ?? product.vendorBio,
              vendorSpecialization: widget.vendorSpecialization ?? product.vendorSpecialization,
              vendorBanner: widget.vendorBanner ?? product.vendorBanner,
              vendorAvatar: widget.vendorAvatar ?? product.vendorAvatar,
              isOwner: false,
            ).launch(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.white,
              border: Border.all(color: sand),
              boxShadow: [BoxShadow(color: ink.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: firstImage == null
                      ? Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                      : (firstImage.startsWith('http://') || firstImage.startsWith('https://')
                          ? CachedNetworkImage(
                              imageUrl: firstImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: imageHeight,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor: sand,
                                highlightColor: Colors.white,
                                child: Container(width: double.infinity, height: imageHeight, color: sand),
                              ),
                              errorWidget: (_, __, ___) => Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: imageHeight),
                            )
                          : (firstImage.startsWith('assets/')
                              ? Image.asset(firstImage, fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                              : (File(firstImage).existsSync()
                                  ? Image.file(File(firstImage), fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                  : Image.asset(femaleAsoebi, fit: BoxFit.cover, width: double.infinity, height: imageHeight)))),
                ),
                12.height,
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: cinta, fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700)),
                6.height,
                Row(children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(4.r)),
                        child: Text(product.category.isNotEmpty ? product.category : 'Fabric', style: GoogleFonts.montserrat(fontSize: 9.sp, color: textLight, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ]),
                8.height,
                Text('NGN ${formatPriceNoDecimal(product.price)}', style: GoogleFonts.montserrat(fontSize: 13.sp, color: primary, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(FeatherIcons.star, size: 48.sp, color: sand),
          16.height,
          Text('No reviews yet', style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ink)),
          8.height,
          Text('Reviews from verified buyers will appear here.', style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildAboutTab() {
    final specs = _specialization != null && _specialization!.isNotEmpty
        ? _specialization!.split(',')
        : <String>[];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Shop Details'),
          _infoCard([
            _infoRow(FeatherIcons.briefcase, 'Shop Name', widget.businessName),
            if (_email != null && _email!.isNotEmpty) _infoRow(FeatherIcons.mail, 'Email', _email!),
            if (_phone != null && _phone!.isNotEmpty) _infoRow(FeatherIcons.phone, 'Phone', _phone!),
            if (_address != null && _address!.isNotEmpty) _infoRow(FeatherIcons.mapPin, 'Location', _address!),
          ]),
          if (specs.isNotEmpty) ...[
            16.height,
            _sectionTitle('Fabric Categories'),
            _infoCard([
              Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: specs.map((s) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: primary.withOpacity(0.2)),
                  ),
                  child: Text(s.trim(), style: GoogleFonts.montserrat(fontSize: 12.sp, color: primary, fontWeight: FontWeight.w600)),
                )).toList(),
              ),
            ]),
          ],
          80.height,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(title, style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w800, color: ink)),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sand),
        boxShadow: [BoxShadow(color: ink.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: textLight),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontFamily: cinta, fontSize: 11.sp, color: textLight)),
                2.height,
                Text(value, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
