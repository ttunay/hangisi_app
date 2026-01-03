import 'dart:async'; // Timer için gerekli (belirli süre sonra işlem çalıştırır)
import 'package:flutter/material.dart';

import '../giris_kayit/giris_ekrani.dart'; // 4 sn sonra gideceğimiz ekran

/// SplashScreen:
/// - Uygulama açılır açılmaz görünen karşılama ekranı.
/// - Arka plan görseli + logo + "hangisi" yazısını gösterir.
/// - 4 saniye sonra giriş ekranına (GirisEkrani) yönlendirir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Uygulama açıldıktan 4 saniye sonra çalışacak bir Timer başlatıyoruz.
    // Amaç: Splash ekranda kısa süre bekletip sonra giriş ekranına geçmek.
    Timer(const Duration(seconds: 4), () {
      // Widget ekrandan kaldırıldıysa (ör. hızlıca başka yere gidildiyse)
      // Navigator kullanmak hata verebilir. Bu yüzden mounted kontrolü yapıyoruz.
      if (!mounted) return;

      // pushReplacement:
      // - Mevcut ekranı (Splash) tamamen değiştirir.
      // - Kullanıcı geri tuşuna basınca Splash’a dönmez.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // builder: sayfayı oluşturan fonksiyon
          builder: (_) => const GirisEkrani(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ölçeklendirme için "birim":
    // Ekranın kısa kenarı (telefon dikey/yatay olsa bile en küçük taraf).
    // Böylece tasarım farklı ekranlarda orantılı kalır.
    final double birim = MediaQuery.of(context).size.shortestSide;

    // Cihaz yatay mı? (landscape)
    // Arka planı yatayda döndürmek için kullanıyoruz.
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      // Arka plan rengi (görsel yüklenmezse bile aynı arka plan görünür)
      backgroundColor: const Color.fromARGB(255, 228, 242, 247),

      // Stack: Ekranın üzerine katman katman widget koymamızı sağlar.
      // 1. katman: arka plan
      // 2. katman: logo + yazı
      body: Stack(
        fit: StackFit.expand, // Stack içindeki her şey tüm ekranı kaplayabilir
        children: [
          // 1) ARKA PLAN KATMANI
          RotatedBox(
            // Yatay modda arka planı döndürerek daha düzgün görünmesini sağlıyor.
            // quarterTurns: 1 => 90°, 2 => 180°, 3 => 270°
            quarterTurns: isLandscape ? 3 : 0,
            child: Image.asset(
              'assets/desen.png',
              fit: BoxFit.cover, // tüm ekranı kaplasın, taşan yerler kırpılır
              // Görsel bulunamazsa hata yerine boş bir widget göster.
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // 2) ORTADAKİ LOGO + YAZI KATMANI
          Center(
            child: Column(
              // Column sadece içeriği kadar yer kaplasın
              mainAxisSize: MainAxisSize.min,
              // Dikey olarak ortala
              mainAxisAlignment: MainAxisAlignment.center,
              // Yatay olarak ortala
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO
                Image.asset(
                  'assets/logo.png',
                  // Logo boyutu ekrana göre ölçekleniyor:
                  width: birim * 0.55,
                  height: birim * 0.55,
                  fit: BoxFit.contain,
                ),

                // Logo ile yazı arasında boşluk (ekrana göre ölçekli)
                SizedBox(height: birim * 0.01),

                // "hangisi" yazısı
                Text(
                  'hangisi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    // Yazı boyutu ekrana göre ölçekli
                    fontSize: birim * 0.10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E201C),
                    letterSpacing: -1.0,
                    height: 1.0, // satır yüksekliği
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
