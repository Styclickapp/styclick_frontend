import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/modules/details.dart';
import 'package:stylclick/modules/buy-fabrics/buy_fabrics_details.dart';
import 'package:stylclick/modules/select-tailor/tailor_details.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/core/services/cart_service.dart';
import 'checkout.dart';

class OrderSummary extends StatefulWidget {
  const OrderSummary({Key? key}) : super(key: key);

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

typedef CartPage = OrderSummary;

class _OrderSummaryState extends State<OrderSummary> {
  final List<CartItemModel> _savedForLater = [];

  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;
  double _discountPercent = 0.0;
  bool _isSelectionMode = false;

  List<CartItemModel> get _cartItems => CartService.instance.items;

  @override
  void initState() {
    super.initState();
    CartService.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    CartService.instance.itemsNotifier.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService.instance.itemsNotifier.removeListener(_onCartChanged);
    _promoController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  double get _selectedSubtotal {
    return _cartItems
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _deliveryFee {
    return _selectedSubtotal > 0 ? 2500.0 : 0.0;
  }

  double get _discountAmount {
    return _selectedSubtotal * _discountPercent;
  }

  double get _grandTotal {
    final total = _selectedSubtotal + _deliveryFee - _discountAmount;
    return total > 0 ? total : 0.0;
  }

  bool get _isAllSelected {
    return _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);
  }

  void _toggleSelectAll(bool? val) {
    CartService.instance.toggleSelectAll(val ?? false);
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'STYCLICK10' || code == 'DISCOUNT10') {
      setState(() {
        _isPromoApplied = true;
        _discountPercent = 0.10;
      });
      toast('Promo code applied! 10% discount added.');
    } else {
      toast('Invalid promo code. Try STYCLICK10');
    }
  }

  void _openProductDetails(CartItemModel item) {
    CategoryDetails(
      name: item.name,
      price: item.price,
      storeName: item.storeName,
      imagePaths: [item.image],
      vendorType: item.vendorType,
    ).launch(context);
  }

