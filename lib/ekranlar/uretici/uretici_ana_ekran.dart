import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui'; // Blur efekti için
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
  int _seciliSekme = 2; 

  final List<Widget> _sayfalar = [
    const UrunEkleEkrani(),
    const UrunlerEkrani(),
    const UreticiProfilEkrani(),
  ];

  void _cikisYap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Çıkış yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const GirisEkrani()),
                  (route) => false,
                );
              }
            },
            child: const Text("Çıkış", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- ARKA PLAN YAPISI ---
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: Color(0xFFE7E9E8)), // Zemin Rengi

        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),

        // --- GÜNCELLENEN CAM EFEKTİ ---
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur miktarı
            child: Container(
              color: Colors.white.withOpacity(0.1), 
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          _buildBackground(),

          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            extendBody: true,
            body: IndexedStack(
              index: _seciliSekme,
              children: _sayfalar,
            ),
            bottomNavigationBar: _buildFloatingNavBar(birim),
          ),
        ],
      ),
    );
  }

  // --- NAVIGATION BAR ---
  Widget _buildFloatingNavBar(double birim) {
    return Container(
      margin: EdgeInsets.fromLTRB(birim * 0.04, 0, birim * 0.04, birim * 0.08),
      height: birim * 0.18,
      decoration: BoxDecoration(
        color: const Color(0xFF1E201C),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.add, Icons.add, 0, birim),
          _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, 1, birim),
          _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 2, birim),
          Container(height: birim * 0.06, width: 1, color: Colors.white.withOpacity(0.2)),
          GestureDetector(
            onTap: () => _cikisYap(context),
            child: Padding(
              padding: EdgeInsets.all(birim * 0.03),
              child: Icon(Icons.logout_rounded, color: Colors.redAccent, size: birim * 0.065),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, double birim) {
    bool isSelected = _seciliSekme == index;
    return GestureDetector(
      onTap: () => setState(() => _seciliSekme = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(birim * 0.025),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
          size: birim * 0.065,
        ),
      ),
    );
  }
}