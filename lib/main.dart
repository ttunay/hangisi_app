import 'package:flutter/material.dart';
import 'yapilandirma/tema.dart'; // Tema dosyamız
import 'ekranlar/acilis/splash_screen.dart'; // Yeni başlangıç noktamız

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Firebase'i sonra açacağız
  runApp(const HangisiApp());
}

class HangisiApp extends StatelessWidget {
  const HangisiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HangisiApp',
      debugShowCheckedModeBanner: false, // Sağ üstteki 'Debug' yazısını kaldırır
      theme: UygulamaTemasi.temaGetir(), // Renk paletimizi uygular
      
      // İŞTE BURASI DEĞİŞTİ:
      // Uygulama ilk açıldığında Karşılama Ekranı (İnekli ekran) gelecek.
      home: const SplashScreen(),
    );
  }
}