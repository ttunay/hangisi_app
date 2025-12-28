import 'package:flutter/material.dart';
import 'package:hangisi_app/ekranlar/tuketici/tuketici_ana_ekran.dart';
import 'dart:ui';
import '../../servisler/auth_servisi.dart'; 
import '../uretici/uretici_ana_ekran.dart'; 
import 'kayit_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
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

  void _girisYap() async {
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen e-posta ve şifrenizi giriniz.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authServisi.girisYap(
        _emailController.text.trim(),
        _sifreController.text.trim(),
      );

      if (user != null) {
        String? rol = await _authServisi.kullaniciRolunuGetir(user.uid);

        if (mounted) {
          if (rol == 'Uretici') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnaEkran()),
            );
          } else if (rol == 'Tuketici') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TuketiciAnaEkran()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş Başarısız: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(double birim, {
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
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
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Colors.green, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double responsiveBirim = size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/inekler.png', 
                fit: BoxFit.cover, 
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          
                          Material(
                            type: MaterialType.transparency,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.07, vertical: responsiveBirim * 0.05),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(128), 
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withAlpha(153), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, spreadRadius: 5),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, 
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center, 
                                    children: [
                                      Text(
                                        "hangisi", 
                                        style: TextStyle(
                                          fontFamily: 'Inter', 
                                          fontSize: responsiveBirim * 0.045, 
                                          color: Colors.black54, 
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () => Navigator.push(
                                          context, 
                                          MaterialPageRoute(builder: (context) => const KayitEkrani())
                                        ),
                                        child: Text(
                                          "Kayıt Ol", 
                                          style: TextStyle(
                                            color: Colors.black, 
                                            fontWeight: FontWeight.bold, 
                                            fontSize: responsiveBirim * 0.04
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: responsiveBirim * 0.02),
                                  Text("Giriş Yap", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.09, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1)),
                                  SizedBox(height: responsiveBirim * 0.06),
                                  
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(fontSize: responsiveBirim * 0.04),
                                    decoration: _inputDecoration(responsiveBirim, hintText: "E-posta Adresi", icon: Icons.alternate_email)
                                  ),
                                  
                                  SizedBox(height: responsiveBirim * 0.03),
                                  
                                  TextField(
                                    controller: _sifreController,
                                    obscureText: _sifreGizli, 
                                    style: TextStyle(fontSize: responsiveBirim * 0.04),
                                    decoration: _inputDecoration(
                                      responsiveBirim, 
                                      hintText: "Şifre", 
                                      icon: Icons.vpn_key_outlined, 
                                      suffixIcon: IconButton(
                                        icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: responsiveBirim * 0.05), 
                                        onPressed: () => setState(() => _sifreGizli = !_sifreGizli)
                                      )
                                    )
                                  ),

                                  SizedBox(height: responsiveBirim * 0.02),
                                  
                                  // --- GÜNCELLENEN HİZALAMA: HAFİF SAĞA ALINDI ---
                                  Align(
                                    alignment: Alignment.centerRight, 
                                    child: Padding(
                                      padding: EdgeInsets.only(right: responsiveBirim * 0.02), // 0.05'ten 0.02'ye çekerek sağa yaklaştırdık
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {}, 
                                        child: Text(
                                          "Şifremi Unuttum", 
                                          style: TextStyle(
                                            color: Colors.black54, 
                                            fontWeight: FontWeight.w600, 
                                            fontSize: responsiveBirim * 0.028
                                          )
                                        )
                                      ),
                                    )
                                  ),
                                  
                                  SizedBox(height: responsiveBirim * 0.04),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.", 
                                          style: TextStyle(fontSize: responsiveBirim * 0.028, color: Colors.black45, height: 1.4)
                                        )
                                      ),
                                      SizedBox(width: responsiveBirim * 0.05),
                                      InkWell(
                                        onTap: _isLoading ? null : _girisYap, 
                                        child: Container(
                                          width: responsiveBirim * 0.18, 
                                          height: responsiveBirim * 0.13, 
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E201C), 
                                            borderRadius: BorderRadius.circular(30)
                                          ),
                                          child: _isLoading 
                                            ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                            : Icon(Icons.arrow_forward, color: Colors.white, size: responsiveBirim * 0.07),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: responsiveBirim * 0.04),
                                  Center(
                                    child: Text(
                                      "Lütfen sorumlu bir şekilde kullanın!", 
                                      style: TextStyle(fontSize: responsiveBirim * 0.025, color: Colors.black38)
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}