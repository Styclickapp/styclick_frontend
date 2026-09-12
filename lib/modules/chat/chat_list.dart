import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/modules/chat/chat_detail.dart';
import 'package:stylclick/core/services/chat_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    ChatService.instance.conversationsNotifier.addListener(_onConversationsChanged);
    ChatService.instance.syncFromBackend();
  }

  @override
  void dispose() {
    ChatService.instance.conversationsNotifier.removeListener(_onConversationsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onConversationsChanged() {
    if (mounted) setState(() {});
  }

  List<ConversationModel> get _filteredConversations {
    final all = ChatService.instance.conversations.values.toList();
    
    // Sort so conversations with recent messages appear first
    all.sort((a, b) {
      final timeA = a.messages.isNotEmpty ? a.messages.last['time'] : '';
      final timeB = b.messages.isNotEmpty ? b.messages.last['time'] : '';
      return timeB.compareTo(timeA);
    });

    if (_searchQuery.isEmpty) return all;
    return all.where((c) {
      return c.vendorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.productName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.messages.any((m) => (m['text'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredConversations;
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
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
              color: cream,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Image.asset(menuIcon, height: 24.h, width: 24.w, color: ink),
                  ),
                  const Spacer(),
                  Text(
                    'Messages',
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
                    onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    child: Image.asset(notificationIcon, height: 24.h, width: 24.w, color: ink),
                  ),
                ],
              ),
            ),
            12.height,

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: sand),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: GoogleFonts.montserrat(fontSize: 13.sp, color: textLight.withOpacity(0.5)),
                    prefixIcon: Icon(FeatherIcons.search, size: 18.sp, color: textLight),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),
            16.height,

            // Conversations list
            Expanded(
              child: list.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 17.w),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => Divider(color: sand.withOpacity(0.6), height: 1),
                      itemBuilder: (context, index) {
                        final convo = list[index];
                        return _buildConversationTile(convo);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel convo) {
    final bool hasUnread = convo.unreadCount > 0;
    final lastMsg = convo.messages.isNotEmpty ? convo.messages.last['text'] : '';
    final timeStr = convo.messages.isNotEmpty ? convo.messages.last['time'] : '';
    final avatarUrl = convo.vendorAvatar;
    final hasImage = avatarUrl != null && avatarUrl.isNotEmpty;

    return InkWell(
      onTap: () {
        ChatDetailPage(
          vendorName: convo.vendorName,
          vendorType: convo.vendorType,
          productName: convo.productName,
          productPrice: convo.productPrice,
          productImage: convo.productImage,
          vendorAvatar: convo.vendorAvatar,
        ).launch(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 52.w,
                  height: 52.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: hasUnread ? primary.withOpacity(0.3) : sand, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26.r),
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
                                convo.vendorName.isNotEmpty ? convo.vendorName[0].toUpperCase() : 'S',
                                style: TextStyle(fontFamily: 'Cinta', color: primary, fontWeight: FontWeight.bold, fontSize: 18.sp),
                              ),
                            ),
                          ),
                  ),
                ),
                if (convo.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
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
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          convo.vendorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cinta',
                            fontSize: 15.sp,
                            color: ink,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          color: hasUnread ? primary : textLight,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  4.height,
                  // Product tag
                  if (convo.productName != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        convo.productName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(fontSize: 10.sp, color: primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    4.height,
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 12.sp,
                            color: hasUnread ? ink : textLight,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                          decoration: const BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${convo.unreadCount}',
                            style: GoogleFonts.montserrat(fontSize: 10.sp, color: white, fontWeight: FontWeight.w700),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(FeatherIcons.messageSquare, size: 48.sp, color: primary.withOpacity(0.5)),
            ),
            24.height,
            Text(
              'No conversations yet',
              style: TextStyle(fontFamily: 'Cinta', fontSize: 18.sp, color: ink, fontWeight: FontWeight.w700),
            ),
            8.height,
            Text(
              'Start chatting with vendors by tapping the chat icon on any product or tailor listing.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13.sp, color: textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
