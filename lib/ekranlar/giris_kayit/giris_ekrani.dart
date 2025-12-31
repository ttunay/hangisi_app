import 'package:flutter/material.dart';
import 'dart:ui'; // BackdropFilter + ImageFilter.blur için gerekli
import 'package:firebase_auth/firebase_auth.dart';

import '../../servis/auth_servisi.dart';
import '../uretici/uretici_ana_ekran.dart';
import '../tuketici/tuketici_ana_ekran.dart';
import 'kayit_ekrani.dart';

/// GirisEkrani:
/// - Kullanıcıdan e-posta + şifre alır
/// - Firebase Authentication ile giriş yapar
/// - Kullanıcının rolünü (Uretici / Tuketici) veritabanından getirir
/// - Role göre ilgili ana ekrana yönlendirir
/// - Şifre sıfırlama e-postası gönderebilir
/// - Arka planda görsel + önde blur'lu (cam efekti) kart tasarımı vardır
class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  // -----------------------------
  // 1) Controller ve Servisler
  // -----------------------------
  // TextEditingController:
  // - TextField içindeki metni okumamızı sağlar (email/sifre gibi)
  // - dispose() içinde kapatmak gerekir (hafıza sızıntısı olmasın diye)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  // AuthServisi:
  // - Firebase giriş, rol çekme gibi işlemleri yapan servis sınıfı
  final AuthServisi _authServisi = AuthServisi();

  // -----------------------------
  // 2) UI Durumları
  // -----------------------------
  bool _sifreGizli = true; // şifre alanını gizle/göster
  bool _isLoading = false; // giriş işlemi sırasında loading göstermek için

  @override
  void dispose() {
    // Controller'ları ekran kapanırken temizliyoruz.
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // ============================================================
  // GİRİŞ YAPMA İŞLEMİ
  // ============================================================
  /// _girisYap():
  /// 1) Alanlar boş mu kontrol eder (validasyon)
  /// 2) Firebase giriş yapar
  /// 3) Kullanıcının rolünü veritabanından çeker
  /// 4) Role göre doğru ekrana yönlendirir
  void _girisYap() async {
    // 1) Basit validasyon: Boş alan var mı?
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      _mesajGoster("Lütfen e-posta adresinizi ve şifrenizi giriniz.");
      return;
    }

    // 2) Loading başlat
    setState(() => _isLoading = true);

    try {
      // 3) Firebase ile giriş yap
      final user = await _authServisi.girisYap(
        _emailController.text.trim(),
        _sifreController.text.trim(),
      );

      // 4) Giriş başarılı mı?
      if (user != null && mounted) {
        debugPrint("Giriş Başarılı, Kullanıcı UID: ${user.uid}");

        // 5) Kullanıcının rolünü veritabanından getir
        final String? rol = await _authServisi.kullaniciRolunuGetir(user.uid);
        debugPrint("Veritabanından Gelen Rol: $rol");

        // 6) Rol yoksa uyarı ver
        if (rol == null) {
          _mesajGoster("Kullanıcı rolü veritabanında bulunamadı.");
          return;
        }

        // 7) Role göre hedef ekranı belirle
        late final Widget hedefEkran;
        if (rol == 'Uretici') {
          hedefEkran = const AnaEkran();
        } else if (rol == 'Tuketici') {
          hedefEkran = const TuketiciAnaEkran();
        } else {
          _mesajGoster("Tanımsız rol: $rol");
          return;
        }

        // 8) Login ekranına geri dönülmesin diye:
        // pushAndRemoveUntil ile tüm önceki sayfaları kaldırıyoruz.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => hedefEkran),
          (route) => false,
        );
      } else {
        // user null döndüyse: şifre yanlış, kullanıcı yok vb.
        _mesajGoster("Giriş başarısız. Lütfen bilgilerinizi kontrol edin.");
      }
    } catch (e) {
      // Herhangi bir hata yakalanırsa snackbar göster
      _mesajGoster("Hata oluştu: ${e.toString()}");
    } finally {
      // İşlem bittiğinde loading kapat
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // ŞİFRE SIFIRLAMA
  // ============================================================
  /// _sifreSifirla():
  /// - E-posta alanı doluysa Firebase'e "şifre sıfırlama maili" göndertir.
  void _sifreSifirla() async {
    if (_emailController.text.isEmpty) {
      _mesajGoster("Lütfen önce e-posta adresinizi giriniz.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      _mesajGoster("Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.");
    } catch (e) {
      _mesajGoster("Hata: ${e.toString()}");
    }
  }

  // ============================================================
  // SNACKBAR (MESAJ GÖSTERME)
  // ============================================================
  /// _mesajGoster():
  /// - Ekranın altından kısa bir bilgi mesajı (SnackBar) gösterir.
  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj)),
    );
  }

  // ============================================================
  // UI - KÜÇÜK YARDIMCI WIDGET'LAR
  // (Kodun okunması kolay olsun diye parçalı yapıyoruz)
  // ============================================================

  // -----------------------------
  // 1) TextField Oluşturucu
  // -----------------------------
  /// Tek bir fonksiyonla hem e-posta hem şifre alanını aynı tasarımda üretiriz.
  /// - isPassword true olursa suffixIcon ile göz butonu çıkar.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double birim,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,

      // Şifre alanında gizle/göster
      obscureText: isPassword ? _sifreGizli : false,

      keyboardType: keyboardType,
      textInputAction: action,

      // TextField içindeki yazının boyutu
      style: TextStyle(fontSize: birim * 0.04),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(179),

        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black45,
          fontSize: birim * 0.04,
        ),

        // İç padding (kutunun iç boşluğu)
        contentPadding: EdgeInsets.symmetric(
          vertical: birim * 0.05,
          horizontal: birim * 0.05,
        ),

        // Sol taraftaki ikon daire içinde
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

        // Şifre alanında sağ tarafta göz ikonu (gizle/göster)
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _sifreGizli ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black45,
                  size: birim * 0.05,
                ),
                onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
              )
            : null,

        // Kenarlıklar (border)
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
    );
  }

  // -----------------------------
  // 2) Üst Kısım (Marka + Kayıt Ol)
  // -----------------------------
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
          // Kayıt ekranına gider
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KayitEkrani()),
          ),
          // Butonun varsayılan boşluklarını kaldırmak için
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Kayıt Ol",
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

  // -----------------------------
  // 3) Şifremi Unuttum
  // -----------------------------
  Widget _buildForgotPassword(double birim) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: birim * 0.02,
          top: birim * 0.02,
        ),
        child: TextButton(
          onPressed: _sifreSifirla,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Şifremi Unuttum",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: birim * 0.030,
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------
  // 4) Alt Kısım (Gizlilik Metni + Giriş Oku Butonu)
  // -----------------------------
  Widget _buildFooter(double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol taraftaki metin alanı genişleyebilsin diye Expanded kullanıyoruz.
        Expanded(
          child: Text(
            "Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.",
            style: TextStyle(
              fontSize: birim * 0.030,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(width: birim * 0.05),

        // Sağ tarafta giriş butonu (ok ikonlu)
        InkWell(
          // Loading sırasında tıklanmasın
          onTap: _isLoading ? null : _girisYap,
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

  // ============================================================
  // ANA BUILD (EKRANIN GÖRÜNÜMÜ)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Ölçeklendirme birimi: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      // Boş yere dokununca klavyeyi kapatır (input odaklarını kaldırır)
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 228, 242, 247),
        resizeToAvoidBottomInset: true, // klavye açılınca içerik taşmasın
        body: Stack(
          children: [
            // 1) ARKA PLAN GÖRSELİ (tam ekran)
            Positioned.fill(
              child: Image.asset(
                'assets/inekler.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

            // 2) ÖNDEKİ İÇERİK:
            // LayoutBuilder + SingleChildScrollView + ConstrainedBox
            // => klavye açıldığında / küçük ekranlarda taşmayı engeller,
            //    yine de kaydırma (scroll) yapılmasını sağlar.
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        // Yatay padding ekrana göre, dikey padding sabit 20 (orijinalde böyle)
                        padding: EdgeInsets.symmetric(
                          horizontal: birim * 0.06,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          // Çok geniş ekranlarda kart aşırı büyümesin
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              children: [
                                // 2.1) BLUR (cam efekti) katmanı
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    // Blur’un çalışması için üstüne şeffaf bir Container koyuyoruz
                                    child: Container(
                                      color: const Color.fromARGB(0, 255, 255, 255),
                                    ),
                                  ),
                                ),

                                // 2.2) KART İÇERİĞİ
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
                                      // Üst satır: "hangisi" + "Kayıt Ol"
                                      _buildHeader(context, birim),
                                      SizedBox(height: birim * 0.02),

                                      // Başlık: "Giriş Yap"
                                      Text(
                                        "Giriş Yap",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: birim * 0.09,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      SizedBox(height: birim * 0.06),

                                      // E-posta alanı
                                      // Not: Orijinalde keyboardType visiblePassword kullanılmış (dokunmuyoruz)
                                      _buildTextField(
                                        controller: _emailController,
                                        hintText: "E-posta Adresi",
                                        icon: Icons.alternate_email,
                                        birim: birim,
                                        keyboardType: TextInputType.visiblePassword,
                                      ),
                                      SizedBox(height: birim * 0.03),

                                      // Şifre alanı
                                      _buildTextField(
                                        controller: _sifreController,
                                        hintText: "Şifre",
                                        icon: Icons.vpn_key_outlined,
                                        birim: birim,
                                        isPassword: true,
                                        action: TextInputAction.done,
                                      ),
                                      SizedBox(height: birim * 0.02),

                                      // Şifremi unuttum
                                      _buildForgotPassword(birim),
                                      SizedBox(height: birim * 0.04),

                                      // Alt kısım: gizlilik metni + giriş butonu
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
