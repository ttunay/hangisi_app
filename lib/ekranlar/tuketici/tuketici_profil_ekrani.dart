import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PointerDeviceKind;

class TuketiciProfilEkrani extends StatefulWidget {
  const TuketiciProfilEkrani({super.key});

  @override
  State<TuketiciProfilEkrani> createState() => _TuketiciProfilEkraniState();
}

class _TuketiciProfilEkraniState extends State<TuketiciProfilEkrani> {
  // Giriş yapmış kullanıcı (null olursa ekran data çekemez)
  final User? user = FirebaseAuth.instance.currentUser;

  // Edit sheet içindeki form doğrulaması için
  final _formKey = GlobalKey<FormState>();

  // Düzenleme alanları için controller'lar
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _hakkimdaController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();

  // Kaydet butonunda loading göstermek için
  bool _isSaving = false;

  // Favori ürün kartları için pastel renkler
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
    // Ekran kapanırken controller'ları temizle (memory leak olmasın)
    _adSoyadController.dispose();
    _hakkimdaController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  // ============================================================
  // 1) ARKA PLAN
  // ============================================================
  /// Arka plan:
  /// - Açık mavi zemin
  /// - Üstüne inekler görseli cover olarak serilir
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
  // 2) PROFİL DÜZENLEME SHEET
  // ============================================================
  /// Profili düzenleme paneli:
  /// - Ad Soyad, Konum, Hakkımda alanlarını gösterir
  /// - Kaydet ile Firestore'da kullanıcı dokümanını günceller
  void _showEditSheet() {
    // Kullanıcı yoksa (teorik olarak) sheet açmayalım
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // klavye açılınca yukarı çıksın
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.50,
          minChildSize: 0.45,
          maxChildSize: 0.50,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 20),

