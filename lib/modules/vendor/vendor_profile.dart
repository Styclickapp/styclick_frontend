import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/modules/vendor/shop_policies.dart' as sp;
import 'package:stylclick/modules/details.dart';
import 'package:stylclick/core/services/vendor_service.dart';
import 'package:stylclick/modules/chat/chat_list.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

String? _ensureHttps(String? url) {
  if (url == null) return null;
  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }
  return url;
}

class VendorProduct {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final int stock;
  final List<String> imagePaths;
  final String createdAt;
  final double? rating;
  final String? vendorId;
  final String? vendorName;
  final String? vendorType;
  final String? vendorEmail;
  final String? vendorPhone;
  final String? vendorAddress;
  final String? vendorBio;
  final String? vendorSpecialization;
  final String? vendorBanner;
  final String? vendorAvatar;

  VendorProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.stock,
    required this.imagePaths,
    required this.createdAt,
    this.rating,
    this.vendorId,
    this.vendorName,
    this.vendorType,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorAddress,
    this.vendorBio,
    this.vendorSpecialization,
    this.vendorBanner,
    this.vendorAvatar,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'stock': stock,
        'imagePaths': imagePaths,
        'createdAt': createdAt,
        'rating': rating,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'vendorType': vendorType,
        'vendorEmail': vendorEmail,
        'vendorPhone': vendorPhone,
        'vendorAddress': vendorAddress,
        'vendorBio': vendorBio,
        'vendorSpecialization': vendorSpecialization,
        'vendorBanner': vendorBanner,
        'vendorAvatar': vendorAvatar,
      };

  factory VendorProduct.fromJson(Map<String, dynamic> j) {
    final v = j['vendor'] is Map ? Map<String, dynamic>.from(j['vendor']) : null;
    return VendorProduct(
      id: j['id']?.toString() ?? j['_id']?.toString() ?? '',
      name: j['name']?.toString() ?? j['title']?.toString() ?? 'Product',
      price: (j['price'] as num?)?.toDouble() ?? 0.0,
      description: j['description'] ?? '',
      category: j['category'] ?? '',
      stock: j['stock'] ?? 1,
      imagePaths: List<String>.from(j['imagePaths'] ?? j['images'] ?? j['image_paths'] ?? [])
          .map((url) => url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url)
          .toList(),
      createdAt: j['createdAt'] ?? j['created_at'] ?? '',
      rating: (j['rating'] as num?)?.toDouble(),
      vendorId: v?['id']?.toString() ?? v?['_id']?.toString(),
      vendorName: j['vendorName'] ?? v?['shop_name']?.toString() ?? v?['name']?.toString() ?? v?['business_name']?.toString(),
      vendorType: j['vendorType'] ?? v?['vendor_type']?.toString() ?? v?['type']?.toString(),
      vendorEmail: j['vendorEmail'] ?? v?['email']?.toString(),
      vendorPhone: j['vendorPhone'] ?? v?['phone']?.toString() ?? v?['phone_number']?.toString(),
      vendorAddress: j['vendorAddress'] ?? v?['address']?.toString() ?? v?['shop_address']?.toString() ?? v?['location']?.toString(),
      vendorBio: j['vendorBio'] ?? v?['bio']?.toString() ?? v?['vendor_bio']?.toString() ?? v?['description']?.toString(),
      vendorSpecialization: j['vendorSpecialization'] ?? v?['specialization']?.toString() ?? v?['specializations']?.toString() ?? v?['fabric_type']?.toString() ?? v?['fabric_types']?.toString(),
      vendorBanner: _ensureHttps(j['vendorBanner'] ?? v?['banner']?.toString() ?? v?['vendor_banner_path']?.toString() ?? v?['banner_url']?.toString()),
      vendorAvatar: _ensureHttps(j['vendorAvatar'] ?? v?['avatar']?.toString() ?? v?['vendor_avatar_path']?.toString() ?? v?['avatar_url']?.toString()),
    );
  }
}

class BusinessHour {
  String day;
  String open;
  String close;
  bool isClosed;

  BusinessHour({required this.day, required this.open, required this.close, this.isClosed = false});

  Map<String, dynamic> toJson() => {'day': day, 'open': open, 'close': close, 'isClosed': isClosed};
  factory BusinessHour.fromJson(Map<String, dynamic> j) =>
      BusinessHour(day: j['day'], open: j['open'], close: j['close'], isClosed: j['isClosed'] ?? false);
}

// ─── Default data ──────────────────────────────────────────────────────────────

