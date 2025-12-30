import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UrunlerEkrani extends StatefulWidget {
  const UrunlerEkrani({super.key});

  @override
  State<UrunlerEkrani> createState() => _UrunlerEkraniState();
}

class _UrunlerEkraniState extends State<UrunlerEkrani> {
  String _aramaKelimesi = "";

  final List<Color> _temaRenkleri = [
    const Color.fromARGB(255, 250, 245, 197),
    const Color.fromARGB(255, 243, 204, 203),
    const Color.fromARGB(255, 226, 194, 164),
    const Color.fromARGB(255, 205, 233, 182),
    const Color.fromARGB(255, 188, 209, 233),
    const Color.fromARGB(255, 182, 236, 232),
  ];

  // --- ARKA PLAN (İnekler + Glass) ---
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: Color.fromARGB(255, 228, 242, 247)), //ZEMİN RENGİ
        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  // --- ÜRÜN DETAY PANELİ ---
  void _urunDetayPaneli(
      String id, Map<String, dynamic> urun, Color kartRengi) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, //PANEL RENGİ
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(birim * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: birim * 0.06),
              Container(
                width: double.infinity,
                height: birim * 0.4,
                decoration: BoxDecoration(
                    color: kartRengi, borderRadius: BorderRadius.circular(25)),
                child: const Icon(Icons.eco, size: 80, color: Colors.black12),
              ),
              SizedBox(height: birim * 0.06),
              Text(urun['urunAdi'] ?? "",
                  style: TextStyle(
                      fontSize: birim * 0.08, fontWeight: FontWeight.bold)),
              Text("Barkod: ${urun['barkod'] ?? '-'}",
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w500)),
              SizedBox(height: birim * 0.06),
              _detaySatiri(Icons.description_outlined, "Açıklama",
                  urun['aciklama'] ?? "-", birim),
              _detaySatiri(Icons.grass_outlined, "Tohum",
                  urun['tohum'] ?? "-", birim),
              _detaySatiri(Icons.opacity_outlined, "Gübre",
                  urun['gubre'] ?? "-", birim),
              _detaySatiri(Icons.sanitizer_outlined, "İlaçlama",
                  urun['ilac'] ?? "-", birim),
              SizedBox(height: birim * 0.01),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _urunDuzenle(id, urun);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text("Düzenle"))),
                  SizedBox(width: birim * 0.04),
                  Expanded(
                      child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _urunSil(id);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("Sil"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB92A2F),
                              foregroundColor: Colors.white))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detaySatiri(
      IconData icon, String baslik, String icerik, double birim) {
    return Padding(
      padding: EdgeInsets.only(bottom: birim * 0.04),
      child: Row(
        children: [
          Icon(icon,
              size: birim * 0.06, color: const Color.fromARGB(255, 0, 0, 0)),
          SizedBox(width: birim * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: birim * 0.045,
                        fontWeight: FontWeight.w500)),
                Text(
                  icerik,
                  style: TextStyle(
                      fontSize: birim * 0.040, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ÜRÜN DÜZENLEME ---
  void _urunDuzenle(String urunId, Map<String, dynamic> urun) {
    final TextEditingController adEdit =
        TextEditingController(text: urun['urunAdi']);
    final TextEditingController aciklamaEdit =
        TextEditingController(text: urun['aciklama']);
    final TextEditingController barkodEdit =
        TextEditingController(text: urun['barkod']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 30,
            right: 30,
            top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ürünü Düzenle",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // 1. INPUT
            TextField(
                controller: adEdit,
                decoration: InputDecoration(
                    labelText: "Ürün Adı",
                    labelStyle: const TextStyle(fontSize: 20), 
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)))),
            
            const SizedBox(height: 15),
            
            // 2. INPUT
            TextField(
                controller: barkodEdit,
                decoration: InputDecoration(
                    labelText: "Barkod",
                    labelStyle: const TextStyle(fontSize: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)))),
            
            const SizedBox(height: 15),
            
            // 3. INPUT
            TextField(
                controller: aciklamaEdit,
                decoration: InputDecoration(
                    labelText: "Açıklama",
                    labelStyle: const TextStyle(fontSize: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
                maxLines: 3),
            
            const SizedBox(height: 25),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E201C),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('urunler')
                    .doc(urunId)
                    .update({
                  'urunAdi': adEdit.text,
                  'aciklama': aciklamaEdit.text,
                  'barkod': barkodEdit.text
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Değişiklikleri Kaydet",
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255), fontSize: 16)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _urunSil(String urunId) async {
    bool? onay = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("Ürünü Sil"),
                content: const Text("Emin misiniz?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Vazgeç")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Sil"))
                ]));
    if (onay == true)
      await FirebaseFirestore.instance
          .collection('urunler')
          .doc(urunId)
          .delete();
  }

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    final User? user = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        // 1. Arka Plan
        _buildBackground(),

        // 2. İçerik
        Scaffold(
          backgroundColor: Colors.transparent,
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              String adSoyad = userSnapshot.hasData
                  ? userSnapshot.data!['adSoyad'] ?? "Üretici"
                  : "Üretici";

              return SafeArea(
                // CustomScrollView yerine Column kullanıldı (Sabit Başlık Efekti için)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ÜST KISIM (Sabit) ---
                    // Merhaba ve İsim Alanı
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          birim * 0.06, birim * 0.06, birim * 0.06, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Merhaba",
                              style: TextStyle(
                                  fontSize: birim * 0.050,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold)),
                          Text(adSoyad,
                              style: TextStyle(
                                  fontSize: birim * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                        ],
                      ),
                    ),

                    // Arama Kutusu
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: birim * 0.06, vertical: birim * 0.04),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10)
                            ]),
                        child: TextField(
                            onChanged: (val) => setState(
                                () => _aramaKelimesi = val.toLowerCase()),
                            decoration: const InputDecoration(
                                hintText: "Ürünlerinizi arayın...",
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15))),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: birim * 0.06, vertical: birim * 0.02),
                      child: Text("Ürünlerim",
                          style: TextStyle(
                              fontSize: birim * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ),

                    // --- LİSTE KISMI (Kaydırılabilir - Expanded İçinde) ---
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('urunler')
                            .where('ureticiId', isEqualTo: user?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ));
                          }

                          var urunlerDocs = snapshot.data!.docs
                              .where((doc) => doc['urunAdi']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_aramaKelimesi))
                              .toList();

                          if (urunlerDocs.isEmpty) {
                            return Center(
                              child: Text("Henüz ürün yok.",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: birim * 0.04)),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                                birim * 0.06, 0, birim * 0.06, 100),
                            itemCount: urunlerDocs.length,
                            itemBuilder: (context, index) {
                              var urun = urunlerDocs[index].data()
                                  as Map<String, dynamic>;
                              return _buildUrunKarti(
                                  urunlerDocs[index].id, urun, index, birim);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUrunKarti(
      String id, Map<String, dynamic> urun, int index, double birim) {
    Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];

    return GestureDetector(
      onTap: () => _urunDetayPaneli(id, urun, kartRengi),
      child: Container(
        margin: EdgeInsets.only(bottom: birim * 0.04),
        height: birim * 0.32,
        padding: EdgeInsets.all(birim * 0.03),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4))
            ]),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                    color: kartRengi, borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.eco,
                    color: Colors.black.withOpacity(0.1), size: birim * 0.15),
              ),
            ),
            SizedBox(width: birim * 0.04),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    urun['urunAdi'] ?? "",
                    style: TextStyle(
                        fontSize: birim * 0.05,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E201C)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: birim * 0.001),
                  Text(urun['aciklama'] ?? "",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 43, 43, 43),
                          fontSize: birim * 0.04,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: birim * 0.02),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: kartRengi.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("Barkod: ${urun['barkod'] ?? '-'}",
                          style: TextStyle(
                              fontSize: birim * 0.030,
                              fontWeight: FontWeight.bold,
                              color: kartRengi)))
                ])),
          ],
        ),
      ),
    );
  }
}