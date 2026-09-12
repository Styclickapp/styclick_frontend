import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/modules/auth/login.dart';
import 'package:stylclick/modules/splash.dart';
import 'package:stylclick/shared/constants/strings.dart';
import 'package:stylclick/shared/utils/helpers.dart';
import 'package:stylclick/shared/widgets/nav.dart';

import 'package:stylclick/core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool moveToOnboarding = false;
  bool moveToHome = true;

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      moveToHome = prefs.getBool('home') ?? false;
      moveToOnboarding = (prefs.getBool('onboarding') ?? true);
    });
  }

  @override
  void initState() {
    load();
    ApiService.instance.warmUpBackend();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Use a standard design size instead of querying window physical size before first frame
      builder: (BuildContext context, Widget? child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scrollBehavior: SBehavior(),
        title: appName,
        home: const SplashScreen(),
        theme: ThemeData(
          fontFamily: 'Cinta',
          drawerTheme: DrawerThemeData(
            width: (320.w).clamp(280.0, 420.0),
          ),
        ),
      ),
    );
  }
}
