import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UrunEkleEkrani extends StatefulWidget {
  const UrunEkleEkrani({super.key});

  @override
  State<UrunEkleEkrani> createState() => _UrunEkleEkraniState();
}

class _UrunEkleEkraniState extends State<UrunEkleEkrani> {
  // Giriş yapmış kullanıcı (ürün eklerken ureticiId olarak kullanılacak)
  final User? user = FirebaseAuth.instance.currentUser;

  // Kaydet butonunda loading göstermek için
  bool _isLoading = false;

  // Form alanları için controller'lar
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _barkodController = TextEditingController();
  final TextEditingController _tohumController = TextEditingController();
  final TextEditingController _gubreController = TextEditingController();
  final TextEditingController _ilacController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  @override
  void dispose() {
    // Ekran kapanırken controller'ları temizle (memory leak olmasın)
    _adController.dispose();
    _barkodController.dispose();
    _tohumController.dispose();
    _gubreController.dispose();
    _ilacController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  // ============================================================
  // 1) FORMU SIFIRLAMA
  // ============================================================
  /// Ürün kaydedildikten sonra alanları temizler.
  void _formuSifirla() {
    _adController.clear();
    _barkodController.clear();
    _tohumController.clear();
    _gubreController.clear();
    _ilacController.clear();
    _aciklamaController.clear();
  }

  // ============================================================
  // 2) ÜRÜN KAYDETME (FIRESTORE)
  // ============================================================
  /// Firestore'a "urunler" koleksiyonuna yeni ürün ekler.
  /// Zorunlu alanlar: Ürün Adı + Barkod
  Future<void> _urunKaydet() async {
    // Kullanıcı yoksa veya zaten işlem sürüyorsa çık
    if (user == null || _isLoading) return;

    // Basit validasyon: ürün adı ve barkod boş olmasın
    if (_adController.text.trim().isEmpty || _barkodController.text.trim().isEmpty) {
      _mesajGoster("Lütfen Ürün Adı ve Barkod alanlarını doldurun!");
      return;
    }

    // Loading başlat
    setState(() => _isLoading = true);

    try {
      // Firestore'a yeni ürün ekle
      await FirebaseFirestore.instance.collection('urunler').add({
        'ureticiId': user!.uid,
        'urunAdi': _adController.text.trim(),
        'barkod': _barkodController.text.trim(),
        'tohum': _tohumController.text.trim(),
        'gubre': _gubreController.text.trim(),
        'ilac': _ilacController.text.trim(),
        'aciklama': _aciklamaController.text.trim(),
        'tarih': Timestamp.now(),
      });

      // Başarılı olunca:
      // - formu temizle
      // - loading kapat
      // - snackBar göster
      // - klavyeyi kapat
      if (!mounted) return;
      _formuSifirla();
      setState(() => _isLoading = false);
      _mesajGoster("Ürün başarıyla kaydedildi!");
      FocusScope.of(context).unfocus();
    } catch (e) {
      // Hata olursa loading kapat ve mesaj göster
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mesajGoster("Hata oluştu: $e");
    }
  }

  // Ekranda hızlı mesaj göstermek için küçük helper
  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj)),
    );
  }

  // ============================================================
  // 3) ARKA PLAN
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
  // 4) KULLANICIDAN AD SOYAD OKUMA (HEADER İÇİN)
  // ============================================================
  /// Üst kısımda "Merhaba + adSoyad" göstermek için kullanıcının
  /// Firestore'daki dokümanını dinler.
  Stream<DocumentSnapshot> _kullaniciStream() {
    return FirebaseFirestore.instance
        .collection('kullanicilar')
        .doc(user?.uid)
        .snapshots();
  }

  // ============================================================
  // 5) ANA BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Responsive birim: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    // Boş alana tıklanınca klavye kapansın
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          _buildBackground(),

          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,

            // Kullanıcının adSoyad bilgisini dinleyerek header'ı güncel tutar
            body: StreamBuilder<DocumentSnapshot>(
              stream: _kullaniciStream(),
              builder: (context, snapshot) {
                // Varsayılan isim
                String adSoyad = "Üretici";

                // Veri geldiyse adSoyad'ı oku
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  adSoyad = data['adSoyad'] ?? "Üretici";
                }

                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================================================
                      // ÜST BAŞLIK: "Merhaba" + adSoyad
                      // =====================================================
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          birim * 0.06,
                          birim * 0.06,
                          birim * 0.06,
                          0,
                        ),
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
                      // KAYDIRILABİLİR FORM ALANI
                      // =====================================================
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: birim * 0.06,
                            vertical: birim * 0.04,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // =============================================
                              // FORM KARTI (Tek büyük kutu)
                              // =============================================
                              Container(
                                padding: EdgeInsets.all(birim * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kart başlığı
                                    Text(
                                      "Yeni Ürün Ekle",
                                      style: TextStyle(
                                        fontSize: birim * 0.060,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E201C),
                                      ),
                                    ),
                                    SizedBox(height: birim * 0.04),

                                    // Form inputları
                                    _inputAlan(
                                      controller: _adController,
                                      label: "Ürün Adı",
                                      icon: Icons.shopping_bag_outlined,
                                      birim: birim,
                                    ),
                                    SizedBox(height: birim * 0.04),

                                    _inputAlan(
                                      controller: _barkodController,
                                      label: "Barkod (Örnek: DOM-01)",
                                      icon: Icons.qr_code_scanner,
                                      birim: birim,
                                    ),
                                    SizedBox(height: birim * 0.04),

                                    _inputAlan(
                                      controller: _tohumController,
                                      label: "Tohum Bilgisi",
                                      icon: Icons.grass,
                                      birim: birim,
                                    ),
                                    SizedBox(height: birim * 0.04),

                                    _inputAlan(
                                      controller: _gubreController,
                                      label: "Gübre Bilgisi",
                                      icon: Icons.opacity,
                                      birim: birim,
                                    ),
                                    SizedBox(height: birim * 0.04),

                                    _inputAlan(
                                      controller: _ilacController,
                                      label: "İlaçlama Bilgisi",
                                      icon: Icons.sanitizer,
                                      birim: birim,
                                    ),
                                    SizedBox(height: birim * 0.04),

                                    _inputAlan(
                                      controller: _aciklamaController,
                                      label: "Açıklama",
                                      icon: Icons.description,
                                      birim: birim,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: birim * 0.03),

                              // =============================================
                              // KAYDET BUTONU
                              // =============================================
                              Center(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _urunKaydet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E201C),
                                    minimumSize: Size(birim * 0.35, birim * 0.15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 1,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: birim * 0.06,
                                          width: birim * 0.06,
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "Ürünü Kaydet",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: birim * 0.040,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              // Alt navigation bar ile çakışmasın diye boşluk
                              SizedBox(height: birim * 0.2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 6) ORTAK INPUT ALANI
  // ============================================================
  /// Formun her alanı aynı stile sahip olsun diye tek fonksiyon kullanıyoruz.
  Widget _inputAlan({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double birim,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: birim * 0.04, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: birim * 0.04,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1E201C),
          size: birim * 0.06,
        ),

        // Border stilleri (orijinal görünüm korunuyor)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E201C), width: 1.5),
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: birim * 0.04,
          vertical: birim * 0.04,
        ),
      ),
    );
  }
}
