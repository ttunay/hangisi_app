import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hangisi_app/ekranlar/giris_kayit/giris_ekrani.dart';
import 'package:hangisi_app/ekranlar/tuketici/kesfet_ekrani.dart'; 
import 'package:hangisi_app/ekranlar/tuketici/tuketici_profil_ekrani.dart';

class TuketiciAnaEkran extends StatefulWidget {
  const TuketiciAnaEkran({super.key});

  @override
  State<TuketiciAnaEkran> createState() => _TuketiciAnaEkranState();
}

class _TuketiciAnaEkranState extends State<TuketiciAnaEkran> {
  int _seciliSekme = 1;

  final List<Widget> _sayfalar = [
    const KesfetEkrani(),         
    const TuketiciProfilEkrani(), 
  ];

  void _cikisYap(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Oturumu kapatmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              try {
                // 1. Firebase oturumunu kapat
                await FirebaseAuth.instance.signOut();
                
                // 2. Diyaloğu kapat
                if (mounted) Navigator.pop(dialogContext);

                // 3. Giriş ekranına yönlendir
                if (mounted) {
                  // EĞER main.dart'ta rotalarınız (routes) tanımlıysa bu satır çalışır:
                  // Navigator.pushNamedAndRemoveUntil(context, '/giris', (route) => false);

                  // EĞER yukarıdaki çalışmıyorsa, aşağıdaki blok en kesin çözümdür:
                  // 'GirisEkrani()' yazan yere kendi giriş sayfanızın sınıf adını yazın.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const GirisEkrani(), // <--- BURAYI DEĞİŞTİRİN
                    ),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("Çıkış hatası: $e");
              }
            },
            child: const Text("Çıkış", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
      backgroundColor: Color.fromARGB(255, 228, 242, 247),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.search_rounded, Icons.search_rounded, 0, birim),
          _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 1, birim), 
          GestureDetector(
            onTap: () => _cikisYap(context),
            child: Container(
              padding: EdgeInsets.all(birim * 0.02),
              color: Colors.transparent, 
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
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent, 
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          isSelected ? activeIcon : icon, 
          color: isSelected ? Colors.white : Colors.white60, 
          size: birim * 0.07 
        ),
      ),
    );
  }
}