import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/modules/details.dart';
import 'package:stylclick/modules/select-tailor/tailor_details.dart';
import 'package:stylclick/modules/buy-fabrics/buy_fabrics_details.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylclick/core/services/chat_service.dart';

class ChatDetailPage extends StatefulWidget {
  final String vendorName;
  final String vendorType; // 'tailor', 'seller', 'rider'
  final String? productName;
  final String? productPrice;
  final String? productImage;
  final String? vendorAvatar;

  const ChatDetailPage({
    Key? key,
    required this.vendorName,
    this.vendorType = 'seller',
    this.productName,
    this.productPrice,
    this.productImage,
    this.vendorAvatar,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ChatService.instance.conversationsNotifier.addListener(_onMessagesUpdated);
  }

  @override
  void dispose() {
    ChatService.instance.conversationsNotifier.removeListener(_onMessagesUpdated);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessagesUpdated() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ChatService.instance.sendMessage(
      widget.vendorName,
      {
        'text': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      },
      widget.vendorType,
    );
    _messageController.clear();
    _scrollToBottom();
  }

  void _showMakeOfferSheet() {
    final offerController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: sand,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                20.height,
                Text(
                  'Make an Offer',
                  style: TextStyle(
                    fontFamily: 'Cinta',
                    fontSize: 20.sp,
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                8.height,
                if (widget.productName != null)
                  Text(
                    'For: ${widget.productName}',
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: textLight),
                  ),
                if (widget.productPrice != null) ...[
                  4.height,
                  Text(
                    'Listed price: ${widget.productPrice}',
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: textLight, fontWeight: FontWeight.w600),
                  ),
                ],
                20.height,
                CustomTextField(
                  controller: offerController,
                  label: 'Your Offer (NGN)',
                  labelColor: ink,
                  hintText: 'e.g. 10,000',
                  hintTextColor: textLight.withOpacity(0.4),
                  textInputType: TextInputType.number,
                ),
                12.height,
                CustomTextField(
                  label: 'Note (Optional)',
                  labelColor: ink,
                  hintText: 'Add a message with your offer...',
                  hintTextColor: textLight.withOpacity(0.4),
                  maxLines: 3,
                ),
                24.height,
                InkWell(
                  onTap: () {
                    final price = offerController.text.trim();
                    if (price.isNotEmpty) {
                      Navigator.pop(context);
                      ChatService.instance.sendMessage(
                        widget.vendorName,
                        {
                          'text': '💰 Offer: NGN $price\nfor ${widget.productName ?? 'this item'}',
                          'isMe': true,
                          'isOffer': true,
                          'time': TimeOfDay.now().format(context),
                        },
                        widget.vendorType,
                      );
                      _scrollToBottom();
                    }
                  },
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      gradient: const LinearGradient(colors: [primary, primaryGradient]),
                    ),
                    child: Center(
                      child: Text(
                        'Send Offer',
                        style: TextStyle(fontFamily: cinta, fontSize: 15.sp, color: white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                20.height,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ChatService.instance.getMessages(
      widget.vendorName,
      widget.vendorType,
      widget.productName,
      productPrice: widget.productPrice,
      productImage: widget.productImage,
      vendorAvatar: widget.vendorAvatar,
    );
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(),
            // Product card (if applicable)
            if (widget.productName != null) _buildProductCard(),
            // Safety banner
            _buildSafetyBanner(),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final showDateHeader = index == 0;
                  return Column(
                    children: [
                      if (showDateHeader) _buildDateHeader('Today'),
                      _buildMessageBubble(msg),
                    ],
                  );
                },
              ),
            ),
            // Input bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  void _openVendorProfile() {
    if (widget.vendorType == 'tailor' || widget.vendorType == 'designer') {
      TailorDetails(businessName: widget.vendorName).launch(context);
    } else {
      FabricSellerDetails(businessName: widget.vendorName).launch(context);
    }
  }

  void _openProductPost() {
    CategoryDetails(
      name: widget.productName ?? 'Product Item',
      storeName: widget.vendorName,
      imagePaths: widget.productImage != null ? [widget.productImage!] : [],
    ).launch(context);
  }

  Widget _buildAppBar() {
    final avatarUrl = widget.vendorAvatar;
    final hasImage = avatarUrl != null && avatarUrl.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cream,
        border: Border(bottom: BorderSide(color: sand, width: 0.8)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => pop(context),
            child: Icon(FeatherIcons.arrowLeft, color: ink, size: 22.sp),
          ),
          14.width,
          // Vendor avatar & info - clicking opens vendor shop/profile page
          Expanded(
            child: InkWell(
              onTap: _openVendorProfile,
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: sand, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: hasImage
                              ? (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')
                                  ? CachedNetworkImage(
                                      imageUrl: avatarUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: sand),
                                      errorWidget: (_, __, ___) => Image.asset(defaultUserImage, fit: BoxFit.cover),
                                    )
                                  : (avatarUrl.startsWith('assets/')
                                      ? Image.asset(avatarUrl, fit: BoxFit.cover)
                                      : (File(avatarUrl).existsSync()
                                          ? Image.file(File(avatarUrl), fit: BoxFit.cover)
                                          : Image.asset(defaultUserImage, fit: BoxFit.cover))))
                              : Container(
                                  color: primary.withOpacity(0.1),
                                  child: Center(
                                    child: Text(
                                      widget.vendorName.isNotEmpty ? widget.vendorName[0].toUpperCase() : 'S',
                                      style: TextStyle(fontFamily: 'Cinta', color: primary, fontWeight: FontWeight.bold, fontSize: 16.sp),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: successColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: cream, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: 'Cinta', fontSize: 16.sp, color: ink, fontWeight: FontWeight.w700),
                        ),
                        2.height,
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                widget.vendorType == 'tailor' || widget.vendorType == 'designer' ? 'Tailor' : widget.vendorType == 'rider' ? 'Rider' : 'Seller',
                                style: GoogleFonts.montserrat(fontSize: 10.sp, color: primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            8.width,
                            Text(
                              'Online',
                              style: GoogleFonts.montserrat(fontSize: 11.sp, color: successColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _showMakeOfferSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FeatherIcons.dollarSign, size: 14.sp, color: primary),
                  4.width,
                  Text(
                    'Offer',
                    style: GoogleFonts.montserrat(fontSize: 11.sp, color: primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return InkWell(
      onTap: _openProductPost,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 17.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: sand),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: widget.productImage != null && widget.productImage!.isNotEmpty
                  ? (widget.productImage!.startsWith('http://') || widget.productImage!.startsWith('https://')
                      ? CachedNetworkImage(
                          imageUrl: widget.productImage!,
                          width: 50.w,
                          height: 50.h,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: sand),
                          errorWidget: (_, __, ___) => Container(
                            color: primary.withOpacity(0.08),
                            child: Icon(
                              widget.vendorType == 'tailor' || widget.vendorType == 'designer' ? FeatherIcons.scissors : FeatherIcons.shoppingBag,
                              color: primary,
                              size: 22.sp,
                            ),
                          ),
                        )
                      : (widget.productImage!.startsWith('assets/')
                          ? Image.asset(
                              widget.productImage!,
                              width: 50.w,
                              height: 50.h,
                              fit: BoxFit.cover,
                            )
                          : (File(widget.productImage!).existsSync()
                              ? Image.file(
                                  File(widget.productImage!),
                                  width: 50.w,
                                  height: 50.h,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50.w,
                                  height: 50.h,
                                  color: primary.withOpacity(0.08),
                                  child: Icon(
                                    widget.vendorType == 'tailor' || widget.vendorType == 'designer' ? FeatherIcons.scissors : FeatherIcons.shoppingBag,
                                    color: primary,
                                    size: 22.sp,
                                  ),
                                ))))
                  : Container(
                      width: 50.w,
                      height: 50.h,
                      color: primary.withOpacity(0.08),
                      child: Icon(
                        widget.vendorType == 'tailor' || widget.vendorType == 'designer' ? FeatherIcons.scissors : FeatherIcons.shoppingBag,
                        color: primary,
                        size: 22.sp,
                      ),
                    ),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700),
                  ),
                  4.height,
                  Text(
                    widget.productPrice ?? '',
                    style: GoogleFonts.montserrat(fontSize: 13.sp, color: primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Icon(FeatherIcons.chevronRight, color: textLight, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.amber.shade200, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(FeatherIcons.shield, color: Colors.amber.shade800, size: 16.sp),
          8.width,
          Expanded(
            child: Text(
              'Safety Warning: Do not pay in advance. Meet in public places to inspect items before purchase.',
              style: GoogleFonts.montserrat(
                fontSize: 10.sp,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: sand.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            date,
            style: GoogleFonts.montserrat(fontSize: 11.sp, color: textLight, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    final bool isOffer = msg['isOffer'] ?? false;

    if (isOffer) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Colors.amber.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: ink.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(FeatherIcons.tag, color: Colors.amber.shade800, size: 16.sp),
                      8.width,
                      Text(
                        'Negotiated Offer',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  10.height,
                  Text(
                    msg['text'],
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 14.sp,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'PENDING',
                          style: GoogleFonts.montserrat(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: white,
                          ),
                        ),
                      ),
                      Text(
                        msg['time'],
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isMe ? primary : white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: isMe ? Radius.circular(18.r) : Radius.circular(4.r),
                bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(18.r),
              ),
              border: isMe ? null : Border.all(color: sand),
              boxShadow: [
                BoxShadow(
                  color: ink.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg['text'],
                  style: TextStyle(
                    fontFamily: 'Cinta',
                    fontSize: 14.sp,
                    color: isMe ? white : ink,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                6.height,
                Text(
                  msg['time'],
                  style: GoogleFonts.montserrat(
                    fontSize: 10.sp,
                    color: isMe ? white.withOpacity(0.7) : textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cream,
        border: Border(top: BorderSide(color: sand, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                  border: Border.all(color: sand),
                ),
                child: Icon(FeatherIcons.image, size: 20.sp, color: textLight),
              ),
            ),
            10.width,
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: sand),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.montserrat(fontSize: 13.sp, color: textLight.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  ),
                ),
              ),
            ),
            10.width,
            // Send button
            InkWell(
              onTap: _sendMessage,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(FeatherIcons.send, size: 18.sp, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
