import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylclick/shared/widgets/nav.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/shared/constants/colors.dart';
import 'package:stylclick/core/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    log('[SPLASH] SplashScreen initialized');
    ApiService.instance.warmUpBackend();
    _init();
  }

  void _init() async {
    try {
      print('[SPLASH_DEBUG] Starting 2 second delay...');
      await Future.delayed(const Duration(seconds: 2));
      print('[SPLASH_DEBUG] Delay finished. Getting SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      print('[SPLASH_DEBUG] SharedPreferences acquired. Reading login credentials...');
      String token = prefs.getString('access_token') ?? '';
      if (token.isEmpty) {
        token = getStringAsync('access_token');
        if (token.isNotEmpty) {
          await prefs.setString('access_token', token);
        }
      }
      final bool hasToken = token.isNotEmpty;
      final bool isLoggedIn = (prefs.getBool('home') ?? false) && hasToken;
      log('[SPLASH] Checking login status: isLoggedIn = $isLoggedIn (token: ${hasToken ? "present" : "EMPTY"})');
      if (!isLoggedIn) {
        await prefs.setBool('home', false);
        setValue('home', false);
      }
      if (!mounted) return;
      if (isLoggedIn) {
        log('[SPLASH] Navigating to Home Dashboard (Nav)');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Nav()),
        );
      } else {
        log('[SPLASH] Navigating to LoginScreen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e, stack) {
      log('[SPLASH] Navigation error: $e\n$stack');
      print('[SPLASH_DEBUG] Caught error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream, // Use cream background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a simple icon or text instead of the heavy image to avoid OOM
            Text(
              'Stylclick',
              style: TextStyle(
                fontFamily: 'Cinta',
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
