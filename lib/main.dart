import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:web/web.dart' as web;
import 'firebase_options.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize ads based on the active platform
  if (kIsWeb) {
    // Register AdSense view factory for Chrome / Web builds
    ui.platformViewRegistry.registerViewFactory(
      'adsense-element',
      (int viewId) {
        final element = web.document.createElement('ins') as web.HTMLElement;
        element.setAttribute('class', 'adsbygoogle');
        element.setAttribute('style', 'display:block');
        element.setAttribute('data-ad-client', 'ca-pub-XXXXXXXXXXXXXXXX'); // Your Publisher ID
        element.setAttribute('data-ad-slot', '1234567890'); // Your Ad Slot ID
        element.setAttribute('data-ad-format', 'auto');
        element.setAttribute('data-full-width-responsive', 'true');

        final script = web.document.createElement('script') as web.HTMLElement;
        script.text = '(adsbygoogle = window.adsbygoogle || []).push({});';
        element.appendChild(script);

        return element;
      },
    );
  } else {
    // Initialize AdMob ONLY on Android / iOS
    await MobileAds.instance.initialize();
  }

  runApp(const SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: false,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}