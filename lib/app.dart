import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme_constants.dart';
import 'screens/splash_screen.dart';
import 'providers/user_provider.dart';

class SkinToneShopApp extends StatelessWidget {
  const SkinToneShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinTone Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeConstants.lightTheme,
      darkTheme: ThemeConstants.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