final _defaultHours = [
  BusinessHour(day: 'Monday',    open: '8:00 AM', close: '6:00 PM'),
  BusinessHour(day: 'Tuesday',   open: '8:00 AM', close: '6:00 PM'),
  BusinessHour(day: 'Wednesday', open: '8:00 AM', close: '6:00 PM'),
  BusinessHour(day: 'Thursday',  open: '8:00 AM', close: '6:00 PM'),
  BusinessHour(day: 'Friday',    open: '8:00 AM', close: '6:00 PM'),
  BusinessHour(day: 'Saturday',  open: '9:00 AM', close: '4:00 PM'),
  BusinessHour(day: 'Sunday',    isClosed: true, open: '', close: ''),
];

final _defaultPolicies = [
  sp.Policy(type: 'Returns',   value: 'Within 7 days'),
  sp.Policy(type: 'Delivery',  value: 'Lagos: 1–2 days'),
  sp.Policy(type: 'Guarantee', value: 'Quality assured'),
];

const _timeOptions = [
  '6:00 AM','7:00 AM','8:00 AM','9:00 AM','10:00 AM','11:00 AM','12:00 PM',
  '1:00 PM','2:00 PM','3:00 PM','4:00 PM','5:00 PM','6:00 PM','7:00 PM','8:00 PM','9:00 PM',
];

const _tailorTopCategories = [
  'Tailoring Service',
  'Cloth Stitching',
  'Cloth Repairs',
  'Ready-to-Wear',
];

const _readyToWearSub = [
  'Traditional',
  'Aso-Ebi',
  'Corporate / Senator',
  'Ankara',
  'Lace',
  'Agbada',
  'Kaftan',
  'Native Gown',
  'Jumpsuit',
  'Skirt & Blouse',
  'Casual Wear',
  'Streetwear',
];

const _sellerCategories = [
  'Ankara Fabric',
  'Lace Fabric',
  'Aso-Oke',
  'Guinea / Damask',
  'Senator Material',
  'Wool / Velvet',
  'Chiffon',
  'Adire',
  'Plain Materials',
  'Accessories',
];

