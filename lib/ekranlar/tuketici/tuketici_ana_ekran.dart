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
  // Bottom bar'da seçili sekme index'i
  int _seciliSekme = 1;

  // Sekmelerin sayfaları (IndexedStack ile sayfa state'i korunur)
  final List<Widget> _sayfalar = const [
    KesfetEkrani(),
    TuketiciProfilEkrani(),
  ];

  // ------------------------------------------------------------
  // ÇIKIŞ DİYALOĞU
  // ------------------------------------------------------------
  void _cikisYap(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
      builder: (dialogContext) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text(
          "Çıkış yapmak istediğinize emin misiniz?",
          style: TextStyle(fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Vazgeç",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              try {
                // 1) Firebase oturumunu kapat
                await FirebaseAuth.instance.signOut();

                // 2) Dialog'u kapat
                if (mounted) Navigator.pop(dialogContext);

                // 3) Giriş ekranına dön (geri tuşuyla dönülmesin diye stack temizlenir)
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const GirisEkrani()),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("Çıkış hatası: $e");
              }
            },
            child: const Text(
              "Çıkış",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ANA BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Responsive birim: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(255, 228, 242, 247),
      body: IndexedStack(index: _seciliSekme, children: _sayfalar),
      bottomNavigationBar: _buildFloatingNavBar(birim),
    );
  }

  // ------------------------------------------------------------
  // FLOATING BOTTOM NAV BAR
  // ------------------------------------------------------------
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
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Keşfet
          _buildNavItem(Icons.search_rounded, Icons.search_rounded, 0, birim),

          // Profil
          _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 1, birim),

          // ✅ ÜRETİCİDEKİYLE AYNI DİK ÇİZGİ (AYRAÇ)
          Container(
            height: birim * 0.06,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),

          // Çıkış
          GestureDetector(
            onTap: () => _cikisYap(context),
            child: Container(
              padding: EdgeInsets.all(birim * 0.02),
              color: Colors.transparent,
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

  // ------------------------------------------------------------
  // TEK NAV ITEM
  // ------------------------------------------------------------
  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, double birim) {
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
