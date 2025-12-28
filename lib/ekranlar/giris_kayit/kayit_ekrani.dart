import 'package:flutter/material.dart';
import 'dart:ui';
import '../../servisler/auth_servisi.dart';
import 'dogrulama_ekrani.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _sifreTekrarController = TextEditingController();
  final AuthServisi _authServisi = AuthServisi();

  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;
  bool _isLoading = false;
  String? _secilenRol;

  @override
  void dispose() {
    _adController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(double birim, {required String hintText, required IconData icon, Widget? suffixIcon}) {
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

  Widget _buildRoleCard(double birim, {required String rolAdi, required String gorselYolu, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(birim * 0.04),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.withAlpha(30) : Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.green : Colors.white.withAlpha(153), width: isSelected ? 3 : 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(gorselYolu, width: birim * 0.20, height: birim * 0.20, fit: BoxFit.contain),
              SizedBox(height: birim * 0.03),
              Text(rolAdi, style: TextStyle(fontFamily: 'Inter', fontSize: birim * 0.045, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.green : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  void _kayitOl() async {
    if (_adController.text.isEmpty || _emailController.text.isEmpty || _sifreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurunuz.")));
      return;
    }
    if (_sifreController.text != _sifreTekrarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifreler birbiriyle uyuşmuyor.")));
      return;
    }
    if (_secilenRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir rol seçiniz (Üretici veya Tüketici).")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authServisi.kayitOl(
        email: _emailController.text.trim(),
        sifre: _sifreController.text.trim(),
        adSoyad: _adController.text.trim(),
        rol: _secilenRol!,
      );
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DogrulamaEkrani(email: _emailController.text.trim())));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata oluştu: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double responsiveBirim = size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Klavye kapansın
      child: Scaffold(
        backgroundColor: const Color(0xFFE7E9E8),
        resizeToAvoidBottomInset: true,
        body: OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;

            return Stack(
              children: [
                Positioned.fill(
                  child: RotatedBox(
                    quarterTurns: isLandscape ? 3 : 0, 
                    child: Image.asset('assets/inekler.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const SizedBox()),
                  ),
                ),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Container(
                            width: size.width,
                            color: Colors.transparent,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 450),
                                    
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      // --- YENİ STACK YAPISI ---
                                      child: Stack(
                                        children: [
                                          // 1. Katman: Blur (Positioned.fill ile arkada)
                                          Positioned.fill(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: Container(color: Colors.transparent),
                                            ),
                                          ),
                                          
                                          // 2. Katman: İçerik (Material ile önde)
                                          Material(
                                            type: MaterialType.transparency,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.07, vertical: responsiveBirim * 0.05),
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
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("hangisi", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.045, color: Colors.black54, fontWeight: FontWeight.w500)),
                                                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Giriş Yap", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: responsiveBirim * 0.04))),
                                                    ],
                                                  ),
                                                  SizedBox(height: responsiveBirim * 0.02),
                                                  Text("Kayıt Ol", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.09, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1)),
                                                  SizedBox(height: responsiveBirim * 0.05),
                                                  
                                                  // FORM ALANLARI
                                                  TextField(controller: _adController, style: TextStyle(fontSize: responsiveBirim * 0.04), decoration: _inputDecoration(responsiveBirim, hintText: "Ad Soyad", icon: Icons.person_outline)),
                                                  SizedBox(height: responsiveBirim * 0.03),
                                                  TextField(controller: _emailController, style: TextStyle(fontSize: responsiveBirim * 0.04), decoration: _inputDecoration(responsiveBirim, hintText: "E-posta Adresi", icon: Icons.alternate_email)),
                                                  SizedBox(height: responsiveBirim * 0.03),
                                                  TextField(controller: _sifreController, obscureText: _sifreGizli, style: TextStyle(fontSize: responsiveBirim * 0.04), decoration: _inputDecoration(responsiveBirim, hintText: "Şifre", icon: Icons.vpn_key_outlined, suffixIcon: IconButton(icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: responsiveBirim * 0.05), onPressed: () => setState(() => _sifreGizli = !_sifreGizli)))),
                                                  SizedBox(height: responsiveBirim * 0.03),
                                                  TextField(controller: _sifreTekrarController, obscureText: _sifreTekrarGizli, style: TextStyle(fontSize: responsiveBirim * 0.04), decoration: _inputDecoration(responsiveBirim, hintText: "Şifre Tekrar", icon: Icons.vpn_key_outlined, suffixIcon: IconButton(icon: Icon(_sifreTekrarGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: responsiveBirim * 0.05), onPressed: () => setState(() => _sifreTekrarGizli = !_sifreTekrarGizli)))),
                                                  
                                                  SizedBox(height: responsiveBirim * 0.05),
                                                  Text("Rolünüzü Seçin", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.045, fontWeight: FontWeight.w600, color: Colors.black87)),
                                                  SizedBox(height: responsiveBirim * 0.03),
                                                  Row(
                                                    children: [
                                                      _buildRoleCard(responsiveBirim, rolAdi: "Üretici", gorselYolu: 'assets/uretici.png', isSelected: _secilenRol == 'Uretici', onTap: () => setState(() => _secilenRol = 'Uretici')),
                                                      SizedBox(width: responsiveBirim * 0.04),
                                                      _buildRoleCard(responsiveBirim, rolAdi: "Tüketici", gorselYolu: 'assets/tuketici.png', isSelected: _secilenRol == 'Tuketici', onTap: () => setState(() => _secilenRol = 'Tuketici')),
                                                    ],
                                                  ),
                                                  SizedBox(height: responsiveBirim * 0.05),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(child: Text("Kayıt olarak, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.", style: TextStyle(fontSize: responsiveBirim * 0.028, color: Colors.black45, height: 1.4))),
                                                      SizedBox(width: responsiveBirim * 0.05),
                                                      InkWell(
                                                        onTap: _isLoading ? null : _kayitOl, 
                                                        child: Container(
                                                          width: responsiveBirim * 0.18, 
                                                          height: responsiveBirim * 0.13, 
                                                          decoration: BoxDecoration(color: const Color(0xFF1E201C), borderRadius: BorderRadius.circular(30)),
                                                          child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white)) : Icon(Icons.arrow_forward, color: Colors.white, size: responsiveBirim * 0.07),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // --- YENİ STACK YAPISI SONU ---
                                        ],
                                      ),
                                    ),
                                  ),
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
            );
          },
        ),
      ),
    );
  }
}