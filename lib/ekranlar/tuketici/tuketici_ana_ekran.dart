import 'package:flutter/material.dart';
import '../../servisler/auth_servisi.dart';
import '../giris_kayit/giris_ekrani.dart';

class TuketiciAnaEkran extends StatelessWidget {
  const TuketiciAnaEkran({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthServisi _authServisi = AuthServisi();

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      appBar: AppBar(
        title: const Text("Tüketici Paneli", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD32F2F), // Kırmızı AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authServisi.cikisYap();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const GirisEkrani()), (r) => false);
            },
          )
        ],
      ),
      body: const Center(
        child: Text("Tüketici Ana Sayfası Şimdilik Boş", style: TextStyle(fontSize: 18, color: Colors.black54)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD32F2F), // Kırmızı Bottom Bar
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}