// ─── Vendor Profile Page ───────────────────────────────────────────────────────

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({Key? key}) : super(key: key);

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _shopName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _vendorType = '';
  String _specializations = '';
  String _bannerPath = '';
  String _avatarPath = '';
  String _bio = '';

  List<VendorProduct>  _products = [];
  List<BusinessHour>   _hours    = List.from(_defaultHours.map((h) => BusinessHour(day: h.day, open: h.open, close: h.close, isClosed: h.isClosed)));
  List<sp.Policy>      _policies = List.from(_defaultPolicies.map((p) => sp.Policy(type: p.type, value: p.value)));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    List<VendorProduct> products = [];
    try {
      final raw = prefs.getString('vendor_products') ?? '[]';
      products = (json.decode(raw) as List).map((e) => VendorProduct.fromJson(e)).toList();
    } catch (_) {}

    List<BusinessHour> hours = List.from(_defaultHours.map((h) => BusinessHour(day: h.day, open: h.open, close: h.close, isClosed: h.isClosed)));
    try {
      final raw = prefs.getString('vendor_hours');
      if (raw != null) hours = (json.decode(raw) as List).map((e) => BusinessHour.fromJson(e)).toList();
    } catch (_) {}

    List<sp.Policy> policies = List.from(_defaultPolicies.map((p) => sp.Policy(type: p.type, value: p.value)));
    try {
      final raw = prefs.getString('vendor_policies');
      if (raw != null) policies = (json.decode(raw) as List).map((e) => sp.Policy.fromJson(e)).toList();
    } catch (_) {}

    setState(() {
      _shopName = prefs.getString('shop_name') ?? prefs.getString('fName') ?? 'My Shop';
      _email    = prefs.getString('email') ?? '';
      _phone    = prefs.getString('phone') ?? '';
      _address  = prefs.getString('address') ?? '';
      _vendorType = prefs.getString('vendor_type') ?? 'tailor';
      _specializations = prefs.getString('specializations') ?? '';
      _bannerPath = prefs.getString('vendor_banner_path') ?? '';
      _avatarPath = prefs.getString('vendor_avatar_path') ?? '';
      _bio      = prefs.getString('vendor_bio') ?? '';
      _products = products;
      _hours    = hours;
      _policies = policies;
    });

    // Remote sync with backend API
    try {
      final profRes = await VendorService.instance.getProfile();
      if (profRes.status == true && profRes.data != null && mounted) {
        final d = profRes.data!;
        setState(() {
          if (d.containsKey('shop_name')) _shopName = d['shop_name'].toString();
          if (d.containsKey('name')) _shopName = d['name'].toString();
          if (d.containsKey('bio')) _bio = d['bio'].toString();
          if (d.containsKey('email')) _email = d['email'].toString();
          if (d.containsKey('phone')) _phone = d['phone'].toString();
        });
      }
    } catch (_) {}

    try {
      final prodRes = await VendorService.instance.getVendorProducts();
      if (prodRes.status == true && prodRes.data is List && mounted) {
        final remoteProducts = (prodRes.data as List).map((e) {
          if (e is Map<String, dynamic>) {
            return VendorProduct(
              id: e['id']?.toString() ?? e['_id']?.toString() ?? '',
              name: e['name']?.toString() ?? e['title']?.toString() ?? 'Product',
              price: (e['price'] is num) ? (e['price'] as num).toDouble() : 0.0,
              description: e['description']?.toString() ?? '',
              category: e['category']?.toString() ?? '',
              stock: (e['stock'] is num) ? (e['stock'] as num).toInt() : 1,
              imagePaths: e['image_paths'] != null ? List<String>.from(e['image_paths']) : <String>[],
              createdAt: e['created_at']?.toString() ?? '',
            );
          }
          return null;
        }).whereType<VendorProduct>().toList();
        if (remoteProducts.isNotEmpty && mounted) {
          setState(() => _products = remoteProducts);
          _saveProducts();
        }
      }
    } catch (_) {}
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_products', json.encode(_products.map((p) => p.toJson()).toList()));
  }

  Future<void> _saveHours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_hours', json.encode(_hours.map((h) => h.toJson()).toList()));
  }

  Future<void> _savePolicies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_policies', json.encode(_policies.map((p) => p.toJson()).toList()));
  }

  String _vendorTypeLabel() {
    switch (_vendorType) {
      case 'tailor':
      case 'designer':
        return 'Tailor';
      case 'seller': return 'Fabric Seller';
      case 'rider':  return 'Dispatch Rider';
      default:       return 'Vendor';
    }
  }

  String _formatPrice(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000)    return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toStringAsFixed(0);
  }

  void _deleteProduct(String id) async {
    setState(() => _products.removeWhere((p) => p.id == id));
    _saveProducts();
    await VendorService.instance.deleteProduct(id);
    toast('Product removed');
  }

  void _showDeleteConfirm(VendorProduct p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Remove Listing', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16.sp)),
        content: Text('Remove "${p.name}" from your shop?', style: TextStyle(fontFamily: cinta, fontSize: 14.sp)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.montserrat(color: textLight))),
          TextButton(
            onPressed: () { Navigator.pop(context); _deleteProduct(p.id); },
            child: Text('Remove', style: GoogleFonts.montserrat(color: primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Edit Profile ──────────────────────────────────────────────────────────

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        shopName: _shopName,
        email: _email,
        phone: _phone,
        address: _address,
        bio: _bio,
        bannerPath: _bannerPath,
        avatarPath: _avatarPath,
        specializations: _specializations,
        onSave: ({
          required String shopName,
          required String email,
          required String phone,
          required String address,
          required String bio,
          required String bannerPath,
          required String avatarPath,
          required String specializations,
        }) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('shop_name', shopName);
          await prefs.setString('email', email);
          await prefs.setString('phone', phone);
          await prefs.setString('address', address);
          await prefs.setString('vendor_bio', bio);
          await prefs.setString('vendor_banner_path', bannerPath);
          await prefs.setString('vendor_avatar_path', avatarPath);
          await prefs.setString('specializations', specializations);

          setState(() {
            _shopName = shopName;
            _email = email;
            _phone = phone;
            _address = address;
            _bio = bio;
            _bannerPath = bannerPath;
            _avatarPath = avatarPath;
            _specializations = specializations;
          });

          await VendorService.instance.updateProfile({
            'shop_name': shopName,
            'email': email,
            'phone': phone,
            'address': address,
            'bio': bio,
            'specializations': specializations,
          });

          if (mounted) Navigator.pop(context);
          toast('Profile updated');
        },
      ),
    );
  }

  // ─── Add/Edit Product Form ─────────────────────────────────────────────────

  void _showAddProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(
        vendorType: _vendorType,
        onSave: (product) async {
          setState(() => _products.insert(0, product));
          _saveProducts();
          // Batch upload all new local images
          final List<String> localPaths = [];
          final List<String> alreadyUrls = [];
          for (final path in product.imagePaths) {
            if (path.startsWith('/') || path.contains('cache')) {
              localPaths.add(path);
            } else {
              alreadyUrls.add(path); // already a public URL
            }
          }
          final List<String> uploaded = await VendorService.instance.uploadProductImages(localPaths);
          final List<String> finalUrls = [...alreadyUrls, ...uploaded];

          await VendorService.instance.createProduct({
            'name': product.name,
            'price': product.price,
            'description': product.description,
            'category': product.category,
            'stock': product.stock,
            'image_paths': finalUrls,
            'images': finalUrls,
          });
        },
      ),
    );
  }

  void _showEditProduct(VendorProduct oldProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(
        vendorType: _vendorType,
        product: oldProduct,
        onSave: (updatedProduct) async {
          final idx = _products.indexWhere((p) => p.id == oldProduct.id);
          if (idx != -1) {
            setState(() => _products[idx] = updatedProduct);
            _saveProducts();
            // Batch upload all new local images
            final List<String> localPaths = [];
            final List<String> alreadyUrls = [];
            for (final path in updatedProduct.imagePaths) {
              if (path.startsWith('/') || path.contains('cache')) {
                localPaths.add(path);
              } else {
                alreadyUrls.add(path);
              }
            }
            final List<String> uploaded = await VendorService.instance.uploadProductImages(localPaths);
            final List<String> finalUrls = [...alreadyUrls, ...uploaded];

            await VendorService.instance.updateProduct(oldProduct.id, {
              'name': updatedProduct.name,
              'price': updatedProduct.price,
              'description': updatedProduct.description,
              'category': updatedProduct.category,
              'stock': updatedProduct.stock,
              'image_paths': finalUrls,
              'images': finalUrls,
            });
            toast('Listing updated!');
          }
        },
      ),
    );
  }

  // ─── Edit Hours ────────────────────────────────────────────────────────────

  void _showEditHours() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HoursSheet(
        hours: _hours,
        onSave: (updated) async {
          setState(() => _hours = updated);
          _saveHours();
          await VendorService.instance.updateBusinessHours({
            'hours': updated.map((h) => h.toJson()).toList(),
          });
        },
      ),
    );
  }

  // ─── Edit Policies ─────────────────────────────────────────────────────────

  void _showEditPolicies() {
    sp.ShopPoliciesPage(
      policies: _policies.map((p) => sp.Policy(type: p.type, value: p.value)).toList(),
      onSave: (updated) async {
        setState(() {
          _policies = updated.map((p) => sp.Policy(type: p.type, value: p.value)).toList();
        });
        _savePolicies();
        await VendorService.instance.updatePolicies({
          'policies': updated.map((p) => p.toJson()).toList(),
        });
      },
    ).launch(context);
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddProduct,
              backgroundColor: primary,
              icon: const Icon(FeatherIcons.plus, color: Colors.white),
              label: Text('Add Listing', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
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

  // ─── Sliver header ─────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background/banner and info text
          Column(
            children: [
              // Banner
              Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _bannerPath.isEmpty
                      ? const LinearGradient(colors: [Color(0xFFEA4262), Color(0xFFDD6140)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  image: _bannerPath.isNotEmpty
                      ? DecorationImage(image: FileImage(File(_bannerPath)), fit: BoxFit.cover)
                      : null,
                ),
                child: Stack(
                  children: [
                    Container(color: Colors.black.withValues(alpha: 0.25)),
                    Positioned(
                      top: 16.h, left: 16.w,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
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
                              Text(_shopName, style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: ink)),
                              4.height,
                              Row(children: [
                                _badge(_vendorTypeLabel(), primary.withValues(alpha: 0.1), primary),
                                8.width,
                                _badge('● Active', successColor.withValues(alpha: 0.1), successColor),
                              ]),
                              if (_bio.isNotEmpty) ...[
                                8.height,
                                Text(_bio, style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                              8.height,
                              Row(children: [
                                Icon(FeatherIcons.mapPin, size: 12.sp, color: textLight),
                                4.width,
                                Expanded(child: Text(_address.isNotEmpty ? _address : 'No address set',
                                    style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: textLight), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ]),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _showEditProfile,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(border: Border.all(color: sand), borderRadius: BorderRadius.circular(20.r)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(FeatherIcons.edit2, size: 12.sp, color: ink),
                                  6.width,
                                  Text('Edit', style: GoogleFonts.montserrat(fontSize: 12.sp, color: ink, fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ),
                            8.height,
                            GestureDetector(
                              onTap: () {
                                const ChatListPage().launch(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20.r)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(FeatherIcons.messageCircle, size: 12.sp, color: Colors.white),
                                  6.width,
                                  Text('Chats', style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    16.height,
                    // Stats
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: sand)),
                      child: Row(children: [
                        _stat(_products.length.toString(), 'Listings'),
                        _statDivider(),
                        _stat('0', 'Orders'),
                        _statDivider(),
                        _stat('0', 'Reviews'),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Positioned Avatar on top of Column (Ensured z-index paints it above white bio card background)
          Positioned(
            top: 130.h,
            left: 20.w,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: sand,
                backgroundImage: _avatarPath.isNotEmpty ? FileImage(File(_avatarPath)) : null,
                child: _avatarPath.isEmpty
                    ? Text(_shopName.isNotEmpty ? _shopName[0].toUpperCase() : 'S',
                        style: GoogleFonts.montserrat(fontSize: 32.sp, fontWeight: FontWeight.bold, color: primary))
                    : null,
              ),
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

  // ─── Tab bar ───────────────────────────────────────────────────────────────

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

  // ─── Products Tab — catalogue-style masonry grid ────────────────────────────

  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(FeatherIcons.shoppingBag, size: 56.sp, color: sand),
            16.height,
            Text('No listings yet', style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ink)),
            8.height,
            Text('Tap "Add Listing" below to post your first product', style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight), textAlign: TextAlign.center),
          ]),
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
        final p = _products[i];
        final imageHeight = i.isEven ? 200.h : 260.h;
        return GestureDetector(
          onTap: () {
            CategoryDetails(
              name: p.name,
              price: p.price,
              description: p.description,
              imagePaths: p.imagePaths,
              category: p.category,
              stock: p.stock,
              isOwner: true,
              storeName: _shopName,
              vendorType: _vendorType,
              vendorEmail: _email,
              vendorPhone: _phone,
              vendorAddress: _address,
              vendorBio: _bio,
              vendorSpecialization: _specializations,
              vendorBanner: _bannerPath,
              vendorAvatar: _avatarPath,
              onEdit: () {
                Navigator.pop(context);
                _showEditProduct(p);
              },
              onDelete: () {
                Navigator.pop(context);
                _showDeleteConfirm(p);
              },
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
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: p.imagePaths.isNotEmpty
                      ? (p.imagePaths.first.startsWith('http://') || p.imagePaths.first.startsWith('https://')
                          ? CachedNetworkImage(
                              imageUrl: p.imagePaths.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: imageHeight,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor: sand,
                                highlightColor: Colors.white,
                                child: Container(width: double.infinity, height: imageHeight, color: sand),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: imageHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(12.r)),
                                child: Icon(FeatherIcons.image, color: textLight, size: 32.sp),
                              ),
                            )
                          : (p.imagePaths.first.startsWith('assets/')
                              ? Image.asset(p.imagePaths.first, fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                              : (File(p.imagePaths.first).existsSync()
                                  ? Image.file(File(p.imagePaths.first), fit: BoxFit.cover, width: double.infinity, height: imageHeight)
                                  : Container(
                                      height: imageHeight,
                                      width: double.infinity,
                                      decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(12.r)),
                                      child: Icon(FeatherIcons.image, color: textLight, size: 32.sp),
                                    ))))
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(12.r)),
                          child: Icon(FeatherIcons.image, color: textLight, size: 32.sp),
                        ),
                ),
                12.height,
                // Name + trash row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: cinta, fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700)),
                    ),
                    GestureDetector(
                      onTap: () => _showDeleteConfirm(p),
                      child: Icon(FeatherIcons.trash2, size: 16.sp, color: textLight),
                    ),
                  ],
                ),
                6.height,
                // Category + stock left
                Row(children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(4.r)),
                        child: Text(p.category.split(':').first, style: GoogleFonts.montserrat(fontSize: 9.sp, color: textLight, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                  8.width,
                  Text('${p.stock} left', style: TextStyle(fontFamily: cinta, fontSize: 10.sp, color: p.stock < 5 ? Colors.orange : successColor)),
                ]),
                8.height,
                // Price
                Text('NGN ${_formatPrice(p.price)}',
                    style: GoogleFonts.montserrat(fontSize: 13.sp, color: primary, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Reviews Tab ───────────────────────────────────────────────────────────

  Widget _buildReviewsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(FeatherIcons.star, size: 56.sp, color: sand),
          16.height,
          Text('No reviews yet', style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ink)),
          8.height,
          Text('Reviews from your customers will appear here', style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  // ─── About Tab ─────────────────────────────────────────────────────────────

  Widget _buildAboutTab() {
    final specs = _specializations.isNotEmpty ? _specializations.split(',').where((s) => s.trim().isNotEmpty).toList() : <String>[];
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop details
          _sectionTitle('Shop Details'),
          _infoCard([
            _infoRow(FeatherIcons.briefcase, 'Shop Name', _shopName),
            _infoRow(FeatherIcons.mail,      'Email',     _email.isNotEmpty ? _email : '—'),
            _infoRow(FeatherIcons.phone,     'Phone',     _phone.isNotEmpty ? _phone : '—'),
            _infoRow(FeatherIcons.mapPin,    'Location',  _address.isNotEmpty ? _address : '—'),
          ]),
          if (specs.isNotEmpty) ...[
            16.height,
            _sectionTitle('Specialisations'),
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

          // Business Hours
          16.height,
          Row(
            children: [
              Expanded(child: _sectionTitle('Business Hours')),
              GestureDetector(
                onTap: _showEditHours,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(FeatherIcons.edit2, size: 14.sp, color: primary),
                  4.width,
                  Text('Edit', style: GoogleFonts.montserrat(fontSize: 12.sp, color: primary, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          4.height,
          _infoCard(_hours.map((h) => _infoRow(
            FeatherIcons.clock,
            h.day,
            h.isClosed ? 'Closed' : '${h.open} – ${h.close}',
          )).toList()),

          // Policies
          16.height,
          Row(
            children: [
              Expanded(child: _sectionTitle('Policies')),
              GestureDetector(
                onTap: _showEditPolicies,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(FeatherIcons.edit2, size: 14.sp, color: primary),
                  4.width,
                  Text('Edit', style: GoogleFonts.montserrat(fontSize: 12.sp, color: primary, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          4.height,
          _infoCard(_policies.map((p) {
            IconData icon = FeatherIcons.shield;
            if (p.type == 'Returns')  icon = FeatherIcons.refreshCw;
            if (p.type == 'Delivery') icon = FeatherIcons.truck;
            return _infoRow(icon, p.type, p.value);
          }).toList()),

          80.height,
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(t, style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w800, color: ink)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(children: [
          Icon(icon, size: 16.sp, color: textLight),
          12.width,
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontFamily: cinta, fontSize: 11.sp, color: textLight)),
              Text(value, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ink)),
            ]),
          ),
        ]),
      );
}

// ─── Edit Profile Sheet (Stateful implementation for banner/avatar preview & specializations) ───────────────────────

class _EditProfileSheet extends StatefulWidget {
  final String shopName;
  final String email;
  final String phone;
  final String address;
  final String bio;
  final String bannerPath;
  final String avatarPath;
  final String specializations;
  final Function({
    required String shopName,
    required String email,
    required String phone,
    required String address,
    required String bio,
    required String bannerPath,
    required String avatarPath,
    required String specializations,
  }) onSave;

  const _EditProfileSheet({
    Key? key,
    required this.shopName,
    required this.email,
    required this.phone,
    required this.address,
    required this.bio,
    required this.bannerPath,
    required this.avatarPath,
    required this.specializations,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _shopNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _bioCtrl;

  String _bannerPath = '';
  String _avatarPath = '';
  List<String> _selectedSpecs = [];

  final List<String> _allOptions = ['Traditional', 'Corporate', 'Casual', 'Bridal', 'Asoebi', 'Streetwear'];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _shopNameCtrl = TextEditingController(text: widget.shopName);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController(text: widget.phone);
    _addressCtrl = TextEditingController(text: widget.address);
    _bioCtrl = TextEditingController(text: widget.bio);
    _bannerPath = widget.bannerPath;
    _avatarPath = widget.avatarPath;
    _selectedSpecs = widget.specializations
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _bannerPath = picked.path);
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            16.height,
            Text('Edit Shop Profile', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w800, color: ink)),
            20.height,

            // Banner Picture Edit
            Text('SHOP BANNER', style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.8)),
            8.height,
            GestureDetector(
              onTap: _pickBanner,
              child: Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: sand, width: 1.5),
                  borderRadius: BorderRadius.circular(12.r),
                  color: cream,
                  image: _bannerPath.isNotEmpty
                      ? DecorationImage(image: FileImage(File(_bannerPath)), fit: BoxFit.cover)
                      : null,
                ),
                child: _bannerPath.isEmpty
                    ? Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FeatherIcons.image, color: textLight, size: 18.sp),
                            8.width,
                            Text('Upload Banner Image', style: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight)),
                          ],
                        ),
                      )
                    : Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FeatherIcons.camera, color: Colors.white, size: 16.sp),
                            8.width,
                            Text('Change Banner', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
              ),
            ),
            16.height,

            // Profile Picture Edit
            Text('SHOP LOGO / AVATAR', style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.8)),
            8.height,
            Row(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: sand, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 36.r,
                          backgroundColor: sand,
                          backgroundImage: _avatarPath.isNotEmpty ? FileImage(File(_avatarPath)) : null,
                          child: _avatarPath.isEmpty
                              ? Icon(FeatherIcons.user, color: textLight, size: 28.sp)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(color: primary, shape: BoxShape.circle),
                          child: Icon(FeatherIcons.camera, color: Colors.white, size: 10.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                16.width,
                Expanded(
                  child: Text(
                    'Tap the circle avatar to update your shop logo or profile picture.',
                    style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: textLight),
                  ),
                ),
              ],
            ),
            20.height,

            _field('SHOP NAME', _shopNameCtrl, 'Your shop name'),
            16.height,
            _field('EMAIL ADDRESS', _emailCtrl, 'yourshop@email.com', type: TextInputType.emailAddress),
            16.height,
            _field('BIO', _bioCtrl, 'Tell customers about your work', maxLines: 3),
            16.height,
            _field('PHONE', _phoneCtrl, '+234 xxx xxx xxxx', type: TextInputType.phone),
            16.height,
            _field('ADDRESS / LOCATION', _addressCtrl, 'e.g. 12 Bode Thomas St, Surulere'),
            16.height,

            // Specialisations edit section
            Text('SPECIALISATIONS', style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.8)),
            8.height,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _allOptions.map((spec) {
                final selected = _selectedSpecs.contains(spec);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedSpecs.remove(spec);
                      } else {
                        _selectedSpecs.add(spec);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: selected ? primary : cream,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: selected ? primary : sand),
                    ),
                    child: Text(
                      spec,
                      style: GoogleFonts.montserrat(
                        fontSize: 11.sp,
                        color: selected ? Colors.white : textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            24.height,

            _saveBtn(() {
              widget.onSave(
                shopName: _shopNameCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                phone: _phoneCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
                bio: _bioCtrl.text.trim(),
                bannerPath: _bannerPath,
                avatarPath: _avatarPath,
                specializations: _selectedSpecs.join(','),
              );
            }, 'Save Changes'),
            20.height,
          ],
        ),
      ),
    );
  }
}

