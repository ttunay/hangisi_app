import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Çekirdeği
import 'package:hangisi_app/ekranlar/acilis/splash_screen.dart';
import 'firebase_options.dart'; // Az önce terminalin oluşturduğu dosya

void main() async {
  // Motoru Hazırla
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i Başlat (Android ve iOS ayarlarını otomatik alarak)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangisi?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Inter', // Projende tanımlı font
      ),
      // Uygulama Karşılama Ekranı ile başlar
      home: const SplashScreen(),
    );
  }
}

