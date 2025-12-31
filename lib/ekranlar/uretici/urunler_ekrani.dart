import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UrunlerEkrani extends StatefulWidget {
  const UrunlerEkrani({super.key});

  @override
  State<UrunlerEkrani> createState() => _UrunlerEkraniState();
}

class _UrunlerEkraniState extends State<UrunlerEkrani> {
  // Arama kutusuna yazılan metni burada tutuyoruz (küçük harfe çevrilerek)
  String _aramaKelimesi = "";

  // Kartlarda döngüyle kullanılan pastel renkler
  final List<Color> _temaRenkleri = const [
    Color.fromARGB(255, 250, 245, 197),
    Color.fromARGB(255, 243, 204, 203),
    Color.fromARGB(255, 226, 194, 164),
    Color.fromARGB(255, 205, 233, 182),
    Color.fromARGB(255, 188, 209, 233),
    Color.fromARGB(255, 182, 236, 232),
  ];

  // ============================================================
  // 1) ARKA PLAN
  // ============================================================
  /// Arka plan:
  /// - Açık mavi zemin rengi
  /// - Üstüne "inekler.png" cover olarak serilir
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color.fromARGB(255, 228, 242, 247)),
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

  // ============================================================
  // 2) ÜRÜN DETAY PANELİ (BOTTOM SHEET)
  // ============================================================
  /// Bir ürün kartına tıklanınca açılan detay bottom sheet.
  /// İçeride:
  /// - Ürün adı, barkod ve detay alanları
  /// - "Düzenle" ve "Sil" butonları
  void _urunDetayPaneli(String urunId, Map<String, dynamic> urun, Color kartRengi) {
    final double birim = MediaQuery.of(context).size.shortestSide;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.80,
        minChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(birim * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tutma çubuğu (üstteki küçük gri çizgi)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: birim * 0.06),

                // Ürün görsel alanı (şimdilik icon + renk)
                Container(
                  width: double.infinity,
                  height: birim * 0.4,
                  decoration: BoxDecoration(
                    color: kartRengi,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.eco, size: 80, color: Colors.black12),
                ),
                SizedBox(height: birim * 0.06),

                // Ürün adı
                Text(
                  urun['urunAdi'] ?? "",
                  style: TextStyle(
                    fontSize: birim * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Barkod
                Text(
                  "Barkod: ${urun['barkod'] ?? '-'}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: birim * 0.06),

                // Detay satırları
                _detaySatiri(Icons.description_outlined, "Açıklama", urun['aciklama'] ?? "-", birim),
                _detaySatiri(Icons.grass_outlined, "Tohum", urun['tohum'] ?? "-", birim),
                _detaySatiri(Icons.opacity_outlined, "Gübre", urun['gubre'] ?? "-", birim),
                _detaySatiri(Icons.sanitizer_outlined, "İlaçlama", urun['ilac'] ?? "-", birim),

                SizedBox(height: birim * 0.01),

                // Düzenle / Sil butonları
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Önce panel kapanır, sonra düzenleme açılır
                          Navigator.pop(bottomSheetContext);
                          _urunDuzenle(urunId, urun);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text("Düzenle"),
                      ),
                    ),
                    SizedBox(width: birim * 0.04),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Önce panel kapanır, sonra silme sorulur
                          Navigator.pop(bottomSheetContext);
                          _urunSil(urunId);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Sil"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB92A2F),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Detay panelindeki her satır (ikon + başlık + içerik)
  Widget _detaySatiri(IconData icon, String baslik, String icerik, double birim) {
    return Padding(
      padding: EdgeInsets.only(bottom: birim * 0.04),
      child: Row(
        children: [
          Icon(icon, size: birim * 0.06, color: const Color.fromARGB(255, 0, 0, 0)),
          SizedBox(width: birim * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: birim * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  icerik,
                  style: TextStyle(fontSize: birim * 0.040, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3) ÜRÜN DÜZENLEME (BOTTOM SHEET)
  // ============================================================
  /// Düzenle butonuna basınca açılan sheet.
  /// Kullanıcı ürün adı/barkod/açıklamayı değiştirip kaydedebilir.
  void _urunDuzenle(String urunId, Map<String, dynamic> urun) {
    // Mevcut değerlerle dolu controller'lar
    final TextEditingController adEdit = TextEditingController(text: urun['urunAdi']);
    final TextEditingController barkodEdit = TextEditingController(text: urun['barkod']);
    final TextEditingController aciklamaEdit = TextEditingController(text: urun['aciklama']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 30,
            right: 30,
            top: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ürünü Düzenle",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Ürün adı
              TextField(
                controller: adEdit,
                decoration: InputDecoration(
                  labelText: "Ürün Adı",
                  labelStyle: const TextStyle(fontSize: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),

              // Barkod
              TextField(
                controller: barkodEdit,
                decoration: InputDecoration(
                  labelText: "Barkod",
                  labelStyle: const TextStyle(fontSize: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),

              // Açıklama
              TextField(
                controller: aciklamaEdit,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Açıklama",
                  labelStyle: const TextStyle(fontSize: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 25),

              // Kaydet butonu -> Firestore update
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E201C),
                  minimumSize: const Size(60, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('urunler').doc(urunId).update({
                    'urunAdi': adEdit.text,
                    'barkod': barkodEdit.text,
                    'aciklama': aciklamaEdit.text,
                  });

                  if (bottomSheetContext.mounted) Navigator.pop(bottomSheetContext);
                },
                child: const Text(
                  "Değişiklikleri Kaydet",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 4) ÜRÜN SİLME (ONAY DİYALOĞU)
  // ============================================================
  /// Sil butonuna basınca önce onay sorar.
  /// Onay gelirse ürünü Firestore'dan siler.
  Future<void> _urunSil(String urunId) async {
    final bool? onay = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Ürünü Sil"),
        content: const Text("Emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (onay == true) {
      await FirebaseFirestore.instance.collection('urunler').doc(urunId).delete();
    }
  }

  // ============================================================
  // 5) ANA BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Responsive birim: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    // Giriş yapmış kullanıcı
    final User? user = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        // 1) Arka plan
        _buildBackground(),

        // 2) Sayfa içeriği
        Scaffold(
          backgroundColor: Colors.transparent,

          // Kullanıcının adSoyad bilgisini dinleyip üstte gösteriyoruz
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
            builder: (context, userSnapshot) {
              // Varsayılan isim
              String adSoyad = "Üretici";

              // Veri geldiyse adSoyad al
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data() as Map<String, dynamic>;
                adSoyad = data['adSoyad'] ?? "Üretici";
              }

              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =====================================================
                    // ÜST SABİT ALAN: "Merhaba" + adSoyad
                    // =====================================================
                    Padding(
                      padding: EdgeInsets.fromLTRB(birim * 0.06, birim * 0.06, birim * 0.06, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Merhaba",
                            style: TextStyle(
                              fontSize: birim * 0.050,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            adSoyad,
                            style: TextStyle(
                              fontSize: birim * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =====================================================
                    // ALT KISIM: Arama + Ürün listesi (kaydırılabilir)
                    // =====================================================
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
                              ),
                            );
                          }

                          // Ürünleri arama kelimesine göre filtrele
                          final List<QueryDocumentSnapshot> urunlerDocs = snapshot.data!.docs.where((doc) {
                            final String urunAdi = doc['urunAdi'].toString().toLowerCase();
                            return urunAdi.contains(_aramaKelimesi);
                          }).toList();

                          // ListView içinde:
                          // - arama kutusu
                          // - başlık
                          // - ürün kartları
                          return ListView(
                            padding: EdgeInsets.fromLTRB(birim * 0.06, 0, birim * 0.06, 100),
                            children: [
                              // Arama kutusu
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: birim * 0.04),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() => _aramaKelimesi = val.toLowerCase());
                                    },
                                    decoration: const InputDecoration(
                                      hintText: "Ürünlerinizi arayın...",
                                      prefixIcon: Icon(Icons.search),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                                    ),
                                  ),
                                ),
                              ),

                              // "Ürünlerim" başlığı
                              Padding(
                                padding: EdgeInsets.only(bottom: birim * 0.02),
                                child: Text(
                                  "Ürünlerim",
                                  style: TextStyle(
                                    fontSize: birim * 0.055,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Ürün yoksa mesaj, varsa kartlar
                              if (urunlerDocs.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: birim * 0.1),
                                    child: Text(
                                      "Henüz ürün yok.",
                                      style: TextStyle(color: Colors.black54, fontSize: birim * 0.04),
                                    ),
                                  ),
                                )
                              else
                                ...urunlerDocs.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final doc = entry.value;
                                  final urun = doc.data() as Map<String, dynamic>;

                                  return _buildUrunKarti(
                                    urunId: doc.id,
                                    urun: urun,
                                    index: index,
                                    birim: birim,
                                  );
                                }),
                            ],
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

  // ============================================================
  // 6) ÜRÜN KARTI
  // ============================================================
  /// Listede görünen ürün kartı.
  /// Tıklanınca detay panelini açar.
  Widget _buildUrunKarti({
    required String urunId,
    required Map<String, dynamic> urun,
    required int index,
    required double birim,
  }) {
    final Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];

    return GestureDetector(
      onTap: () => _urunDetayPaneli(urunId, urun, kartRengi),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sol görsel kutu
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: kartRengi,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.eco,
                  color: Colors.black.withOpacity(0.1),
                  size: birim * 0.15,
                ),
              ),
            ),
            SizedBox(width: birim * 0.04),

            // Sağ yazı alanı
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ürün adı
                  Text(
                    urun['urunAdi'] ?? "",
                    style: TextStyle(
                      fontSize: birim * 0.05,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E201C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Barkod
                  SizedBox(height: birim * 0.005),
                  Text(
                    "Barkod: ${urun['barkod'] ?? '-'}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: birim * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: birim * 0.01),

                  // Açıklama (2 satır)
                  Text(
                    urun['aciklama'] ?? "",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 43, 43, 43),
                      fontSize: birim * 0.04,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