// ─── Hours Sheet ───────────────────────────────────────────────────────────────

class _HoursSheet extends StatefulWidget {
  final List<BusinessHour> hours;
  final Function(List<BusinessHour>) onSave;
  const _HoursSheet({required this.hours, required this.onSave});

  @override
  State<_HoursSheet> createState() => _HoursSheetState();
}

class _HoursSheetState extends State<_HoursSheet> {
  late List<BusinessHour> _hours;

  @override
  void initState() {
    super.initState();
    _hours = widget.hours.map((h) => BusinessHour(day: h.day, open: h.open, close: h.close, isClosed: h.isClosed)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _handle(),
          16.height,
          Text('Business Hours', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w800, color: ink)),
          4.height,
          Text('Set the hours your shop is open each day.', style: TextStyle(fontFamily: 'Cinta', fontSize: 13.sp, color: textLight)),
          20.height,
          ..._hours.map((h) => _buildDayRow(h)),
          24.height,
          _saveBtn(() { widget.onSave(_hours); Navigator.pop(context); toast('Hours saved'); }, 'Save Hours'),
          20.height,
        ]),
      ),
    );
  }

  Widget _buildDayRow(BusinessHour h) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            child: Text(h.day.substring(0, 3), style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ink)),
          ),
          Switch(
            value: !h.isClosed,
            activeColor: primary,
            onChanged: (v) => setState(() { h.isClosed = !v; }),
          ),
          const Spacer(),
          if (!h.isClosed) ...[
            SizedBox(width: 85.w, child: _timeDropdown(h.open, (v) => setState(() => h.open = v!))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text('–', style: TextStyle(fontFamily: 'Cinta', color: textLight)),
            ),
            SizedBox(width: 85.w, child: _timeDropdown(h.close, (v) => setState(() => h.close = v!))),
          ] else ...[
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Text('Closed', style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: textLight)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeDropdown(String value, ValueChanged<String?> onChanged) {
    final v = _timeOptions.contains(value) ? value : _timeOptions.first;
    return DropdownButtonFormField<String>(
      value: v,
      onChanged: onChanged,
      isDense: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: sand)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: sand)),
      ),
      style: GoogleFonts.montserrat(fontSize: 11.sp, color: ink),
      items: _timeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
    );
  }
}