                      const Text(
                        "Profili Düzenle",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E201C),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Form alanları
                      _buildInput(_adSoyadController, "Ad Soyad", Icons.person),
                      const SizedBox(height: 15),
                      _buildInput(_konumController, "Konum", Icons.location_on),
                      const SizedBox(height: 15),
                      _buildInput(
                        _hakkimdaController,
                        "Hakkımda",
                        Icons.description,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Kaydet butonu
                      Center(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 0, 0),
                            minimumSize: const Size(45, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Kaydet",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Kaydet:
  /// - Form valid mi kontrol eder
  /// - Firestore'da kullanıcı dokümanını update eder
  /// - Başarılıysa sheet kapatır
  Future<void> _saveProfile() async {
    if (user == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user!.uid)
          .update({
        'adSoyad': _adSoyadController.text,
        'hakkimda': _hakkimdaController.text,
        'konum': _konumController.text,
      });

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  // 3) ORTAK INPUT WIDGET'I
  // ============================================================
  /// Edit sheet içinde kullanılan TextFormField
  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 70, 70, 70)),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF2D5A27)),
        ),
      ),
    );
  }

  // ============================================================
  // 4) MOUSE + TOUCH SCROLL DAVRANIŞI (DESKTOP/WEB)
  // ============================================================
  /// Mouse ile de drag/scroll çalışsın diye ScrollBehavior ayarlanır.
  ScrollBehavior _scrollBehavior(BuildContext context) {
    return ScrollConfiguration.of(context).copyWith(
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      },
    );
  }

  // ============================================================
  // 5) ANA BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Standart responsive birim (kısa kenar)
    final double birim = MediaQuery.of(context).size.shortestSide;

    // Avatar ve layout ölçüleri (orijinal davranış korunur)
    final double avatarDiameter = birim * 0.30;
    final double contentPadding = 30.0;

    return Stack(
      children: [
        _buildBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,

          // Kullanıcı dokümanı dinlenir:
          // adSoyad, hakkimda, konum ve favoriler buradan okunur
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Firestore verisi
              final data = snapshot.data!.data() as Map<String, dynamic>?;

              // Ekranda gösterilecek değerler (fallback ile)
              final String adSoyad = data?['adSoyad'] ?? "İsimsiz Kullanıcı";
              final String hakkimda =
                  data?['hakkimda'] ?? "Henüz bilgi girilmemiş.";
              final String konum = data?['konum'] ?? "Konum Yok";

              // Favoriler listesi: ürün id'leri array olarak tutuluyor
              final List favoriler = data?['favoriler'] ?? [];

              // Controller'ları sadece ilk kez doldur:
              // (Aksi halde her rebuild'de kullanıcının yazdıklarını geri ezebilir)
              if (_adSoyadController.text.isEmpty) {
                _adSoyadController.text = adSoyad;
              }
              if (_hakkimdaController.text.isEmpty) {
                _hakkimdaController.text = hakkimda;
              }
              if (_konumController.text.isEmpty) {
                _konumController.text = konum;
              }

              // ScrollConfiguration:
              // - Mouse ve touch ile scroll/drag rahat olsun
              return ScrollConfiguration(
                behavior: _scrollBehavior(context),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Üstte küçük boşluk (orijinalde SliverAppBar ile sağlanmış)
                    SliverAppBar(
                      stretch: true,
                      expandedHeight: size.height * 0.05,
                      pinned: false,
                      floating: false,
                      snap: false,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      systemOverlayStyle: SystemUiOverlayStyle.dark,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [StretchMode.zoomBackground],
                        background: Container(color: Colors.transparent),
                      ),
                    ),

                    // Profil içeriği (büyük beyaz panel + avatar + edit)
                    SliverToBoxAdapter(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Beyaz panel
                          Container(
                            margin: EdgeInsets.only(top: avatarDiameter / 2),
                            constraints: BoxConstraints(
                              minHeight: size.height * 0.7,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(40),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                contentPadding,
                                24,
                                contentPadding,
                                0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar için boşluk
                                  SizedBox(height: (avatarDiameter / 2) + 5),

                                  // Ad Soyad
                                  Text(
                                    adSoyad,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E201C),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Konum chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.deepOrange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.deepOrangeAccent,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            konum,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // Hakkımda başlığı
                                  Text(
                                    "Hakkımda",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),

                                  // Hakkımda içeriği
                                  Text(
                                    hakkimda,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),

                                  const SizedBox(height: 25),

                                  // İstatistik kutuları
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem(
                                          "Favoriler", "${favoriler.length}"),
                                      _buildStatItem("Takip", "124"),
                                      _buildStatItem("Puan", "4.8"),
                                    ],
                                  ),

                                  const SizedBox(height: 25),

                                  // Favoriler başlığı
                                  Text(
                                    "Favorilerim",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  // Favori ürünler yatay listesi
                                  SizedBox(
                                    height: birim * 0.45,
                                    child: ScrollConfiguration(
                                      behavior: _scrollBehavior(context),
                                      child: _FavoriUrunListesi(
                                        favoriler: favoriler,
                                        birim: birim,
                                        temaRenkleri: _temaRenkleri,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 50),
                                ],
                              ),
                            ),
                          ),

                          // Avatar (üstten taşan)
                          Positioned(
                            top: 0,
                            left: contentPadding,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 255, 255, 255),
                                  width: 6,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: avatarDiameter / 2,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage:
                                    const AssetImage('assets/tuketici.png'),
                              ),
                            ),
                          ),

                          // "Profili düzenle" (sağ üst)
                          Positioned(
                            top: (avatarDiameter / 2) + 20,
                            right: contentPadding,
                            child: InkWell(
                              onTap: _showEditSheet,
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  "Profili düzenle",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Altta beyaz alan devam etsin diye
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Container(color: Colors.white),
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
  // 6) İSTATİSTİK KUTUSU (DÜZELTİLMİŞ)
  // ============================================================
  /// Favoriler / Takip / Puan kutuları
  /// - Gereksiz Text("") kaldırıldı
  Widget _buildStatItem(String label, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromARGB(255, 146, 193, 231)),
      ),
      child: Column(
        children: [
          // Üstte sayı/değer
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          // Değer ile label arası boşluk
          const SizedBox(height: 4),
          // Altta label
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

/// Favori ürünleri yatay listeleyen küçük widget:
/// - urunler koleksiyonunu dinler
/// - favoriler listesinde olan ürünleri filtreler
/// - boşsa mesaj gösterir
class _FavoriUrunListesi extends StatelessWidget {
  final List favoriler;
  final double birim;
  final List<Color> temaRenkleri;

  const _FavoriUrunListesi({
    required this.favoriler,
    required this.birim,
    required this.temaRenkleri,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('urunler').snapshots(),
      builder: (context, urunSnapshot) {
        if (!urunSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Favorilerde olan ürünleri seç
        final favoriUrunler = urunSnapshot.data!.docs.where((doc) {
          return favoriler.contains(doc.id);
        }).toList();

        // Favori yoksa mesaj
        if (favoriUrunler.isEmpty) {
          return Center(
            child: Text(
              "Henüz favori ürününüz yok.",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        // Yatay liste
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: favoriUrunler.length,
          itemBuilder: (context, index) {
            final urun = favoriUrunler[index].data() as Map<String, dynamic>;
            final String name = urun['urunAdi'] ?? "";

            return _ProductCard(
              name: name,
              index: index,
              birim: birim,
              temaRenkleri: temaRenkleri,
            );
          },
        );
      },
    );
  }
}

/// Favori ürün kartı:
/// - Renkli kare + icon
/// - Altında ürün adı
class _ProductCard extends StatelessWidget {
  final String name;
  final int index;
  final double birim;
  final List<Color> temaRenkleri;

  const _ProductCard({
    required this.name,
    required this.index,
    required this.birim,
    required this.temaRenkleri,
  });

  @override
  Widget build(BuildContext context) {
    final Color kartRengi = temaRenkleri[index % temaRenkleri.length];

    return Container(
      width: birim * 0.28,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: kartRengi,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.eco,
                color: Colors.black.withOpacity(0.1),
                size: birim * 0.15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E201C),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
