import 'package:flutter/material.dart';
import 'package:hangisi_app/ekranlar/tuketici/tuketici_ana_ekran.dart';
import 'dart:ui';
import '../../servisler/auth_servisi.dart';
import '../uretici/uretici_ana_ekran.dart';
import 'kayit_ekrani.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  // --- CONTROLLER VE DEĞİŞKENLER ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final AuthServisi _authServisi = AuthServisi();

  bool _sifreGizli = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

 // --- GÜNCELLENMİŞ GİRİŞ YAP FONKSİYONU ---
  void _girisYap() async {
    // 1. Validasyon
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      _mesajGoster("Lütfen e-posta adresinizi ve şifrenizi giriniz.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Firebase Girişi
      final user = await _authServisi.girisYap(
        _emailController.text.trim(),
        _sifreController.text.trim(),
      );

      // 3. Kullanıcı Kontrolü
      if (user != null && mounted) {
        debugPrint("Giriş Başarılı, Kullanıcı UID: ${user.uid}");

        // 4. Rolü Getir
        String? rol = await _authServisi.kullaniciRolunuGetir(user.uid);
        debugPrint("Veritabanından Gelen Rol: $rol"); // Konsola bak: Burası null mı geliyor?

        if (mounted) {
          if (rol != null) {
            // 5. Yönlendirme (Rol boş değilse)
            Widget hedefEkran;
            if (rol == 'Uretici') {
              hedefEkran = const AnaEkran();
            } else if (rol == 'Tuketici') {
              hedefEkran = const TuketiciAnaEkran();
            } else {
              _mesajGoster("Tanımsız rol: $rol");
              return;
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => hedefEkran),
              (route) => false, // Geri butonunu devre dışı bırakır (Login ekranına dönülmez)
            );
          } else {
            _mesajGoster("Kullanıcı rolü veritabanında bulunamadı.");
          }
        }
      } else {
        // Kullanıcı null döndüyse (Şifre yanlış vs.)
        _mesajGoster("Giriş başarısız. Lütfen bilgilerinizi kontrol edin.");
      }
    } catch (e) {
      if (mounted) _mesajGoster("Hata oluştu: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sifreSifirla() async {
    if (_emailController.text.isEmpty) {
      _mesajGoster("Lütfen önce e-posta adresinizi giriniz.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      _mesajGoster("Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.");
    } catch (e) {
      _mesajGoster("Hata: ${e.toString()}");
    }
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }

  // ================= UI HELPER METODLARI =================

  // 1. TEXTFIELD OLUŞTURUCU
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
      obscureText: isPassword ? _sifreGizli : false,
      keyboardType: keyboardType,
      textInputAction: action,
      style: TextStyle(fontSize: birim * 0.04),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(179),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black45, fontSize: birim * 0.04),
        contentPadding: EdgeInsets.symmetric(vertical: birim * 0.05, horizontal: birim * 0.05),
        prefixIcon: Container(
          margin: EdgeInsets.all(birim * 0.02),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black54, size: birim * 0.055),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: birim * 0.05),
                onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
              )
            : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2)),
      ),
    );
  }

  // 2. HEADER (Marka ve Kayıt Ol Butonu)
  Widget _buildHeader(BuildContext context, double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("hangisi", style: TextStyle(fontFamily: 'Inter', fontSize: birim * 0.050, color: Colors.black54, fontWeight: FontWeight.w500)),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KayitEkrani())),
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text("Kayıt Ol", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: birim * 0.04)),
        ),
      ],
    );
  }

  // 3. ŞİFREMİ UNUTTUM BUTONU
  Widget _buildForgotPassword(double birim) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: birim * 0.02, top: birim * 0.02),
        child: TextButton(
          onPressed: _sifreSifirla,
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text("Şifremi Unuttum", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: birim * 0.030)),
        ),
      ),
    );
  }

  // 4. FOOTER (Gizlilik Metni ve Giriş Butonu)
  Widget _buildFooter(double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.",
            style: TextStyle(fontSize: birim * 0.030, color: Colors.black54, height: 1.4,),
          ),
        ),
        SizedBox(width: birim * 0.05),
        InkWell(
          onTap: _isLoading ? null : _girisYap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: birim * 0.18, height: birim * 0.13,
            decoration: BoxDecoration(color: const Color(0xFF1E201C), borderRadius: BorderRadius.circular(30)),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Icon(Icons.arrow_forward, color: Colors.white, size: birim * 0.07),
          ),
        ),
      ],
    );
  }

  // ================= ANA BUILD METODU =================
  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 228, 242, 247),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Arka Plan Resmi
            Positioned.fill(
              child: Image.asset('assets/inekler.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
            ),

            // Scroll ve Layout Yapısı (Fix)
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Her yerden kaydırmayı sağlar
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: birim * 0.06, vertical: 20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              children: [
                                // Blur Efekti
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // İçerik Kartı
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: birim * 0.07, vertical: birim * 0.05),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(128),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.white.withAlpha(153), width: 1.5),
                                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, spreadRadius: 5)],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildHeader(context, birim),
                                      SizedBox(height: birim * 0.02),
                                      
                                      Text("Giriş Yap", style: TextStyle(fontFamily: 'Inter', fontSize: birim * 0.09, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1)),
                                      SizedBox(height: birim * 0.06),

                                      // E-posta Alanı (Klavye fix için visiblePassword kullanıldı)
                                      _buildTextField(
                                        controller: _emailController,
                                        hintText: "E-posta Adresi",
                                        icon: Icons.alternate_email,
                                        birim: birim,
                                        keyboardType: TextInputType.visiblePassword, 
                                      ),
                                      SizedBox(height: birim * 0.03),

                                      // Şifre Alanı
                                      _buildTextField(
                                        controller: _sifreController,
                                        hintText: "Şifre",
                                        icon: Icons.vpn_key_outlined,
                                        birim: birim,
                                        isPassword: true,
                                        action: TextInputAction.done,
                                      ),
                                      SizedBox(height: birim * 0.02),

                                      _buildForgotPassword(birim),
                                      SizedBox(height: birim * 0.04),

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