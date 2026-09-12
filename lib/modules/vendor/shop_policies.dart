import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';

class Policy {
  String type;
  String value;
  Policy({required this.type, required this.value});
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
  factory Policy.fromJson(Map<String, dynamic> j) => Policy(type: j['type'], value: j['value']);
}

class ShopPoliciesPage extends StatefulWidget {
  final List<Policy> policies;
  final Function(List<Policy>) onSave;

  const ShopPoliciesPage({Key? key, required this.policies, required this.onSave}) : super(key: key);

  @override
  State<ShopPoliciesPage> createState() => _ShopPoliciesPageState();
}

class _ShopPoliciesPageState extends State<ShopPoliciesPage> {
  late List<Policy> _policies;
  final _deliveryCtrl = TextEditingController();

  final List<String> _returnOptions = ['Within 24 hours', 'Within 3 days', 'Within 7 days', 'Within 14 days', 'No returns', 'Case by case'];
  final List<String> _guaranteeOptions = ['Quality assured or free redo', 'Full refund if not satisfied', 'Free alterations within 30 days', 'No guarantee', 'As described'];

  @override
  void initState() {
    super.initState();
    _policies = widget.policies.map((p) => Policy(type: p.type, value: p.value)).toList();
    
    // Ensure all 3 types exist
    for (final type in ['Returns', 'Delivery', 'Guarantee']) {
      if (!_policies.any((p) => p.type == type)) {
        _policies.add(Policy(type: type, value: type == 'Delivery' ? 'Lagos: 1-2 days' : ''));
      }
    }

    final delPolicy = _policies.firstWhere((p) => p.type == 'Delivery');
    _deliveryCtrl.text = delPolicy.value;
  }

  @override
  void dispose() {
    _deliveryCtrl.dispose();
    super.dispose();
  }

  IconData _iconFor(String type) {
    if (type == 'Returns') return FeatherIcons.refreshCw;
    if (type == 'Delivery') return FeatherIcons.truck;
    return FeatherIcons.shield;
  }

  void _save() {
    final delIndex = _policies.indexWhere((p) => p.type == 'Delivery');
    if (delIndex != -1) {
      _policies[delIndex].value = _deliveryCtrl.text.trim();
    }
    widget.onSave(_policies);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final returnPolicy = _policies.firstWhere((p) => p.type == 'Returns');
    final guaranteePolicy = _policies.firstWhere((p) => p.type == 'Guarantee');

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
          'Shop Policies',
          style: GoogleFonts.montserrat(color: ink, fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Define your store terms and policies for buyers.',
                      style: TextStyle(fontFamily: cinta, fontSize: 14.sp, color: textLight),
                    ),
                    24.height,

                    // Delivery Section
                    _buildDeliverySection(),
                    24.height,

                    // Returns Section
                    _buildChipsSection('Returns Policy', returnPolicy, _returnOptions),
                    24.height,

                    // Guarantee Section
                    _buildChipsSection('Guarantee Policy', guaranteePolicy, _guaranteeOptions),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Policies',
                    style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_iconFor('Delivery'), color: primary, size: 18.sp),
            8.width,
            Text(
              'Delivery & Dispatch Terms',
              style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ink),
            ),
          ],
        ),
        10.height,
        TextFormField(
          controller: _deliveryCtrl,
          style: GoogleFonts.montserrat(fontSize: 14.sp, color: ink),
          decoration: InputDecoration(
            hintText: 'e.g. Lagos: 1–2 days, Outside Lagos: 3–5 days',
            hintStyle: TextStyle(fontFamily: cinta, color: textLight),
            filled: true,
            fillColor: cream,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: sand)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: sand)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: primary, width: 1.5)),
          ),
        ),
        6.height,
        Text(
          'Let buyers know estimated delivery times and dispatch availability.',
          style: TextStyle(fontFamily: cinta, fontSize: 11.sp, color: textLight),
        ),
      ],
    );
  }

  Widget _buildChipsSection(String sectionTitle, Policy policy, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_iconFor(policy.type), color: primary, size: 18.sp),
            8.width,
            Text(
              sectionTitle,
              style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: ink),
            ),
          ],
        ),
        12.height,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final selected = policy.value == opt;
            return GestureDetector(
              onTap: () => setState(() => policy.value = opt),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: selected ? primary : cream,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: selected ? primary : sand),
                ),
                child: Text(
                  opt,
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
      ],
    );
  }
}
