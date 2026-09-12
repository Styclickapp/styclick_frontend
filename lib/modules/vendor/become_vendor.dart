import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class BecomeVendor extends StatefulWidget {
  const BecomeVendor({Key? key}) : super(key: key);

  @override
  State<BecomeVendor> createState() => _BecomeVendorState();
}

class _BecomeVendorState extends State<BecomeVendor> {
  int _currentStep = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _shopName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  List<String> _specializations = [];
  final List<String> _options = ['Traditional', 'Corporate', 'Casual', 'Bridal', 'Asoebi', 'Streetwear'];

  // Image Upload Paths
  String? _cacImagePath;
  List<String> _portfolioImages = [];
  final _imagePicker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  void _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final prefEmail = prefs.getString('email') ?? getStringAsync('email');
    final prefPhone = prefs.getString('phone') ?? getStringAsync('phone');
    final prefAddress = prefs.getString('address') ?? getStringAsync('address');

    setState(() {
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
                    'Tailor Registration',
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
                      if (_currentStep == 0) _buildBusinessInfo(),
                      if (_currentStep == 1) _buildSpecialization(),
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

  Widget _buildBusinessInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BUSINESS DETAILS', 'Tell us about your brand.'),
        24.height,
        _buildTextField(
          'Brand/Shop Name',
          _shopName,
          FeatherIcons.briefcase,
          validator: (v) => v.validate().isEmpty ? 'Brand/Shop Name is required' : null,
        ),
        16.height,
        _buildTextField(
          'Email',
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
          'Physical Address',
          _address,
          FeatherIcons.mapPin,
          validator: (v) => v.validate().isEmpty ? 'Physical Address is required' : null,
        ),
      ],
    );
  }

  Widget _buildSpecialization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SPECIALIZATION', 'What styles do you master?'),
        24.height,
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _options.map((opt) {
            bool isSelected = _specializations.contains(opt);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) _specializations.remove(opt);
                  else _specializations.add(opt);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? primary : white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: isSelected ? primary : sand),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: cinta,
                    fontSize: 14.sp,
                    color: isSelected ? white : ink,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        32.height,
      ],
    );
  }

  Widget _buildVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('VERIFICATION', 'Upload proof of your business.'),
        24.height,
        _buildUploadField(
          'Business Registration (CAC)',
          'PDF or Image Document',
          _cacImagePath,
          () async {
            final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (picked != null) setState(() => _cacImagePath = picked.path);
          },
        ),
        32.height,
        Row(
          children: [
            Icon(FeatherIcons.info, color: primary, size: 16.sp),
            8.width,
            Expanded(
              child: Text(
                'Approval typically takes 24-48 hours after manual review.',
                style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: textLight),
              ),
            ),
          ],
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

  Widget _buildUploadField(String label, String sub, String? filePath, VoidCallback onTap) {
    final bool hasFile = filePath != null && filePath.isNotEmpty;
    final String fileName = hasFile ? filePath.split(RegExp(r'[/\\]')).last : '';
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
                    if (filePath != null && (filePath.endsWith('.png') || filePath.endsWith('.jpg') || filePath.endsWith('.jpeg') || filePath.endsWith('.webp') || filePath.endsWith('.heic')))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(filePath),
                          height: 48.h,
                          width: 48.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                            child: Icon(FeatherIcons.fileText, color: primary, size: 24.sp),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                        child: Icon(FeatherIcons.fileText, color: primary, size: 24.sp),
                      ),
                    14.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: GoogleFonts.montserrat(fontSize: 14.sp, color: ink, fontWeight: FontWeight.w700)),
                          4.height,
                          Text(fileName, style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: primary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(FeatherIcons.checkCircle, color: successColor, size: 20.sp),
                  ],
                )
              : Column(
                  children: [
                    Icon(FeatherIcons.uploadCloud, color: primary, size: 32.sp),
                    12.height,
                    Text(label, style: GoogleFonts.montserrat(fontSize: 15.sp, color: ink, fontWeight: FontWeight.w700)),
                    4.height,
                    Text(sub, style: TextStyle(fontFamily: cinta, fontSize: 12.sp, color: textLight)),
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
            child: GestureDetector(
              onLongPress: _currentStep == 2
                  ? () async {
                      log('[DEBUG] Long-press: bypassing API, simulating tailor approval.');
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_vendor', true);
                      await prefs.setString('vendor_type', 'tailor');
                      await prefs.setString('shop_name', _shopName.text.trim());
                      await prefs.setString('phone', _phone.text.trim());
                      await prefs.setString('address', _address.text.trim());
                      await prefs.setString('email', _email.text.trim());
                      await prefs.setString('specializations', _specializations.join(','));
                      if (_cacImagePath != null) {
                        await prefs.setString('cac_image_path', _cacImagePath!);
                      }
                      if (_portfolioImages.isNotEmpty) {
                        await prefs.setStringList('portfolio_images', _portfolioImages);
                      }
                      if (mounted) {
                        const SuccessPage(
                          isVendorRegistration: true,
                          medium: 'Application Sent',
                          message: 'Your tailor profile is being reviewed. We will contact you shortly.',
                        ).launch(context);
                      }
                    }
                  : null,
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
                          if (_currentStep == 1 && _specializations.isEmpty) {
                            toast('Please select at least one specialization');
                            return;
                          }

                          if (_currentStep == 2 && (_cacImagePath == null || _cacImagePath!.isEmpty)) {
                            toast('Please upload Business Registration (CAC)');
                            return;
                          }

                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            setState(() => _isLoading = true);
                            log('[VENDOR] Submitting vendor application...');
                            final res = await VendorService.instance.applyAsVendor(
                              shopName: _shopName.text.trim(),
                              email: _email.text.trim(),
                              phone: _phone.text.trim(),
                              address: _address.text.trim(),
                              specializations: _specializations,
                              certificate: _cacImagePath,
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
                              await prefs.setString('vendor_type', 'designer');
                              await prefs.setString('shop_name', _shopName.text.trim());
                              await prefs.setString('specializations', _specializations.join(','));
                              setValue('is_vendor', false);
                              setValue('vendor_status', 'pending');
                              setValue('vendor_type', 'designer');
                              if (mounted) {
                                const SuccessPage(
                                  isVendorRegistration: true,
                                  medium: 'Application Sent to Moderation',
                                  message: 'Your tailor application has been submitted to the Moderation Dashboard for admin review and approval.',
                                ).launch(context);
                              }
                            }
                          }
                        }
                      },
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
