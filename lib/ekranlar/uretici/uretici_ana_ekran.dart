import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int _seciliSekme = 2; // Ürünlerim listesi ile başlasın

  final List<Widget> _sayfalar = [
    const UrunEkleEkrani(), // Index 0
    const UrunlerEkrani(),  // Index 1
    const ProfilEkrani(),   // Index 2
  ];

  void _cikisYap(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Çıkış Yap"),
      content: const Text("Oturumu kapatmak istediğinize emin misiniz?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
        TextButton(
          onPressed: () async {
            // 1. Firebase oturumunu kapat
            await FirebaseAuth.instance.signOut();
            
            if (context.mounted) {
              // 2. Diyaloğu kapat
              Navigator.pop(context); 
              
              // 3. Giriş ekranına git ve önceki tüm sayfaları sil
              // NOT: 'GirisEkrani()' kısmını kendi giriş sayfanın ismiyle değiştir.
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

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFE7E9E8),
      body: IndexedStack(index: _seciliSekme, children: _sayfalar),
      bottomNavigationBar: _buildFloatingNavBar(birim),
    );
  }

  Widget _buildFloatingNavBar(double birim) {
    return Container(
      margin: EdgeInsets.fromLTRB(birim * 0.04, 0, birim * 0.04, birim * 0.08),
      height: birim * 0.16,
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
        padding: EdgeInsets.all(birim * 0.015), 
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent, 
          shape: BoxShape.circle
        ),
        child: Icon(
          isSelected ? activeIcon : icon, 
          color: isSelected ? Colors.black : Colors.white70, 
          size: birim * 0.07 
        ),
      ),
    );
  }
}