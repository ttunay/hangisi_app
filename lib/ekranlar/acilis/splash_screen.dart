import 'package:flutter/material.dart';
import 'dart:async';
import '../giris_kayit/giris_ekrani.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 saniye sonra Giriş Ekranına temiz geçiş
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GirisEkrani()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive birim: Ekranın kısa kenarı (Dikeyde genişlik, Yatayda yükseklik)
    final double birim = MediaQuery.of(context).size.shortestSide;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. KATMAN: Arka Plan (Yatay modda dönen)
          RotatedBox(
            quarterTurns: isLandscape ? 3 : 0,
            child: Image.asset(
              'assets/splash_arkaplan.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // 2. KATMAN: Logo ve Yazı (Merkezde)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: birim * 0.63,
                  height: birim * 0.63,
                  fit: BoxFit.contain,
                ),
                
                SizedBox(height: birim * 0.005),

                // Yazı
                Text(
                  "hangisi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: birim * 0.10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E201C),
                    letterSpacing: -1.0,
                    height: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}