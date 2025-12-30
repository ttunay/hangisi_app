import 'dart:ui'; // Glassmorphism için gerekli
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KesfetEkrani extends StatefulWidget {
  const KesfetEkrani({super.key});

  @override
  State<KesfetEkrani> createState() => _KesfetEkraniState();
}

class _KesfetEkraniState extends State<KesfetEkrani> {
  final TextEditingController _aramaController = TextEditingController();
  final TextEditingController _barkodController = TextEditingController();
  String _aramaKelimesi = "";
  String _barkodKelimesi = "";

  // UrunlerEkrani'ndaki Pastel Renkler
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
        Container(color: Color.fromARGB(255, 228, 242, 247)), // Zemin Rengi
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

  void _barkodAramaGoster() {
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
            const Text("Barkod İle Ara",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _barkodController,
              decoration: InputDecoration(
                hintText: "Barkod numarasını girin...",
                prefixIcon: const Icon(Icons.qr_code_scanner,
                    color: Color.fromARGB(255, 0, 0, 0)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E201C),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                setState(() => _barkodKelimesi =
                    _barkodController.text.trim().toLowerCase());
                Navigator.pop(context);
              },
              child: const Text("Sorgula",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _favoriGuncelle(String urunId, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef =
        FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid);
    if (isFavorite) {
      await userRef.update({
        'favoriler': FieldValue.arrayRemove([urunId])
      });
    } else {
      await userRef.update({
        'favoriler': FieldValue.arrayUnion([urunId])
      });
    }
  }

  // --- ÜRÜN DETAY PANELİ ---
  void _urunDetayGoster(Map<String, dynamic> urun, Color kartRengi) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    final user = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        // 1. ARKA PLAN
        _buildBackground(),

        // 2. İÇERİK
        Scaffold(
          backgroundColor: Colors.transparent, // Arka plan görünsün diye
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SABİT KISIM (BAŞLIK & ARAMA) ---
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      birim * 0.06, birim * 0.06, birim * 0.06, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Taze ve Sağlıklı",
                                style: TextStyle(
                                    fontSize: birim * 0.050,
                                    color:
                                        const Color.fromARGB(255, 70, 70, 70))),
                            Text("Yeni Ürünler Keşfet",
                                style: TextStyle(
                                    fontSize: birim * 0.07,
                                    fontWeight: FontWeight.bold)),
                          ]),
                      GestureDetector(
                        onTap: _barkodAramaGoster,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              borderRadius: BorderRadius.circular(15)),
                          child: const Icon(Icons.qr_code_scanner,
                              color: Colors.white, size: 28),
                        ),
                      )
                    ],
                  ),
                ),

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
                      controller: _aramaController,
                      onChanged: (val) {
                        setState(() {
                          _aramaKelimesi = val.toLowerCase();
                          _barkodKelimesi = "";
                        });
                      },
                      decoration: const InputDecoration(
                          hintText: "Ürün arayın...",
                          prefixIcon:
                              Icon(Icons.search, color: Color(0xFF2D5A27)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15)),
                    ),
                  ),
                ),

                if (_barkodKelimesi.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                    child: Chip(
                      label: Text("Barkod: $_barkodKelimesi"),
                      onDeleted: () => setState(() => _barkodKelimesi = ""),
                      backgroundColor: Colors.white,
                      deleteIconColor: Colors.red,
                    ),
                  ),

                // --- KAYDIRILABİLİR KISIM (LİSTE) ---
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('kullanicilar')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      List favoriIds = [];
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        favoriIds = (userSnapshot.data!.data()
                                as Map<String, dynamic>)['favoriler'] ??
                            [];
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('urunler')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          var docs = snapshot.data!.docs.where((doc) {
                            var urunVerisi = doc.data() as Map<String, dynamic>;
                            String urunAdi = urunVerisi['urunAdi']
                                    ?.toString()
                                    .toLowerCase() ??
                                "";
                            String barkod = urunVerisi['barkod']
                                    ?.toString()
                                    .toLowerCase() ??
                                "";

                            if (_barkodKelimesi.isNotEmpty) {
                              return barkod == _barkodKelimesi;
                            }
                            return urunAdi.contains(_aramaKelimesi);
                          }).toList();

                          if (docs.isEmpty) {
                            return Center(
                                child: Text("Ürün bulunamadı.",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: birim * 0.04)));
                          }

                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(), // Yaylanma efekti için
                            padding: EdgeInsets.symmetric(
                                horizontal: birim * 0.06),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              var urun =
                                  docs[index].data() as Map<String, dynamic>;
                              String urunId = docs[index].id;
                              bool isFavorite = favoriIds.contains(urunId);
                              Color kartRengi =
                                  _temaRenkleri[index % _temaRenkleri.length];

                              // --- KART TASARIMI ---
                              return GestureDetector(
                                onTap: () =>
                                    _urunDetayGoster(urun, kartRengi),
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: birim * 0.04),
                                  height: birim * 0.32,
                                  padding: EdgeInsets.all(birim * 0.03),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.05),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4))
                                      ]),
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: kartRengi,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Icon(Icons.eco,
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  size: birim * 0.15),
                                            ),
                                          ),
                                          SizedBox(width: birim * 0.04),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  urun['urunAdi'] ?? "",
                                                  style: TextStyle(
                                                      fontSize: birim * 0.05,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: const Color(
                                                          0xFF1E201C)),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                    height: birim * 0.001),
                                                Text(
                                                  urun['aciklama'] ?? "",
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 43, 43, 43),
                                                      fontSize: birim * 0.04,
                                                      height: 1.2),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                    height: birim * 0.02),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                  decoration: BoxDecoration(
                                                      color: kartRengi
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8)),
                                                  child: Text(
                                                      "Barkod: ${urun['barkod'] ?? '-'}",
                                                      style: TextStyle(
                                                          fontSize:
                                                              birim * 0.030,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: kartRengi)),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // FAVORİ BUTONU
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () => _favoriGuncelle(
                                              urunId, isFavorite),
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.grey
                                                    .withOpacity(0.5),
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}