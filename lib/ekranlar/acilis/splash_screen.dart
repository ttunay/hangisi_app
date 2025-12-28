import 'package:flutter/material.dart';
import 'dart:async';
import '../../yapilandirma/tema.dart';
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
    
    // RESPONSIVE ÖLÇÜ BİRİMİ (Kısa Kenar):
    // Telefon yan da olsa dik de olsa referans noktamız hep kısa kenardır.
    // Bu sayede nesneler ekrandan taşmaz.
    final double responsiveBirim = size.shortestSide;
    
    // LOGO BOYUTU (Ekranın kısa kenarının yarısı)
    final double logoBoyutu = responsiveBirim * 0.50;

    return Scaffold(
      backgroundColor: Colors.white,
      // OrientationBuilder: Ekranın dönüşünü dinler
      body: OrientationBuilder(
        builder: (context, orientation) {
          // Ekran yatay modda mı?
          final bool isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // 1. KATMAN: ARKA PLAN (DÖNEN VE KAPLAYAN)
              // ============================================================
              Positioned.fill(
                // RotatedBox: Eğer ekran yan ise (landscape), dikey resmi
                // 90 derece çevirerek (3 çeyrek tur) ekrana tam oturtur.
                child: RotatedBox(
                  quarterTurns: isLandscape ? 3 : 0, 
                  child: Image.asset(
                    'assets/splash_arkaplan.png',
                    fit: BoxFit.cover, // Boşluk kalmayacak şekilde doldur
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox();
                    },
                  ),
                ),
              ),

              // ============================================================
              // 2. KATMAN: İÇERİK GRUBU (LOGO + YAZI) - TAM MERKEZ
              // ============================================================
              Center(
                child: Column(
                  // Column sadece içindeki elemanlar kadar yer kaplasın
                  mainAxisSize: MainAxisSize.min,
                  // Yatayda ortala
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

                    // --- ARADAKİ İNCE BOŞLUK ---
                    // Logoya çok yakın olması için %2'lik boşluk
                    SizedBox(height: responsiveBirim * 0.02),

                    // --- YAZI ---
                    Text(
                      "hangisi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        // Font boyutu responsive
                        fontSize: responsiveBirim * 0.10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E201C),
                        letterSpacing: -1.0,
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