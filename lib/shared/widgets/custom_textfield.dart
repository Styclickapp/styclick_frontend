import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';

class CustomTextField extends StatelessWidget {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final String? hintText;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool obscureText;
  final String? obscuringCharacter;
  final bool? enabled;
  final Function()? onTap;
  final String? initialVlaue;
  final List<TextInputFormatter>? inputFormmater;
  final AutovalidateMode? autovalidateMode;
  final BorderRadius? borderRadius;
  String? label;
  Color? labelColor;
  Color? hintTextColor;
  Color? filledColor;
  Color? borderColor;
  Color? focusedBorderColor;
  Color? enabledBorderColor;
  int? maxLines;
  FontWeight? fontWeight;

  CustomTextField(
      {this.borderColor,
      this.focusedBorderColor,
      this.enabledBorderColor,
      this.prefixIcon,
      this.suffixIcon,
      this.validator,
      this.onSaved,
      this.hintText,
      this.textInputAction,
      this.textInputType,
      this.textAlign,
      this.onChanged,
      this.controller,
      this.obscureText = false,
      this.obscuringCharacter,
      this.enabled = true,
      this.onTap,
      this.initialVlaue,
      this.inputFormmater,
      this.autovalidateMode,
      this.borderRadius,
      this.label = '',
      this.hintTextColor,
      this.filledColor,
      this.maxLines,
      this.fontWeight,
      this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.validate().isNotEmpty)
          Text(
            _toTitleCase(label!),
            style: GoogleFonts.montserrat(
              fontSize: 11.sp,
              color: labelColor ?? textLight,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        if (label.validate().isNotEmpty) 6.height,
        TextFormField(
          initialValue: initialVlaue,
          onTap: onTap,
          maxLines: maxLines ?? 1,
          enabled: enabled,
          textInputAction: textInputAction,
          inputFormatters: inputFormmater,
          style: TextStyle(
            fontFamily: cinta,
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
            color: ink,
          ),
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: cinta,
              color: hintTextColor ?? textLight.withOpacity(0.5),
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: filledColor ?? white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor ?? sand),
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: focusedBorderColor ?? primary, width: 1.5),
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: enabledBorderColor ?? sand,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
          ),
          obscureText: obscureText,
          controller: controller,
          textAlign: textAlign ?? TextAlign.start,
          keyboardType: textInputType,
          onFieldSubmitted: onSaved,
          onSaved: onSaved,
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word.replaceAllMapped(RegExp(r'[a-zA-Z]+'), (match) {
      String m = match.group(0)!;
      if (m == 'NGN') return 'NGN';
      if (m == 'CAC') return 'CAC';
      if (m == 'NIN') return 'NIN';
      if (m == 'ID') return 'ID';
      return m[0].toUpperCase() + m.substring(1).toLowerCase();
    });
  }).join(' ');
}
