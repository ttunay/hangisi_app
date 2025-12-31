import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class UreticiProfilEkrani extends StatefulWidget {
  const UreticiProfilEkrani({super.key});

  @override
  State<UreticiProfilEkrani> createState() => _UreticiProfilEkraniState();
}

class _UreticiProfilEkraniState extends State<UreticiProfilEkrani> {
  // Giriş yapan kullanıcı
  final User? user = FirebaseAuth.instance.currentUser;

  // Form kontrol anahtarı (validate için)
  final _formKey = GlobalKey<FormState>();

  // ----- Controller'lar -----
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _ciftlikBilgisiController = TextEditingController();
  final TextEditingController _hakkimdaController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();

  // Kaydetme esnasında butonu disable etmek için
  bool _isSaving = false;

  // Pastel tema renkleri
  final List<Color> _temaRenkleri = const [
    Color.fromARGB(255, 250, 245, 197),
    Color.fromARGB(255, 243, 204, 203),
    Color.fromARGB(255, 226, 194, 164),
    Color.fromARGB(255, 205, 233, 182),
    Color.fromARGB(255, 188, 209, 233),
    Color.fromARGB(255, 182, 236, 232),
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _ciftlikBilgisiController.dispose();
    _hakkimdaController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  // ============================================================
  // 1) ARKA PLAN
  // ============================================================
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
  // 2) PROFİL DÜZENLE SHEET
  // ============================================================
  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.60,
        minChildSize: 0.55,
        maxChildSize: 0.60,
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
                    // Tutma çizgisi
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

                    _buildInput(_adSoyadController, "Ad Soyad", Icons.person),
                    const SizedBox(height: 15),
                    _buildInput(_ciftlikBilgisiController, "Çiftlik İsmi", Icons.agriculture),
                    const SizedBox(height: 15),
                    _buildInput(_konumController, "Konum", Icons.location_on),
                    const SizedBox(height: 15),
                    _buildInput(_hakkimdaController, "Hakkımda", Icons.description, maxLines: 3),

                    const SizedBox(height: 30),

                    // Kaydet Butonu
                    Center(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          minimumSize: const Size(45, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Kaydet",
                                style: TextStyle(color: Colors.white, fontSize: 18),
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
      ),
    );
  }

  /// Form valid ise Firestore güncellemesi yapar
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    if (user == null) return;

    setState(() => _isSaving = true);

    await FirebaseFirestore.instance.collection('kullanicilar').doc(user!.uid).update({
      'adSoyad': _adSoyadController.text,
      'ciftlikBilgisi': _ciftlikBilgisiController.text,
      'hakkimda': _hakkimdaController.text,
      'konum': _konumController.text,
    });

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  // Edit sheet input alanı (tekrarı azaltmak için)
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
  // 3) ANA BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;

    final double avatarDiameter = birim * 0.30;
    final double contentPadding = 30.0;

    return Stack(
      children: [
        // Arka plan (inekler + zemin)
        _buildBackground(),

        // Üstteki içerik
        Scaffold(
          backgroundColor: Colors.transparent,
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Firestore'dan gelen profil verileri
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final String adSoyad = data?['adSoyad'] ?? "İsimsiz Üretici";
              final String ciftlik = data?['ciftlikBilgisi'] ?? "Çiftlik Bilgisi Yok";
              final String hakkimda = data?['hakkimda'] ?? "Henüz bilgi girilmemiş.";
              final String konum = data?['konum'] ?? "Konum Yok";

              // Controller'ları sadece 1 kere doldur (sayfa sürekli rebuild oluyor)
              _fillControllersIfEmpty(
                adSoyad: adSoyad,
                ciftlik: ciftlik,
                hakkimda: hakkimda,
                konum: konum,
              );

              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // Üstte boş / şeffaf appbar alanı (tasarım için)
                  SliverAppBar(
                    stretch: true,
                    expandedHeight: size.height * 0.05,
                    pinned: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      background: Container(color: Colors.transparent),
                    ),
                  ),

                  // Asıl içerik
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Beyaz panel (üstü yuvarlak)
                        Container(
                          margin: EdgeInsets.only(top: avatarDiameter / 2),
                          constraints: BoxConstraints(minHeight: size.height * 0.7),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(contentPadding, 24, contentPadding, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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

                                // Çiftlik adı
                                const SizedBox(height: 2),
                                Text(
                                  ciftlik,
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                                ),

                                const SizedBox(height: 12),

                                // Konum chip
                                _buildKonumChip(konum),

                                const SizedBox(height: 25),

                                // Hakkımda
                                Text(
                                  "Hakkımda",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  hakkimda,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),

                                const SizedBox(height: 25),

                                // İstatistik satırı
                                _buildStatsRow(),

                                const SizedBox(height: 25),

                                // Ürünlerim listesi
                                Text(
                                  "Ürünlerim",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                SizedBox(
                                  height: birim * 0.45,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('urunler')
                                        .where('ureticiId', isEqualTo: user?.uid)
                                        .snapshots(),
                                    builder: (context, urunSnapshot) {
                                      if (!urunSnapshot.hasData) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (urunSnapshot.data!.docs.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "Henüz ürün yok.",
                                            style: TextStyle(color: Colors.grey.shade500),
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: urunSnapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final urun = urunSnapshot.data!.docs[index].data()
                                              as Map<String, dynamic>;
                                          return _buildProductCard(urun, index, birim);
                                        },
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),

                        // Avatar
                        Positioned(
                          top: 0,
                          left: contentPadding,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 6),
                            ),
                            child: CircleAvatar(
                              radius: avatarDiameter / 2,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: const AssetImage('assets/uretici.png'),
                            ),
                          ),
                        ),

                        // Profili düzenle (sağ üst yazı)
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
                                  color: Colors.black,
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

                  // Sayfa sonunu beyazla doldurur (tasarım için)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: Container(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 4) HELPER'LAR
  // ============================================================

  /// Rebuild olurken controller’lar sürekli set edilmesin diye:
  /// sadece boşsa dolduruyoruz
  void _fillControllersIfEmpty({
    required String adSoyad,
    required String ciftlik,
    required String hakkimda,
    required String konum,
  }) {
    if (_adSoyadController.text.isEmpty) _adSoyadController.text = adSoyad;
    if (_ciftlikBilgisiController.text.isEmpty) _ciftlikBilgisiController.text = ciftlik;
    if (_hakkimdaController.text.isEmpty) _hakkimdaController.text = hakkimda;
    if (_konumController.text.isEmpty) _konumController.text = konum;
  }

  // Konum chip'i (UI aynı)
  Widget _buildKonumChip(String konum) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 14, color: Colors.deepOrangeAccent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              konum,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // İstatistik satırı (Ürün sayısı canlı, diğerleri sabit)
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Ürün sayısı: Firestore'dan canlı gelir
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('urunler')
              .where('ureticiId', isEqualTo: user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String urunSayisi = "0";
            if (snapshot.hasData) {
              urunSayisi = snapshot.data!.docs.length.toString();
            }
            return _buildStatItem("Ürünler", urunSayisi);
          },
        ),

        // Şimdilik sabit
        _buildStatItem("Takipçi", "1.2k"),
        _buildStatItem("Puan", "4.8"),
      ],
    );
  }

  // İstatistik kutusu (UI aynı)
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  // Ürün kartı (UI aynı: kare renk kutu + isim)
  Widget _buildProductCard(Map<String, dynamic> urun, int index, double birim) {
    final Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];

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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.eco,
                color: Colors.black.withOpacity(0.1),
                size: birim * 0.15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            urun['urunAdi'] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1E201C),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
