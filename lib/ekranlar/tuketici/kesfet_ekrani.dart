import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'uretici_detay_sayfasi.dart';

/// KesfetEkrani:
/// - Firestore'dan ürünleri çeker ve listeler
/// - Arama kutusu ile ürün adına göre filtreler
/// - Barkod ile arama yapabilir (bottom sheet açılır)
/// - Favori ekle/çıkar (kullanıcı dokümanındaki 'favoriler' array alanı)
/// - Ürüne tıklanınca detay bottom sheet açılır (DraggableScrollableSheet)
class KesfetEkrani extends StatefulWidget {
  const KesfetEkrani({super.key});

  @override
  State<KesfetEkrani> createState() => _KesfetEkraniState();
}

class _KesfetEkraniState extends State<KesfetEkrani> {
  // Arama (ürün adı) için input
  final TextEditingController _aramaController = TextEditingController();

  // Barkod araması için input
  final TextEditingController _barkodController = TextEditingController();

  // Arama filtreleri (küçük harfe çevrilmiş şekilde tutuluyor)
  String _aramaKelimesi = "";
  String _barkodKelimesi = "";

  // Ürün kartlarında kullanılacak pastel renkler (sıra ile döner)
  final List<Color> _temaRenkleri = [
    const Color.fromARGB(255, 250, 245, 197),
    const Color.fromARGB(255, 243, 204, 203),
    const Color.fromARGB(255, 226, 194, 164),
    const Color.fromARGB(255, 205, 233, 182),
    const Color.fromARGB(255, 188, 209, 233),
    const Color.fromARGB(255, 182, 236, 232),
  ];

  @override
  void dispose() {
    // Ekran kapanırken controller'ları temizle
    _aramaController.dispose();
    _barkodController.dispose();
    super.dispose();
  }

  // ============================================================
  // 1) ARKA PLAN
  // ============================================================
  /// Arka plan:
  /// - Açık mavi bir zemin
  /// - Üstüne inekler görseli kaplanır
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
  // 2) BARKOD ARAMA BOTTOM SHEET
  // ============================================================
  /// Barkod araması için alttan panel açar.
  /// - Kullanıcı barkod girer
  /// - "Sorgula" ile _barkodKelimesi set edilir
  /// - Arama kelimesi (_aramaKelimesi) etkisiz hale gelir (ürün adı yerine barkod eşitliği aranır)
  void _barkodAramaGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // klavye açılınca panelin yükselmesi için
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        // Burada da birim kullanabiliriz ama mevcut görünümü bozmamak için
        // orijinal değerleri büyük ölçüde koruyoruz.
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 30,
            right: 30,
            top: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Barkod İle Ara",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _barkodController,
                decoration: InputDecoration(
                  hintText: "Barkod numarasını girin...",
                  prefixIcon: const Icon(
                    Icons.qr_code_scanner,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E201C),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Barkod filtresini aktif et
                  setState(() {
                    _barkodKelimesi =
                        _barkodController.text.trim().toLowerCase();
                  });

                  // Paneli kapat
                  Navigator.pop(sheetContext);
                },
                child: const Text(
                  "Sorgula",
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
  // 3) FAVORİ EKLE / ÇIKAR
  // ============================================================
  /// Kullanıcının Firestore dokümanındaki 'favoriler' alanını günceller.
  /// - isFavorite true ise remove
  /// - isFavorite false ise add
  Future<void> _favoriGuncelle(String urunId, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid);

    if (isFavorite) {
      await userRef.update({
        'favoriler': FieldValue.arrayRemove([urunId]),
      });
    } else {
      await userRef.update({
        'favoriler': FieldValue.arrayUnion([urunId]),
      });
    }
  }

