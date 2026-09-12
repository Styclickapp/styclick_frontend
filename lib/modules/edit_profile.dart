import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/core/services/profile_service.dart';
import 'package:stylclick/modules/success_page.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/wallet/wallet.dart';
import 'package:stylclick/modules/wallet/transaction_history.dart';
import 'package:stylclick/modules/account.dart';
import 'package:stylclick/modules/order/saved_order.dart';
import 'package:stylclick/modules/vendor/index.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/shared/widgets/app_drawer.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/images.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  String? selectedState = 'Lagos';
  List<String> states = ['Abuja', 'Lagos', 'Kano', 'Oyo', 'Rivers', 'Enugu', 'Delta', 'Kaduna', 'Edo', 'Ogun'];

  // Profile Picture state
  String? _profilePicPath;
  final ImagePicker _picker = ImagePicker();

  // Text controllers bound to the editable form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = '${getStringAsync('fName')} ${getStringAsync('lName')}'.trim();
    _emailController.text = getStringAsync('email');
    _phoneController.text = getStringAsync('phone');
    _addressController.text = getStringAsync('address');
    _loadProfileData();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_picture', image.path);
        setValue('profile_picture', image.path);
        setState(() {
          _profilePicPath = image.path;
        });
        toast('Profile picture updated!');
      }
    } catch (e) {
      log('[EDIT_PROFILE] Error picking image: $e');
    }
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final fName = prefs.getString('fName') ?? getStringAsync('fName');
    final lName = prefs.getString('lName') ?? getStringAsync('lName');
    final email = prefs.getString('email') ?? getStringAsync('email');
    final phone = prefs.getString('phone') ?? getStringAsync('phone');
    final address = prefs.getString('address') ?? getStringAsync('address');
    final state = prefs.getString('state') ?? getStringAsync('state');
    final pic = prefs.getString('profile_picture') ?? getStringAsync('profile_picture');

    setState(() {
      if (pic.isNotEmpty) _profilePicPath = pic;
      final full = '$fName $lName'.trim();
      if (full.isNotEmpty) _fullNameController.text = full;
      if (email.isNotEmpty) _emailController.text = email;
      if (phone.isNotEmpty) _phoneController.text = phone;
      if (address.isNotEmpty) _addressController.text = address;
      if (state.isNotEmpty && states.contains(state)) selectedState = state;
    });

    try {
      final res = await ProfileService.instance.fetchProfile();
      if (res.status == true && res.data != null) {
        final pData = res.data!['data'] ?? res.data!['user'] ?? res.data!;
        if (pData is Map) {
          final apiFn = pData['first_name'] ?? pData['firstname'] ?? pData['fName'] ?? '';
          final apiLn = pData['last_name'] ?? pData['lastname'] ?? pData['lName'] ?? '';
          final apiEm = pData['email'] ?? '';
          final apiPh = pData['phone'] ?? pData['phone_number'] ?? '';
          final apiAddr = pData['address'] ?? '';
          final apiState = pData['state']?.toString() ?? '';

          setState(() {
            final apiFull = '$apiFn $apiLn'.trim();
            if (apiFull.isNotEmpty) _fullNameController.text = apiFull;
            if (apiEm.isNotEmpty) _emailController.text = apiEm;
            if (apiPh.isNotEmpty) _phoneController.text = apiPh;
            if (apiAddr.isNotEmpty) _addressController.text = apiAddr;
            if (apiState.isNotEmpty && states.contains(apiState)) selectedState = apiState;
          });
        }
      }
    } catch (e) {
      log('[EDIT_PROFILE] Remote profile sync log: $e');
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
                      child: Icon(
                        FeatherIcons.arrowLeft,
                        color: ink,
                        size: 24.sp,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Edit Profile',
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
              40.height,
              // Avatar Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primary.withOpacity(0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60.r,
                          backgroundColor: white,
                          backgroundImage: (_profilePicPath != null && _profilePicPath!.isNotEmpty && File(_profilePicPath!).existsSync())
                              ? FileImage(File(_profilePicPath!)) as ImageProvider
                              : const AssetImage(defaultUserImage),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 3),
                          ),
                          child: Icon(FeatherIcons.camera, color: white, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              32.height,
              // Form
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal Information'),
                    20.height,
                    _buildTextField('Full Name', 'Enter full name', FeatherIcons.user, controller: _fullNameController),
                    16.height,
                    _buildTextField('Email Address', 'Enter email address', FeatherIcons.mail, controller: _emailController),
                    16.height,
                    _buildTextField('Phone Number', 'Enter phone number', FeatherIcons.phone, controller: _phoneController),
                    16.height,
                    _buildDropdown('State', selectedState, states, (v) => setState(() => selectedState = v)),
                    16.height,
                    _buildTextField('Address', 'Enter address', FeatherIcons.mapPin, controller: _addressController),
                    40.height,
                    // Save Button
                    InkWell(
                      onTap: _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);
                              log('[PROFILE] Saving profile update...');
                              final res = await ProfileService.instance.updateProfile(
                                fullName: _fullNameController.text.trim(),
                                address: _addressController.text.trim(),
                                city: '',
                                state: selectedState ?? '',
                                country: 'Nigeria',
                              );
                              if (mounted) {
                                setState(() => _isSaving = false);
                                if (res.status == true) {
                                  final prefs = await SharedPreferences.getInstance();
                                  final parts = _fullNameController.text.trim().split(' ');
                                  final firstName = parts.isNotEmpty ? parts.first : '';
                                  final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
                                  final email = _emailController.text.trim();
                                  final phone = _phoneController.text.trim();
                                  final address = _addressController.text.trim();
                                  final state = selectedState ?? '';

                                  await prefs.setString('fName', firstName);
                                  await prefs.setString('lName', lastName);
                                  await prefs.setString('email', email);
                                  await prefs.setString('phone', phone);
                                  await prefs.setString('address', address);
                                  await prefs.setString('state', state);

                                  setValue('fName', firstName);
                                  setValue('lName', lastName);
                                  setValue('email', email);
                                  setValue('phone', phone);
                                  setValue('address', address);
                                  setValue('state', state);

                                  const SuccessPage(message: 'Your profile has been successfully\nupdated').launch(context);
                                } else {
                                  showMessage(context, res.message ?? 'Failed to save profile. Please try again.');
                                }
                              }
                            },
                      child: Container(
                        height: 56.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: const LinearGradient(
                            colors: [primary, primaryGradient],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? const CircularProgressIndicator(color: white)
                              : Text(
                                  'Save Changes',
                                  style: GoogleFonts.montserrat(
                                    color: white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    40.height,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Cinta',
        fontSize: 12.sp,
        color: textLight,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, {TextEditingController? controller}) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hint,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'Cinta', 
            fontSize: 14.sp,
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.height,
        Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: sand),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: Icon(FeatherIcons.chevronDown, color: sand, size: 16.sp),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontFamily: 'Cinta', fontSize: 14.sp, color: ink),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsLink(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: sand),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 20.sp),
            16.width,
            Text(
              title,
              style: TextStyle(fontFamily: 'Cinta', 
                fontSize: 15.sp,
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: sand, size: 14.sp),
          ],
        ),
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