// ─── Add/Edit Product Form Sheet (CRUD helper) ────────────────────────────────────────────────

class _ProductFormSheet extends StatefulWidget {
  final String vendorType;
  final VendorProduct? product;
  final Function(VendorProduct) onSave;

  const _ProductFormSheet({
    Key? key,
    required this.vendorType,
    this.product,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  final _formKey   = GlobalKey<FormState>();
  final _picker    = ImagePicker();

  List<String> _imagePaths = [];
  String _topCategory = '';
  String? _subCategory;

  List<String> get _topCategories => widget.vendorType == 'seller' ? _sellerCategories : _tailorTopCategories;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _descCtrl.text = p.description;
      _stockCtrl.text = p.stock.toString();
      _imagePaths = List.from(p.imagePaths);
      
      if (p.category.startsWith('Ready-to-Wear: ')) {
        _topCategory = 'Ready-to-Wear';
        _subCategory = p.category.substring('Ready-to-Wear: '.length);
      } else {
        _topCategory = _topCategories.contains(p.category) ? p.category : _topCategories.first;
      }
    } else {
      _topCategory = _topCategories.first;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose(); _descCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  String get _finalCategory {
    if (_topCategory == 'Ready-to-Wear' && _subCategory != null) return 'Ready-to-Wear: $_subCategory';
    return _topCategory;
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) setState(() => _imagePaths = picked.map((x) => x.path).toList());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_topCategory == 'Ready-to-Wear' && _subCategory == null) {
      toast('Please select a Ready-to-Wear style');
      return;
    }
    
    final updated = VendorProduct(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0,
      description: _descCtrl.text.trim(),
      category: _finalCategory,
      stock: int.tryParse(_stockCtrl.text) ?? 1,
      imagePaths: _imagePaths,
      createdAt: widget.product?.createdAt ?? DateTime.now().toIso8601String(),
    );
    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            _handle(),
            16.height,
            Text(isEdit ? 'Edit Listing' : 'Add Listing', style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w800, color: ink)),
            20.height,

