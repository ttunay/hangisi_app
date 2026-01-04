import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui'; // ImageFilter.blur için
import 'package:hangisi_app/ekranlar/giris_kayit/giris_ekrani.dart';
import 'package:hangisi_app/ekranlar/uretici/uretici_profil_ekrani.dart';
import 'package:hangisi_app/ekranlar/uretici/urun_ekle_ekrani.dart';
import 'package:hangisi_app/ekranlar/uretici/urunler_ekrani.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  // Alt menüde seçili sekme index'i (başlangıçta profil sayfası = 2)
  int _seciliSekme = 2;

  // BottomNavigation içindeki sayfalar (IndexedStack ile state korunur)
  final List<Widget> _sayfalar = const [
    UrunEkleEkrani(),
    UrunlerEkrani(),
    UreticiProfilEkrani(),
  ];

  // ============================================================
  // 1) ÇIKIŞ DİYALOĞU
  // ============================================================
  /// Çıkış butonuna basılınca kullanıcıya onay sorar.
  /// Onaylanırsa:
  ///  - FirebaseAuth signOut yapılır
  ///  - Dialog kapanır
  ///  - Giriş ekranına geri dönülür (pushAndRemoveUntil ile stack temizlenir)
  void _cikisYap(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text("Çıkış Yap"),
        content: const Text(
          "Çıkış yapmak istediğinize emin misiniz?",
          style: TextStyle(fontSize: 17),
        ),
          
        actions: [
          // Vazgeç: sadece dialog kapanır
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Vazgeç", 
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
          ),

          // Çıkış: signOut + yönlendirme
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // dialogContext yerine ana context'i kullanmak daha stabil olur.
              // Önce dialog kapanır, sonra login ekranına geçilir.
              if (!context.mounted) return;

              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GirisEkrani()),
                (route) => false,
              );
            },
            child: const Text(
              "Çıkış",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2) ARKA PLAN (GÖRSEL + BLUR)
  // ============================================================
  /// Arka plan yapısı:
  ///  - Zemin rengi
  ///  - Cover bir arka plan görseli
  ///  - Üzerine blur/cam efekti (BackdropFilter)
  Widget _buildBackground() {
    return Stack(
      children: [
        // Zemin rengi
        Container(color: const Color(0xFFE7E9E8)),

        // Arka plan resmi
        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),

        // Cam / blur efekti
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              // Blur'un görünmesi için az opak beyaz katman
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 3) ANA BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Responsive birim: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    // Boş alana tıklayınca klavye kapansın diye GestureDetector
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          // Arka plan
          _buildBackground(),

          // Üstte gerçek içerik (Scaffold)
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            extendBody: true,

            // IndexedStack: sekmeler arası geçişte sayfa state'i korunur
            body: IndexedStack(
              index: _seciliSekme,
              children: _sayfalar,
            ),

            // Alttaki floating navigation bar
            bottomNavigationBar: _buildFloatingNavBar(birim),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4) ALT NAVBAR
  // ============================================================
  /// Alt navigation bar:
  ///  - 3 sekme (Ekle, Ürünler, Profil)
  ///  - sağda ayraç + çıkış ikonu
  Widget _buildFloatingNavBar(double birim) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        birim * 0.04,
        0,
        birim * 0.04,
        birim * 0.08,
      ),
      height: birim * 0.16,
      decoration: BoxDecoration(
        color: const Color(0xFF1E201C),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Sekmeler
          _buildNavItem(Icons.add, Icons.add, 0, birim),
          _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, 1, birim),
          _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 2, birim),

          // Ayraç çizgisi (görsel amaçlı)
          Container(
            height: birim * 0.06,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),

          // Çıkış ikonu
          GestureDetector(
            onTap: () => _cikisYap(context),
            child: Padding(
              padding: EdgeInsets.all(birim * 0.02),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: birim * 0.065,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 5) NAV ITEM (TEK TEK BUTON)
  // ============================================================
  /// Alt menüdeki her bir ikon:
  ///  - Seçiliyse arka plan hafif beyazlaşır
  ///  - Seçiliyse aktif ikon (activeIcon) kullanılır
  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    int index,
    double birim,
  ) {
    final bool isSelected = _seciliSekme == index;

    return GestureDetector(
      onTap: () => setState(() => _seciliSekme = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(birim * 0.025),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.white : Colors.white60,
          size: birim * 0.07,
        ),
      ),
    );
  }
}
