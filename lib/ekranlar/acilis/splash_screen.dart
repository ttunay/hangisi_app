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
    // 3 Saniye bekle ve Giriş Ekranına geç
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GirisEkrani()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını al
    final size = MediaQuery.of(context).size;
    
    // RESPONSIVE ÖLÇÜ BİRİMİ (Kısa Kenar)
    final double responsiveBirim = size.shortestSide;
    
    // LOGO BOYUTU (%60)
    final double logoBoyutu = responsiveBirim * 0.60;

    return Scaffold(
      // --- ARKA PLAN RENGİ (Temadaki Gri) ---
      backgroundColor: Color(0xFFE7E9E8),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. KATMAN: ARKA PLAN RESMİ (DÖNEN)
              Positioned.fill(
                child: RotatedBox(
                  quarterTurns: isLandscape ? 3 : 0, 
                  child: Image.asset(
                    'assets/splash_arkaplan.png',
                    fit: BoxFit.cover, 
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),

              // 2. KATMAN: LOGO + YAZI
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- LOGO ---
                    SizedBox(
                      width: logoBoyutu,
                      height: logoBoyutu,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // --- ARADAKİ BOŞLUK ---
                    SizedBox(height: responsiveBirim * 0.005),

                    // --- YAZI ---
                    Text(
                      "hangisi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: responsiveBirim * 0.10,
                        fontWeight: FontWeight.w900,
                        // --- YAZI RENGİ (Temadaki Siyah) ---
                        // Projede butonlarda kullandığımız siyah tonu
                        color: const Color(0xFF1E201C), 
                        letterSpacing: -1.0,
                        height: 0.8, 
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}