            // Photo picker
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 100.h,
                decoration: BoxDecoration(border: Border.all(color: sand, width: 1.5), borderRadius: BorderRadius.circular(12.r), color: cream),
                child: _imagePaths.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(FeatherIcons.image, color: textLight, size: 24.sp),
                        6.height,
                        Text('Tap to add product photos', style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: textLight)),
                      ]))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(8.w),
                        itemCount: _imagePaths.length,
                        separatorBuilder: (_, __) => 8.width,
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(File(_imagePaths[i]), height: 84.h, width: 84.w, fit: BoxFit.cover),
                        ),
                      ),
              ),
            ),
            16.height,

            _formField('PRODUCT NAME', _nameCtrl, 'e.g. Custom Ankara Jumpsuit', validator: (v) => v!.isEmpty ? 'Required' : null),
            16.height,
            Row(children: [
              Expanded(child: _formField('PRICE (₦)', _priceCtrl, '15000', type: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
              12.width,
              Expanded(child: _formField('STOCK / SLOTS', _stockCtrl, '10', type: TextInputType.number)),
            ]),
            16.height,

            // Top-level category
            _label('CATEGORY'),
            8.height,
            Wrap(
              spacing: 8.w, runSpacing: 8.h,
              children: _topCategories.map((cat) => GestureDetector(
                onTap: () => setState(() { _topCategory = cat; _subCategory = null; }),
                child: _chip(cat, _topCategory == cat),
              )).toList(),
            ),

            // Sub-category for Ready-to-Wear
            if (_topCategory == 'Ready-to-Wear') ...[
              16.height,
              _label('STYLE TYPE'),
              8.height,
              Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: _readyToWearSub.map((s) => GestureDetector(
                  onTap: () => setState(() => _subCategory = s),
                  child: _chip(s, _subCategory == s),
                )).toList(),
              ),
            ],

            16.height,
            _formField('DESCRIPTION', _descCtrl, 'Describe your product or service...', maxLines: 3),
            24.height,
            _saveBtn(_submit, isEdit ? 'Save Changes' : 'Add to Shop'),
            20.height,
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? primary : cream,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? primary : sand),
        ),
        child: Text(label, style: GoogleFonts.montserrat(fontSize: 11.sp, color: selected ? Colors.white : textLight, fontWeight: FontWeight.w600)),
      );

  Widget _label(String t) => Text(t, style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.8));

  Widget _formField(String label, TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType? type, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      8.height,
      TextFormField(
        controller: ctrl, maxLines: maxLines, keyboardType: type, validator: validator,
        style: GoogleFonts.montserrat(fontSize: 14.sp, color: ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Cinta', color: textLight),
          filled: true, fillColor: cream,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          border:         OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: sand)),
          enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: sand)),
          focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: primary, width: 1.5)),
          errorBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: primary)),
        ),
      ),
    ]);
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────────

Widget _handle() => Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(4))));

Widget _saveBtn(VoidCallback onTap, String label) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );

Widget _field(String label, TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType? type}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.8)),
    SizedBox(height: 8),
    TextFormField(
      controller: ctrl, maxLines: maxLines, keyboardType: type,
      style: GoogleFonts.montserrat(fontSize: 14, color: ink),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(fontFamily: 'Cinta', color: textLight),
        filled: true, fillColor: cream,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: sand)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: sand)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
      ),
    ),
  ]);
}