  // ============================================================
  // 4) ÜRETİCİ BİLGİSİ (DETAY PANELİ İÇİN)
  // ============================================================
  /// Ürün detay panelinde üreticiyi göstermek için Firestore'dan üretici bilgisi çekilir.
  /// - Üretici kartına tıklanınca UreticiDetaySayfasi açılır.
  Widget _buildUreticiBilgisi(String? ureticiId, double birim) {
    if (ureticiId == null || ureticiId.isEmpty) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(ureticiId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final ureticiData = snapshot.data!.data() as Map<String, dynamic>;
        final String adSoyad = ureticiData['adSoyad'] ?? "Bilinmeyen Üretici";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UreticiDetaySayfasi(
                  ureticiId: ureticiId,
                  adSoyad: adSoyad,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: birim * 0.04),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: birim * 0.06,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: const AssetImage('assets/uretici.png'),
                ),
                SizedBox(width: birim * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Üretici",
                        style: TextStyle(
                          fontSize: birim * 0.04,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        adSoyad,
                        style: TextStyle(
                          fontSize: birim * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 5) ÜRÜN DETAY PANELİ
  // ============================================================
  /// Ürün kartına tıklanınca alttan detay paneli açılır.
  /// - DraggableScrollableSheet ile yukarı-aşağı sürüklenebilir
  /// - Ürün bilgilerini satır satır gösterir
  void _urunDetayGoster(Map<String, dynamic> urun, Color kartRengi) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    final String ureticiId = urun['ureticiId'] ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.80,
          maxChildSize: 0.85,
          minChildSize: 0.80,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(birim * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üstte küçük sürükleme çubuğu
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

                  // Ürün görsel alanı (şimdilik icon)
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

                  // Barkod satırı
                  Text(
                    "Barkod: ${urun['barkod'] ?? '-'}",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Üretici kartı
                  _buildUreticiBilgisi(ureticiId, birim),

                  SizedBox(height: birim * 0.02),

                  // Detay satırları
                  _detaySatiri(
                    Icons.description_outlined,
                    "Açıklama",
                    urun['aciklama'] ?? "-",
                    birim,
                  ),
                  _detaySatiri(
                    Icons.grass_outlined,
                    "Tohum",
                    urun['tohum'] ?? "-",
                    birim,
                  ),
                  _detaySatiri(
                    Icons.opacity_outlined,
                    "Gübre",
                    urun['gubre'] ?? "-",
                    birim,
                  ),
                  _detaySatiri(
                    Icons.sanitizer_outlined,
                    "İlaçlama",
                    urun['ilac'] ?? "-",
                    birim,
                  ),

                  SizedBox(height: birim * 0.02),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Detay panelinde kullanılan tek satırlık bilgi widget'ı
  Widget _detaySatiri(IconData icon, String baslik, String icerik, double birim) {
    return Padding(
      padding: EdgeInsets.only(bottom: birim * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: birim * 0.06,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
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
                  style: TextStyle(
                    fontSize: birim * 0.040,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 6) ÜST BAŞLIK (SABİT ALAN)
  // ============================================================
  Widget _buildHeader(double birim) {
    return Padding(
      padding: EdgeInsets.fromLTRB(birim * 0.06, birim * 0.06, birim * 0.06, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol tarafta 2 satır başlık
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Taze ve Sağlıklı",
                style: TextStyle(
                  fontSize: birim * 0.050,
                  color: const Color.fromARGB(255, 70, 70, 70),
                ),
              ),
              Text(
                "Yeni Ürünler Keşfet",
                style: TextStyle(
                  fontSize: birim * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Sağ tarafta barkod arama butonu
          GestureDetector(
            onTap: _barkodAramaGoster,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 7) ARAMA KUTUSU
  // ============================================================
  Widget _buildSearchBox(double birim) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: birim * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            )
          ],
        ),
        child: TextField(
          controller: _aramaController,
          onChanged: (val) {
            // Ürün adı araması aktif olunca barkod filtresi sıfırlanıyor
            setState(() {
              _aramaKelimesi = val.toLowerCase();
              _barkodKelimesi = "";
            });
          },
          decoration: const InputDecoration(
            hintText: "Ürün arayın...",
            prefixIcon: Icon(Icons.search, color: Color(0xFF2D5A27)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 8) BARKOD ÇİPİ
  // ============================================================
  Widget _buildBarcodeChip(double birim) {
    return Padding(
      padding: EdgeInsets.only(bottom: birim * 0.04),
      child: Chip(
        label: Text("Barkod: $_barkodKelimesi"),
        onDeleted: () => setState(() => _barkodKelimesi = ""),
        backgroundColor: Colors.white,
        deleteIconColor: Colors.red,
      ),
    );
  }

  // ============================================================
  // 9) ÜRÜN KARTI
  // ============================================================
  /// Listede görünen tek ürün kartı.
  /// - Kart tıklanınca detay paneli açılır
  /// - Kalp ikonuna basınca favori ekle/çıkar olur
  Widget _buildUrunKarti({
    required double birim,
    required Map<String, dynamic> urun,
    required String urunId,
    required bool isFavorite,
    required Color kartRengi,
  }) {
    return GestureDetector(
      onTap: () => _urunDetayGoster(urun, kartRengi),
      child: Container(
        margin: EdgeInsets.only(bottom: birim * 0.04),
        height: birim * 0.32, // orijinal değer korunuyor
        padding: EdgeInsets.all(birim * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Sol tarafta renkli kare (ikon alanı)
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

                // Sağ tarafta metinler
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

                      // Barkod satırı
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

                      // Açıklama
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

            // Sağ üst köşede favori ikonu
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => _favoriGuncelle(urunId, isFavorite),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 10) ANA BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    final user = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        _buildBackground(),

        // Arka plan üstünde saydam Scaffold kullanıyoruz
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst sabit başlık alanı
                _buildHeader(birim),

                // Alt kısım: scroll edilebilir alan
                Expanded(
                  // 1) Kullanıcının favorilerini takip etmek için user dokümanını dinliyoruz
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('kullanicilar')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      // Favori listesi: kullanıcı dokümanından okunur
                      List favoriIds = [];
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        favoriIds =
                            (userSnapshot.data!.data() as Map<String, dynamic>)['favoriler'] ??
                                [];
                      }

                      // 2) Ürünleri dinliyoruz
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('urunler')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          // Ürünleri filtreliyoruz:
                          // - Barkod araması aktifse barkod == barkodKelimesi
                          // - Değilse ürün adı aramaKelimesi içeriyor mu?
                          final docs = snapshot.data!.docs.where((doc) {
                            final urunVerisi = doc.data() as Map<String, dynamic>;

                            final String urunAdi =
                                urunVerisi['urunAdi']?.toString().toLowerCase() ?? "";
                            final String barkod =
                                urunVerisi['barkod']?.toString().toLowerCase() ?? "";

                            if (_barkodKelimesi.isNotEmpty) {
                              return barkod == _barkodKelimesi;
                            }

                            return urunAdi.contains(_aramaKelimesi);
                          }).toList();

                          // Listeyi çiziyoruz
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                            children: [
                              // 1) Arama kutusu
                              _buildSearchBox(birim),

                              // 2) Barkod chip (varsa)
                              if (_barkodKelimesi.isNotEmpty) _buildBarcodeChip(birim),

                              // 3) Ürün listesi
                              if (docs.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: birim * 0.1),
                                  child: Center(
                                    child: Text(
                                      "Ürün bulunamadı.",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: birim * 0.04,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...docs.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final doc = entry.value;

                                  final urun = doc.data() as Map<String, dynamic>;
                                  final String urunId = doc.id;

                                  final bool isFavorite = favoriIds.contains(urunId);

                                  // Kart rengi: pastel renklerden sırayla seç
                                  final Color kartRengi =
                                      _temaRenkleri[index % _temaRenkleri.length];

                                  return _buildUrunKarti(
                                    birim: birim,
                                    urun: urun,
                                    urunId: urunId,
                                    isFavorite: isFavorite,
                                    kartRengi: kartRengi,
                                  );
                                }).toList(),

                              // Alt tarafta biraz boşluk (floating navbar çakışmasın)
                              const SizedBox(height: 100),
                            ],
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
