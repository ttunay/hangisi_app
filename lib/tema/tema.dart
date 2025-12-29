// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class UygulamaTemasi {
//   // --- Renk Paleti (Senin gönderdiğin Coolors linklerinden seçildi) ---
  
//   // Ana Renkler (Doğa ve Güven - 1. Palet)
//   static const Color anaYesil = Color(0xFF1D683F); // Koyu yeşil (Marka rengi)
//   static const Color acikYesil = Color(0xFF3D7051); // Butonlar vs.
//   static const Color zeminRengi = Color(0xFFE7E9E8); // Kırık beyaz (Göz yormayan zemin)
//   static const Color yaziKoyu = Color(0xFF1E201C); // Okunabilir koyu metin

//   // Vurgu ve Uyarı Renkleri (2. ve 3. Palet)
//   static const Color uyariKirmizi = Color(0xFFB92A2F); // Hata veya yüksek fiyat uyarısı
//   static const Color vurguSari = Color(0xFFF9D187); // Yıldız, Puan, Öne çıkanlar
//   static const Color toprakRengi = Color(0xFF946B35); // Çiftçi detayları

//   // --- Tema Ayarları ---
//   static ThemeData temaGetir() {
//     return ThemeData(
//       useMaterial3: true,
//       scaffoldBackgroundColor: zeminRengi,
//       primaryColor: anaYesil,
      
//       // Renk Şeması
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: anaYesil,
//         primary: anaYesil,
//         secondary: toprakRengi,
//         error: uyariKirmizi,
//         surface: zeminRengi,
//       ),

//       // FONT AYARLARI (iOS benzeri Inter Fontu)
//       textTheme: GoogleFonts.interTextTheme().apply(
//         bodyColor: yaziKoyu,
//         displayColor: yaziKoyu,
//       ),

//       // AppBar Teması (Üst Başlık Çubuğu)
//       appBarTheme: const AppBarTheme(
//         backgroundColor: zeminRengi,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: yaziKoyu),
//         titleTextStyle: TextStyle(
//           color: yaziKoyu,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Inter', // Inter fontu
//         ),
//       ),

//       // Buton Teması (Tüm uygulama genelinde standart)
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: anaYesil, // Buton rengi
//           foregroundColor: Colors.white, // Buton yazı rengi
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12), // Hafif yuvarlak köşeler (iOS stili)
//           ),
//           textStyle: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
      
//       // Input (Giriş Alanı) Teması
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.all(16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none, // Çizgisiz, sadece gölge veya zemin
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: anaYesil, width: 2),
//         ),
//         labelStyle: const TextStyle(color: Colors.grey),
//       ),
//     );
//   }
// }