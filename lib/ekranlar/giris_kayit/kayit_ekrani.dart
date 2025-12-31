import 'package:flutter/material.dart';
import 'dart:ui'; // Blur efekti için (BackdropFilter + ImageFilter)
import '../../servis/auth_servisi.dart';
import 'dogrulama_ekrani.dart';

/// KayitEkrani:
/// - Kullanıcıdan ad, soyad, e-posta, şifre bilgilerini alır.
/// - Kullanıcı rolü seçtirir (Üretici / Tüketici).
/// - AuthServisi ile kayıt işlemi yapar.
/// - Doğrulama e-postası gönderir.
/// - Sonra DogrulamaEkrani'na yönlendirir.
/// - Arka plan görseli + önde blur'lu cam efektli kart tasarımı vardır.
class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  // -------------------------------------------------------
  // 1) Controller ve Servisler
  // -------------------------------------------------------
  // Kullanıcının yazdığı metinleri almak için controller kullanıyoruz.
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  // Kayıt / doğrulama maili gibi işlemleri yapan servis
  final AuthServisi _authServisi = AuthServisi();

  // -------------------------------------------------------
  // 2) UI Durumları
  // -------------------------------------------------------
  bool _sifreGizli = true; // Şifreyi gizle/göster
  bool _isLoading = false; // Kayıt olurken butonda loading göstermek için
  String? _secilenRol;     // Kullanıcının seçtiği rol: 'Uretici' veya 'Tuketici'

  @override
  void dispose() {
    // Ekran kapatılırken controller'ları temizlemek gerekir.
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // =======================================================
  // KAYIT OL İŞLEMİ
  // =======================================================
  /// _kayitOl():
  /// 1) Form alanlarını kontrol eder (boş var mı?)
  /// 2) AuthServisi.kayitOl(...) ile kullanıcıyı kaydeder
  /// 3) Doğrulama maili gönderir
  /// 4) DogrulamaEkrani'na yönlendirir
  void _kayitOl() async {
    // 1) Basit validasyon: Her alan dolu mu + rol seçilmiş mi?
    if (_adController.text.isEmpty ||
        _soyadController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _sifreController.text.isEmpty ||
        _secilenRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurunuz.")),
      );
      return;
    }

    // 2) Loading başlat
    setState(() => _isLoading = true);

    try {
      // 3) Servis üzerinden kayıt işlemi
      await _authServisi.kayitOl(
        email: _emailController.text.trim(),
        sifre: _sifreController.text.trim(),
        ad: _adController.text.trim(),
        soyad: _soyadController.text.trim(),
        rol: _secilenRol!, // null olamayacağını kontrol ettik
      );

      // 4) Doğrulama maili gönder
      await _authServisi.dogrulamaMailiGonder();

      // 5) Ekran hâlâ açıksa doğrulama ekranına geç
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DogrulamaEkrani(email: _emailController.text.trim()),
        ),
      );
    } catch (e) {
      // Hata olursa kullanıcıya göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    } finally {
      // Loading kapat
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =======================================================
  // UI - YARDIMCI WIDGET'LAR (Helper Methods)
  // =======================================================

  // -------------------------------------------------------
  // 1) TextField oluşturucu (tekrar olmasın diye)
  // -------------------------------------------------------
  /// Aynı tasarıma sahip inputları tek yerden üretir:
  /// - Ad / Soyad / Email / Şifre
  /// - isPassword true ise göz ikonu çıkar (şifre gizle/göster)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double birim,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      // Orijinalde alt boşluk 12 idi, aynı bıraktık
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _sifreGizli : false,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: birim * 0.04),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withAlpha(179),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black45,
            fontSize: birim * 0.04,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: birim * 0.05,
            horizontal: birim * 0.05,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(birim * 0.02),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.black54,
              size: birim * 0.055,
            ),
          ),
          // Şifre alanında sağdaki göz butonu
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _sifreGizli ? Icons.visibility_off : Icons.visibility,
                    size: birim * 0.05,
                  ),
                  onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // 2) Rol seçim kartı (Üretici / Tüketici)
  // -------------------------------------------------------
  /// Kullanıcı bir role tıklayınca _secilenRol güncellenir.
  /// Seçili kart daha belirgin görünür.
  Widget _buildRoleCard(
    double birim, {
    required String rolAdi,
    required String gorselYolu,
    required String value,
  }) {
    final bool isSelected = _secilenRol == value;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _secilenRol = value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(birim * 0.04),
          decoration: BoxDecoration(
            // Seçiliyse daha sıcak (turuncu) bir vurgu
            color: isSelected
                ? Colors.deepOrangeAccent.withAlpha(60)
                : Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.deepOrangeAccent.withAlpha(60)
                  : Colors.white.withAlpha(150),
              width: isSelected ? 3 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rol görseli
              Image.asset(
                gorselYolu,
                width: birim * 0.20,
                height: birim * 0.20,
                fit: BoxFit.contain,
              ),
              SizedBox(height: birim * 0.03),

              // Rol adı yazısı
              Text(
                rolAdi,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: birim * 0.045,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.deepOrangeAccent.withAlpha(200)
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // 3) Header: "hangisi" + "Giriş Yap" butonu
  // -------------------------------------------------------
  /// Sağdaki "Giriş Yap" butonu:
  /// - Navigator.pop(context) ile bir önceki sayfaya döner (Giriş ekranı)
  Widget _buildHeader(BuildContext context, double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "hangisi",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: birim * 0.050,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Giriş Yap",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: birim * 0.04,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // 4) Footer: Gizlilik metni + Kayıt ol butonu
  // -------------------------------------------------------
  /// Sağ taraftaki ok butonu:
  /// - _kayitOl() fonksiyonunu çalıştırır
  /// - loading sırasında yerine progress çıkar
  Widget _buildFooter(double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.",
            style: TextStyle(
              fontSize: birim * 0.030,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(width: birim * 0.05),
        InkWell(
          onTap: _isLoading ? null : _kayitOl,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: birim * 0.18,
            height: birim * 0.13,
            decoration: BoxDecoration(
              color: const Color(0xFF1E201C),
              borderRadius: BorderRadius.circular(30),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: birim * 0.07,
                  ),
          ),
        ),
      ],
    );
  }

  // =======================================================
  // ANA BUILD (EKRANIN GÖRÜNÜMÜ)
  // =======================================================
  @override
  Widget build(BuildContext context) {
    // Ölçeklendirme birimi: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      // Boş yere tıklanınca klavyeyi kapatır
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 228, 242, 247),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // 1) ARKA PLAN (tam ekran görsel)
            Positioned.fill(
              child: Image.asset(
                'assets/inekler.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

            // 2) ÖNDEKİ İÇERİK:
            // LayoutBuilder + SingleChildScrollView + ConstrainedBox
            // => küçük ekran / klavye açılınca taşmayı engeller, kaydırma sağlar.
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        // Orijinalde yatay: birim*0.06, dikey: 20 idi
                        padding: EdgeInsets.symmetric(
                          horizontal: birim * 0.06,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          // Çok geniş ekranda kartın max genişliği sabit kalsın
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              children: [
                                // 2.1) BLUR KATMANI (cam efekti)
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    // Blur aktif olsun diye transparan bir container
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),

                                // 2.2) İÇERİK KARTI
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: birim * 0.07,
                                    vertical: birim * 0.05,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(128),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(153),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(13),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Üst kısım: başlık + giriş yap
                                      _buildHeader(context, birim),

                                      // Orijinalde sabit 10 boşluk vardı
                                      const SizedBox(height: 10),

                                      // Büyük başlık
                                      Text(
                                        "Kayıt Ol",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: birim * 0.09,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: -1,
                                        ),
                                      ),

                                      // Orijinalde sabit 20 boşluk vardı
                                      const SizedBox(height: 20),

                                      // Form alanları
                                      // Not: Orijinalde "klavye fix" diye visiblePassword verilmişti,
                                      // aynen koruyoruz (davranış değişmesin).
                                      _buildTextField(
                                        controller: _adController,
                                        hintText: "Ad",
                                        icon: Icons.person_outline,
                                        birim: birim,
                                        keyboardType: TextInputType.visiblePassword,
                                      ),
                                      _buildTextField(
                                        controller: _soyadController,
                                        hintText: "Soyad",
                                        icon: Icons.person_outline,
                                        birim: birim,
                                        keyboardType: TextInputType.visiblePassword,
                                      ),
                                      _buildTextField(
                                        controller: _emailController,
                                        hintText: "E-posta",
                                        icon: Icons.alternate_email,
                                        birim: birim,
                                        keyboardType: TextInputType.visiblePassword,
                                      ),
                                      _buildTextField(
                                        controller: _sifreController,
                                        hintText: "Şifre",
                                        icon: Icons.vpn_key_outlined,
                                        birim: birim,
                                        isPassword: true,
                                      ),

                                      const SizedBox(height: 8),

                                      // Rol başlığı
                                      Text(
                                        "Rol Seçin",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: birim * 0.04,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Rol kartları: Üretici / Tüketici
                                      Row(
                                        children: [
                                          _buildRoleCard(
                                            birim,
                                            rolAdi: "Üretici",
                                            gorselYolu: 'assets/uretici.png',
                                            value: 'Uretici',
                                          ),
                                          const SizedBox(width: 10),
                                          _buildRoleCard(
                                            birim,
                                            rolAdi: "Tüketici",
                                            gorselYolu: 'assets/tuketici.png',
                                            value: 'Tuketici',
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 25),

                                      // Alt kısım: gizlilik + kayıt ol butonu
                                      _buildFooter(birim),
                                      SizedBox(height: birim * 0.02),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
