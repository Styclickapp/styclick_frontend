import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/widgets/custom_textfield.dart';
import 'package:stylclick/shared/widgets/snack_bar.dart';
import 'package:stylclick/core/services/auth_service.dart';
import 'package:stylclick/core/services/profile_service.dart';
import 'package:stylclick/modules/auth/login.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _understandCheckbox = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_understandCheckbox) {
      showMessage(context, "Please acknowledge the warning checkbox");
      return;
    }

    final userEmail = getStringAsync('email');
    if (userEmail.isEmpty) {
      showMessage(context, "User session not found. Please log in again.");
      return;
    }

    // Double confirmation dialog
    final confirm = await showConfirmDialog(
      context,
      "Are you absolutely sure you want to delete your account? All of your data will be permanently removed. This action is irreversible.",
      positiveText: "Delete",
      negativeText: "Cancel",
      buttonColor: primary,
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      log('[DELETE_ACCOUNT] Verifying user password by attempting authentication...');
      final authRes = await AuthService.instance.login(
        userEmail,
        _passwordController.text.trim(),
      );

      if (authRes.status != true) {
        log('[DELETE_ACCOUNT] Password verification failed');
        if (mounted) {
          showMessage(context, "Incorrect password. Please verify your credentials.");
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      log('[DELETE_ACCOUNT] Password verified. Proceeding to delete account on the backend...');
      final deleteRes = await ProfileService.instance.deleteAccount();

      log('[DELETE_ACCOUNT] Backend delete account status: ${deleteRes.status}, message: ${deleteRes.message}');

      if (deleteRes.status == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        setValue('home', false);
        setValue('access_token', '');

        if (mounted) {
          toast("Account successfully deleted");
          const LoginScreen().launch(context, isNewTask: true);
        }
      } else {
        if (mounted) {
          final errorMsg = deleteRes.message ?? "Server failed to delete account.";
          showMessage(
            context,
            "Account deletion failed on the server ($errorMsg). Please contact support to delete your account.",
          );
        }
      }
    } catch (e) {
      log('[DELETE_ACCOUNT] Unexpected error during account deletion: $e');
      if (mounted) {
        showMessage(context, "An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                    'Delete Account',
                    style: TextStyle(
                      fontFamily: cinta,
                      fontSize: 18.sp,
                      color: ink,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFF5F5),
                          ),
                          child: Icon(
                            FeatherIcons.alertTriangle,
                            color: primary,
                            size: 48.sp,
                          ),
                        ),
                      ),
                      24.height,
                      Text(
                        'We are sad to see you go',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 20.sp,
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      8.height,
                      Text(
                        'Please read the warnings below carefully before proceeding. Deleting your account is permanent.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: cinta,
                          fontSize: 14.sp,
                          color: textLight,
                        ),
                      ),
                      24.height,
                      
                      // Warnings Container
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFFFD8D8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WARNING:',
                              style: TextStyle(
                                fontFamily: cinta,
                                fontSize: 13.sp,
                                color: primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            12.height,
                            _buildWarningItem('This action is irreversible and permanent.'),
                            8.height,
                            _buildWarningItem('You will lose access to your profile, listings, and items.'),
                            8.height,
                            _buildWarningItem('Any remaining wallet balance will be permanently forfeited.'),
                            8.height,
                            _buildWarningItem('Pending transactions and active orders will be cancelled.'),
                          ],
                        ),
                      ),
                      24.height,

                      // Confirmation Checkbox
                      InkWell(
                        onTap: () {
                          setState(() {
                            _understandCheckbox = !_understandCheckbox;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: Checkbox(
                                value: _understandCheckbox,
                                onChanged: (val) {
                                  setState(() {
                                    _understandCheckbox = val ?? false;
                                  });
                                },
                                activeColor: primary,
                              ),
                            ),
                            12.width,
                            Expanded(
                              child: Text(
                                'I understand the consequences and wish to permanently delete my account.',
                                style: TextStyle(
                                  fontFamily: cinta,
                                  fontSize: 13.sp,
                                  color: ink,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      32.height,

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Confirm Password',
                        hintText: 'Enter your password to confirm',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: textLight,
                            size: 20.sp,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required to delete account';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      40.height,

                      // Submit Button
                      ElevatedButton(
                        onPressed: (_understandCheckbox && !_isLoading) ? _handleDeleteAccount : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: primary.withOpacity(0.4),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return primary.withOpacity(0.4);
                            }
                            return primary;
                          }),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _understandCheckbox
                                ? const LinearGradient(
                                    colors: [primary, primaryGradient],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Container(
                            height: 56.h,
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Permanently Delete Account',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Container(
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        10.width,
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: cinta,
              fontSize: 13.sp,
              color: const Color(0xFFC53030),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
