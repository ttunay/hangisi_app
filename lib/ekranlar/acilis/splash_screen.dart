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
    // 5 saniye sonra Giriş Ekranına temiz geçiş
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GirisEkrani()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive birim: Ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. KATMAN: Arka Plan
          RotatedBox(
            quarterTurns: isLandscape ? 3 : 0,
            child: Image.asset(
              'assets/splash_arkaplan.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // 2. KATMAN: Logo ve Yazı (Tam Merkezde)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
              mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortala
              crossAxisAlignment: CrossAxisAlignment.center, // Yatayda ortala
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: birim * 0.50,
                  height: birim * 0.50,
                  fit: BoxFit.contain,
                ),
                
                // Logo ile yazı arasındaki boşluk
                SizedBox(height: birim * 0.01), // Biraz artırıldı, daha dengeli durur

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
                    height: 1.0, // Satır yüksekliği standartlaştırıldı
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