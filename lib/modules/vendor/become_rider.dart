import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylclick/core/services/vendor_service.dart';
import 'package:stylclick/modules/success_page.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/shared/utils/validator.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';

class BecomeRider extends StatefulWidget {
  const BecomeRider({Key? key}) : super(key: key);

  @override
  State<BecomeRider> createState() => _BecomeRiderState();
}

class _BecomeRiderState extends State<BecomeRider> {
  int _currentStep = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _vehicleMake = TextEditingController();
  final TextEditingController _plateNumber = TextEditingController();

  String _vehicleType = 'Motorcycle';

  // Image Upload Paths
  String? _licenseImagePath;
  String? _insuranceImagePath;
  String? _ninImagePath;
  final _imagePicker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  void _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final fName = prefs.getString('fName') ?? getStringAsync('fName');
    final lName = prefs.getString('lName') ?? getStringAsync('lName');
    final prefEmail = prefs.getString('email') ?? getStringAsync('email');
    final prefPhone = prefs.getString('phone') ?? getStringAsync('phone');
    final prefAddress = prefs.getString('address') ?? getStringAsync('address');

    setState(() {
      final full = '$fName $lName'.trim();
      if (full.isNotEmpty) _fullName.text = full;
      if (prefEmail.isNotEmpty) _email.text = prefEmail;
      if (prefPhone.isNotEmpty) _phone.text = prefPhone;
      if (prefAddress.isNotEmpty) _address.text = prefAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Column(
          children: [
            20.height,
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => pop(context),
                    child: Icon(FeatherIcons.arrowLeft, color: ink, size: 24.sp),
                  ),
                  20.width,
                  Text(
                    'Rider Registration',
                    style: TextStyle(
                      fontFamily: 'Cinta',
                      fontSize: 22.sp,
                      color: primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
            32.height,
            // Progress Indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: Row(
                children: [0, 1, 2].map((i) {
                  bool isActive = _currentStep >= i;
                  return Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 8.w),
                      decoration: BoxDecoration(
                        color: isActive ? primary : sand,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            24.height,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildPersonalInfo(),
                      if (_currentStep == 1) _buildVehicleInfo(),
                      if (_currentStep == 2) _buildVerification(),
                      60.height,
                    ],
                  ),
                ),
              ),
            ),
            // Navigation Buttons
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PERSONAL DETAILS', 'Create your dispatch profile.'),
        24.height,
        _buildTextField(
          'Full Name',
          _fullName,
          FeatherIcons.user,
          validator: (v) => v.validate().isEmpty ? 'Full Name is required' : null,
        ),
        16.height,
        _buildTextField(
          'Email Address',
          _email,
          FeatherIcons.mail,
          type: TextInputType.emailAddress,
          validator: EmailValidator.validateEmail,
        ),
        16.height,
        _buildTextField(
          'Phone Number',
          _phone,
          FeatherIcons.phone,
          type: TextInputType.phone,
          validator: PhoneValidator.validatePhone,
        ),
        16.height,
        _buildTextField(
          'Residential Address',
          _address,
          FeatherIcons.mapPin,
          validator: (v) => v.validate().isEmpty ? 'Residential Address is required' : null,
        ),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('VEHICLE DETAILS', 'Register your vehicle.'),
        24.height,
        Text(
          'Vehicle Type',
          style: GoogleFonts.montserrat(fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700),
        ),
        12.height,
        Row(
          children: ['Motorcycle', 'Bicycle', 'Car'].map((type) {
            bool isSelected = _vehicleType == type;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _vehicleType = type),
                child: Container(
                  margin: EdgeInsets.only(right: type == 'Car' ? 0 : 8.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: isSelected ? primary : sand),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontFamily: cinta,
                        fontSize: 14.sp,
                        color: isSelected ? white : ink,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        24.height,
        _buildTextField(
          'Vehicle Manufacturer (e.g. Honda)',
          _vehicleMake,
          FeatherIcons.truck,
          validator: (v) => v.validate().isEmpty ? 'Vehicle Manufacturer is required' : null,
        ),
        16.height,
        _buildTextField(
          'License Plate Number',
          _plateNumber,
          FeatherIcons.hash,
          validator: (v) => v.validate().isEmpty ? 'License Plate Number is required' : null,
        ),
      ],
    );
  }

  Widget _buildVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DOCUMENTATION', 'Verify your credentials.'),
        24.height,
        _buildUploadField(
          'Driver\'s License',
          'Front & Back View',
          _licenseImagePath,
          () async {
            final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (picked != null) setState(() => _licenseImagePath = picked.path);
          },
        ),
        16.height,
        _buildUploadField(
          'Vehicle Insurance/Reg',
          'Valid Documents',
          _insuranceImagePath,
          () async {
            final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (picked != null) setState(() => _insuranceImagePath = picked.path);
          },
        ),
        16.height,
        _buildUploadField(
          'NIN/ID Card',
          'National Identification',
          _ninImagePath,
          () async {
            final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (picked != null) setState(() => _ninImagePath = picked.path);
          },
        ),
        32.height,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16.r)),
          child: Row(
            children: [
              Icon(FeatherIcons.shield, color: primary, size: 20.sp),
              16.width,
              Expanded(
                child: Text(
                  'Your data is encrypted and only used for verification purposes.',
                  style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: ink.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cinta',
            fontSize: 12.sp,
            color: primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        8.height,
        Text(
          sub,
          style: TextStyle(
            fontFamily: 'Cinta',
            fontSize: 22.sp,
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: 'Enter your ${label.toLowerCase()}',
      textInputType: type,
      validator: validator,
    );
  }

  Widget _buildUploadField(String label, String sub, String? imagePath, VoidCallback onTap, {bool isCac = false}) {
    final bool hasFile = imagePath != null && imagePath.isNotEmpty;
    final String fileName = hasFile ? imagePath.split(RegExp(r'[/\\]')).last : '';
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        color: sand,
        strokeWidth: 1,
        dashPattern: const [8, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16.r)),
          child: hasFile
              ? Row(
                  children: [
                    if (isCac)
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                        child: Icon(FeatherIcons.fileText, color: primary, size: 24.sp),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(imagePath),
                          height: 50.h,
                          width: 50.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: GoogleFonts.montserrat(fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700)),
                          4.height,
                          Text(isCac ? fileName : 'File uploaded successfully', style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: isCac ? primary : successColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(FeatherIcons.checkCircle, color: successColor, size: 20.sp),
                  ],
                )
              : Column(
                  children: [
                    Icon(FeatherIcons.camera, color: primary, size: 28.sp),
                    12.height,
                    Text(label, style: TextStyle(fontFamily: 'Cinta', fontSize: 15.sp, color: ink, fontWeight: FontWeight.w700)),
                    4.height,
                    Text(sub, style: TextStyle(fontFamily: 'Cinta', fontSize: 12.sp, color: textLight)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: EdgeInsets.all(17.w),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: AppButton(
                  text: 'Back',
                  textStyle: GoogleFonts.montserrat(color: ink, fontWeight: FontWeight.w700),
                  color: white,
                  onTap: () => setState(() => _currentStep--),
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r), side: BorderSide(color: sand)),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: AppButton(
          text: _currentStep == 2
              ? (_isLoading ? 'Submitting...' : 'Submit Application')
              : 'Next Step',
              textStyle: GoogleFonts.montserrat(color: white, fontWeight: FontWeight.w700),
              color: primary,
          onTap: _isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {

                    if (_currentStep == 2) {
                      if (_licenseImagePath == null || _licenseImagePath!.isEmpty) {
                        toast('Please upload Driver\'s License');
                        return;
                      }
                      if (_insuranceImagePath == null || _insuranceImagePath!.isEmpty) {
                        toast('Please upload Vehicle Insurance/Reg');
                        return;
                      }
                      if (_ninImagePath == null || _ninImagePath!.isEmpty) {
                        toast('Please upload NIN/ID Card');
                        return;
                      }
                    }

                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      setState(() => _isLoading = true);
                      log('[RIDER] Submitting rider application...');
                      final res = await VendorService.instance.applyAsRider(
                        fullName: _fullName.text.trim(),
                        email: _email.text.trim(),
                        phone: _phone.text.trim(),
                        address: _address.text.trim(),
                        vehicleType: _vehicleType,
                        vehicleMake: _vehicleMake.text.trim(),
                        plateNumber: _plateNumber.text.trim(),
                        certificate: _licenseImagePath,
                      );
                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (res.status != true) {
                          toast(res.message ?? 'Failed to submit application');
                          return;
                        }
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_vendor', false);
                        await prefs.setString('vendor_status', 'pending');
                        await prefs.setString('vendor_type', 'rider');
                        await prefs.setString('shop_name', _fullName.text.trim());
                        setValue('is_vendor', false);
                        setValue('vendor_status', 'pending');
                        setValue('vendor_type', 'rider');
                        if (mounted) {
                          const SuccessPage(
                            isVendorRegistration: true,
                            medium: 'Application Sent to Moderation',
                            message: 'Your rider application has been submitted to the Moderation Dashboard for admin review and approval.',
                          ).launch(context);
                        }
                      }
                    }
                  }
                },
              shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ],
      ),
    );
  }
}
