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

  final List<Color> _temaRenkleri = [
    const Color(0xFFB92A2F), // Domates Kırmızısı
    const Color(0xFF2D5A27), // Koyu Yaprak Yeşili
    const Color(0xFFE23E44), // Parlak Kırmızı
    const Color(0xFF4F772D), // Çimen Yeşili
  ];

  void _barkodAramaGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 30, right: 30, top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Barkod İle Ara", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _barkodController,
              decoration: InputDecoration(
                hintText: "Barkod numarasını girin...",
                prefixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2D5A27)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                setState(() => _barkodKelimesi = _barkodController.text.trim().toLowerCase());
                Navigator.pop(context);
              },
              child: const Text("Sorgula", style: TextStyle(color: Colors.white)),
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
    final userRef = FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid);
    if (isFavorite) {
      await userRef.update({'favoriler': FieldValue.arrayRemove([urunId])});
    } else {
      await userRef.update({'favoriler': FieldValue.arrayUnion([urunId])});
    }
  }

  void _urunDetayGoster(Map<String, dynamic> urun, Color kartRengi) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(birim * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Container(width: double.infinity, height: birim * 0.4, decoration: BoxDecoration(color: kartRengi, borderRadius: BorderRadius.circular(25)), child: const Icon(Icons.eco, size: 80, color: Colors.black12)),
              const SizedBox(height: 20),
              // Ürün ismi büyütüldü
              Text(urun['urunAdi'] ?? "", style: TextStyle(fontSize: birim * 0.10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _detayBilgi(Icons.qr_code_2_outlined, "Ürün Barkodu", urun['barkod'] ?? "Barkod Bilgisi Yok"),
              _detayBilgi(Icons.grass_outlined, "Tohum Türü", urun['tohum'] ?? "-"),
              _detayBilgi(Icons.opacity_outlined, "Gübre", urun['gubre'] ?? "-"),
              _detayBilgi(Icons.sanitizer_outlined, "İlaçlama", urun['ilac'] ?? "-"),
              _detayBilgi(Icons.description_outlined, "Açıklama", urun['aciklama'] ?? "-"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detayBilgi(IconData icon, String baslik, String icerik) {
    // Detay metinleri 16'dan 20'ye çıkarıldı
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2D5A27), size: 26), 
          const SizedBox(width: 12), 
          Expanded(
            child: Text(
              "$baslik: $icerik", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
            )
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(birim * 0.06, birim * 0.06, birim * 0.06, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Taze ve Sağlıklı", style: TextStyle(fontSize: birim * 0.045, color: Colors.grey.shade600)),
                    Text("Yeni Ürünler Keşfet", style: TextStyle(fontSize: birim * 0.07, fontWeight: FontWeight.bold)),
                  ]),
                  GestureDetector(
                    onTap: _barkodAramaGoster,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF2D5A27), borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: birim * 0.06, vertical: birim * 0.04),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: TextField(
                  controller: _aramaController,
                  onChanged: (val) {
                    setState(() {
                      _aramaKelimesi = val.toLowerCase();
                      _barkodKelimesi = ""; 
                    });
                  },
                  decoration: const InputDecoration(hintText: "Ürün arayın...", prefixIcon: Icon(Icons.search, color: Color(0xFF2D5A27)), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
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
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
                builder: (context, userSnapshot) {
                  List favoriIds = [];
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    favoriIds = (userSnapshot.data!.data() as Map<String, dynamic>)['favoriler'] ?? [];
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('urunler').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      var docs = snapshot.data!.docs.where((doc) {
                        var urunVerisi = doc.data() as Map<String, dynamic>;
                        String urunAdi = urunVerisi['urunAdi']?.toString().toLowerCase() ?? "";
                        String barkod = urunVerisi['barkod']?.toString().toLowerCase() ?? "";
                        
                        if (_barkodKelimesi.isNotEmpty) {
                          return barkod == _barkodKelimesi;
                        }
                        return urunAdi.contains(_aramaKelimesi);
                      }).toList();

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var urun = docs[index].data() as Map<String, dynamic>;
                          String urunId = docs[index].id;
                          bool isFavorite = favoriIds.contains(urunId);
                          Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];

                          return GestureDetector(
                            onTap: () => _urunDetayGoster(urun, kartRengi),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              height: birim * 0.45,
                              padding: EdgeInsets.all(birim * 0.05),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))]),
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Expanded(flex: 2, child: Container(height: double.infinity, decoration: BoxDecoration(color: kartRengi, borderRadius: BorderRadius.circular(22)), child: Icon(Icons.eco, color: Colors.black.withOpacity(0.1), size: birim * 0.18))),
                                      const SizedBox(width: 15),
                                      Expanded(flex: 3, child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start, 
                                        crossAxisAlignment: CrossAxisAlignment.start, 
                                        children: [
                                          const SizedBox(height: 5), 
                                          Text(urun['urunAdi'] ?? "", style: TextStyle(fontSize: birim * 0.055, fontWeight: FontWeight.w900)),
                                          Text("Barkod: ${urun['barkod'] ?? '-'}", style: TextStyle(color: Colors.black87, fontSize: birim * 0.032, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 8), 
                                          Text(urun['aciklama'] ?? "", style: TextStyle(color: Colors.black, fontSize: birim * 0.035, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
                                        ]
                                      )),
                                    ]
                                  ),
                                  Positioned(
                                    top: 0, right: 0,
                                    child: IconButton(
                                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                                      onPressed: () => _favoriGuncelle(urunId, isFavorite),
                                    ),
                                  ),
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
    );
  }
}