  void _openVendorProfile(CartItemModel item) {
    if (item.vendorType == 'tailor' || item.vendorType == 'designer' || item.storeName.toLowerCase().contains('stitches')) {
      TailorDetails(businessName: item.storeName).launch(context);
    } else {
      FabricSellerDetails(businessName: item.storeName).launch(context);
    }
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Clear Cart',
          style: TextStyle(fontFamily: cinta, fontSize: 18.sp, color: ink, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(fontFamily: cinta, fontSize: 14.sp, color: textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontFamily: cinta, fontSize: 14.sp, color: textLight, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                CartService.instance.clearCart();
                _isSelectionMode = false;
              });
              toast('Cart cleared');
            },
            child: Text('Clear All', style: TextStyle(fontFamily: cinta, fontSize: 14.sp, color: primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemoveSheet(CartItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.r),
      ),
      builder: (BuildContext ctx) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove from Cart',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: cinta,
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              8.height,
              Text(
                'Do you want to remove "${item.name}" from your cart?',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: cinta,
                  color: textLight,
                ),
              ),
              20.height,
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    CartService.instance.removeFromCart(item.id);
                    _savedForLater.add(item);
                  });
                  toast('Item moved to Saved for Later');
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: sand),
                  ),
                  child: Center(
                    child: Text(
                      'Save for Later',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 15.sp,
                        color: ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              12.height,
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    CartService.instance.removeFromCart(item.id);
                  });
                  toast('Item removed from cart');
                },
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primaryGradient],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Remove Product',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 15.sp,
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              24.height,
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          elevation: 0,
          backgroundColor: cream,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Row(
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
                    child: Icon(FeatherIcons.arrowLeft, color: ink, size: 20.sp),
                  ),
                ),
                16.width,
                Text(
                  'Cart',
                  style: TextStyle(
                    fontFamily: 'Cinta',
                    color: ink,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isSelectionMode) ...[
                  8.width,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${_cartItems.where((i) => i.isSelected).length} Selected',
                      style: TextStyle(
                        fontFamily: cinta,
                        color: primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (_cartItems.isNotEmpty)
                  if (_isSelectionMode)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = false;
                        });
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.montserrat(
                          color: ink,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _showClearAllConfirmation,
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.montserrat(
                          color: primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      body: _cartItems.isEmpty && _savedForLater.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select All Header Bar
                  if (_cartItems.isNotEmpty && _isSelectionMode)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isAllSelected,
                            activeColor: primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            onChanged: _toggleSelectAll,
                          ),
                          Text(
                            'Select All (${_cartItems.length} items)',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_cartItems.isNotEmpty && _isSelectionMode) 16.height,

                  // Active Cart Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => 12.height,
                    itemBuilder: (_, index) {
                      final item = _cartItems[index];
                      return _buildCartItemCard(item);
                    },
                  ),

                  24.height,

                  // Promo Code / Voucher Card
                  if (_cartItems.isNotEmpty) ...[
                    Text(
                      'Voucher & Promo Code',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 14.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.height,
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: sand),
                      ),
                      child: Row(
                        children: [
                          Icon(FeatherIcons.tag, color: primary, size: 18.sp),
                          12.width,
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              decoration: InputDecoration(
                                hintText: 'Enter promo code (e.g. STYCLICK10)',
                                hintStyle: TextStyle(fontFamily: cinta, fontSize: 13.sp, color: textLight),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _applyPromoCode,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: _isPromoApplied ? successColor : primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                _isPromoApplied ? 'Applied' : 'Apply',
                                style: GoogleFonts.montserrat(
                                  color: white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    24.height,
                  ],

                  // Saved for Later Section
                  if (_savedForLater.isNotEmpty) ...[
                    Text(
                      'Saved for Later (${_savedForLater.length})',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    12.height,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedForLater.length,
                      separatorBuilder: (_, __) => 12.height,
                      itemBuilder: (_, index) {
                        final item = _savedForLater[index];
                        return _buildSavedForLaterCard(item);
                      },
                    ),
                    24.height,
                  ],

                  // Order Summary Price Breakdown
                  if (_cartItems.isNotEmpty) ...[
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 16.sp,
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    12.height,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: sand),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Selected Items Subtotal', 'NGN ${formatPriceNoDecimal(_selectedSubtotal.toInt())}'),
                          12.height,
                          _buildSummaryRow('Estimated Delivery Fee', 'NGN ${formatPriceNoDecimal(_deliveryFee.toInt())}'),
                          if (_isPromoApplied) ...[
                            12.height,
                            _buildSummaryRow('Promo Discount (10%)', '- NGN ${formatPriceNoDecimal(_discountAmount.toInt())}', color: successColor),
                          ],
                          12.height,
                          Divider(color: sand),
                          12.height,
                          _buildSummaryRow(
                            'Total',
                            'NGN ${formatPriceNoDecimal(_grandTotal.toInt())}',
                            isBold: true,
                            fontSize: 16.sp,
                          ),
                        ],
                      ),
                    ),
                    100.height,
                  ],
                ],
              ),
            ),
      bottomNavigationBar: _cartItems.isEmpty || _selectedSubtotal == 0
          ? null
          : Container(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h, bottom: 32.h),
              decoration: BoxDecoration(
                color: white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pay',
                          style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: textLight),
                        ),
                        Text(
                          'NGN ${formatPriceNoDecimal(_grandTotal.toInt())}',
                          style: GoogleFonts.montserrat(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        const CheckoutPage().launch(context);
                      },
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, primaryGradient],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Checkout',
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
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItemCard(CartItemModel item) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (!_isSelectionMode) {
            _isSelectionMode = true;
          }
          item.isSelected = !item.isSelected;
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            item.isSelected = !item.isSelected;
          });
        } else {
          _openProductDetails(item);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: item.isSelected && _isSelectionMode ? primary.withOpacity(0.02) : white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: item.isSelected && _isSelectionMode ? primary.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Selection Checkbox (Visible in selection mode)
            if (_isSelectionMode)
              Checkbox(
                value: item.isSelected,
                activeColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                onChanged: (val) {
                  setState(() {
                    item.isSelected = val ?? false;
                  });
                },
              ),
            // Product Image (Clickable if not in selection mode)
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: item.image.startsWith('http://') || item.image.startsWith('https://')
                  ? CachedNetworkImage(
                      imageUrl: item.image,
                      height: 90.h,
                      width: 80.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 90.h, width: 80.w, color: sand),
                      errorWidget: (_, __, ___) => Container(height: 90.h, width: 80.w, color: sand, child: Icon(FeatherIcons.image, color: textLight)),
                    )
                  : (item.image.startsWith('assets/')
                      ? Image.asset(
                          item.image,
                          height: 90.h,
                          width: 80.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 90.h,
                            width: 80.w,
                            color: sand,
                            child: Icon(FeatherIcons.image, color: textLight),
                          ),
                        )
                      : (File(item.image).existsSync()
                          ? Image.file(
                              File(item.image),
                              height: 90.h,
                              width: 80.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 90.h,
                                width: 80.w,
                                color: sand,
                                child: Icon(FeatherIcons.image, color: textLight),
                              ),
                            )
                          : Image.asset(
                              femaleAsoebi,
                              height: 90.h,
                              width: 80.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 90.h,
                                width: 80.w,
                                color: sand,
                                child: Icon(FeatherIcons.image, color: textLight),
                              ),
                            ))),
            ),
            16.width,
            // Product Details & Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 15.sp,
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.height,
                // Vendor Name (Clickable)
                GestureDetector(
                  onTap: () => _openVendorProfile(item),
                  child: Row(
                    children: [
                      Text(
                        item.storeName,
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 12.sp,
                          color: textLight,
                        ),
                      ),
                      4.width,
                      Icon(Icons.arrow_forward_ios, size: 10.sp, color: textLight),
                    ],
                  ),
                ),
                6.height,
                Text(
                  'Size: ${item.size}',
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 11.sp,
                    color: textLight,
                  ),
                ),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NGN ${formatPriceNoDecimal((item.price * item.quantity).toInt())}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                    // Quantity Counter
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (item.quantity > 1) {
                              CartService.instance.updateQuantity(item.id, item.quantity - 1);
                            } else {
                              _showRemoveSheet(item);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: cream,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: sand),
                            ),
                            child: Icon(Icons.remove, size: 14.sp, color: ink),
                          ),
                        ),
                        10.width,
                        Text(
                          '${item.quantity}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                        10.width,
                        GestureDetector(
                          onTap: () {
                            CartService.instance.updateQuantity(item.id, item.quantity + 1);
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: cream,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: sand),
                            ),
                            child: Icon(Icons.add, size: 14.sp, color: ink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                12.height,
                // Remove / Save Action
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _showRemoveSheet(item),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FeatherIcons.trash2, size: 12.sp, color: primary),
                        4.width,
                        Text(
                          'Remove',
                          style: TextStyle(
                            fontFamily: cinta,
                            fontSize: 12.sp,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

Widget _buildSavedForLaterCard(CartItemModel item) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: sand),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(item.image, height: 70.h, width: 70.w, fit: BoxFit.cover),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: cinta, fontSize: 13.sp, fontWeight: FontWeight.w700, color: ink)),
                4.height,
                Text('NGN ${formatPriceNoDecimal(item.price.toInt())}', style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w800, color: primary)),
              ],
            ),
          ),
          12.width,
          InkWell(
            onTap: () {
              setState(() {
                _savedForLater.removeWhere((i) => i.id == item.id);
                CartService.instance.addToCart(item);
              });
              toast('Moved to Cart');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Move to Cart',
                style: GoogleFonts.montserrat(fontSize: 11.sp, color: primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, double? fontSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: cinta,
            fontSize: fontSize ?? 13.sp,
            color: isBold ? ink : textLight,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: fontSize ?? 13.sp,
            color: color ?? (isBold ? primary : ink),
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: white,
                shape: BoxShape.circle,
                border: Border.all(color: sand),
              ),
              child: Icon(FeatherIcons.shoppingBag, size: 64.sp, color: primary),
            ),
            24.height,
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontFamily: cinta,
                fontSize: 20.sp,
                color: ink,
                fontWeight: FontWeight.bold,
              ),
            ),
            8.height,
            Text(
              'Explore our collection of fabrics and tailor designs to start shopping.',
              style: TextStyle(
                fontFamily: cinta,
                fontSize: 14.sp,
                color: textLight,
              ),
              textAlign: TextAlign.center,
            ),
            32.height,
            InkWell(
              onTap: () {
                currentIndex = 1;
                const Nav().launch(context, isNewTask: true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const LinearGradient(
                    colors: [primary, primaryGradient],
                  ),
                ),
                child: Text(
                  'Start Shopping',
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 16.sp,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
