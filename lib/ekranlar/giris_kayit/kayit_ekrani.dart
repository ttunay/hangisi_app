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
  // --- CONTROLLER VE SERVİSLER ---
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _authServisi = AuthServisi();

  // --- STATE DEĞİŞKENLERİ ---
  bool _sifreGizli = true;
  bool _isLoading = false;
  String? _secilenRol;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // --- KAYIT OL FONKSİYONU ---
  void _kayitOl() async {
    if (_adController.text.isEmpty ||
        _soyadController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _sifreController.text.isEmpty ||
        _secilenRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurunuz.")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authServisi.kayitOl(
        email: _emailController.text.trim(),
        sifre: _sifreController.text.trim(),
        ad: _adController.text.trim(),
        soyad: _soyadController.text.trim(),
        rol: _secilenRol!,
      );
      await _authServisi.dogrulamaMailiGonder();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DogrulamaEkrani(email: _emailController.text.trim())));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= UI BİLEŞENLERİ (HELPER METHODS) =================

  // 1. TEXTFIELD OLUŞTURUCU (Tekrarı önler)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double birim,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text, // Varsayılan değer
  }) {
    return Padding(
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
          hintStyle: TextStyle(color: Colors.black45, fontSize: birim * 0.04),
          contentPadding: EdgeInsets.symmetric(vertical: birim * 0.05, horizontal: birim * 0.05),
          prefixIcon: Container(
            margin: EdgeInsets.all(birim * 0.02),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black54, size: birim * 0.055),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, size: birim * 0.05),
                  onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                )
              : null,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2)),
        ),
      ),
    );
  }

  // 2. ROL SEÇİM KARTI
  Widget _buildRoleCard(double birim, {required String rolAdi, required String gorselYolu, required String value}) {
    final isSelected = _secilenRol == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _secilenRol = value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(birim * 0.04),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrangeAccent.withAlpha(60) : Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.deepOrangeAccent.withAlpha(60) : Colors.white.withAlpha(150), width: isSelected ? 3 : 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(gorselYolu, width: birim * 0.20, height: birim * 0.20, fit: BoxFit.contain),
              SizedBox(height: birim * 0.03),
              Text(rolAdi, style: TextStyle(fontFamily: 'Inter', fontSize: birim * 0.045, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepOrangeAccent.withAlpha(200) : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  // 3. HEADER (Marka ve Giriş Yap Butonu)
  Widget _buildHeader(BuildContext context, double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("hangisi", style: TextStyle(fontFamily: 'Inter', fontSize: birim * 0.050, color: Colors.black54, fontWeight: FontWeight.w500)),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          onPressed: () => Navigator.pop(context),
          child: Text("Giriş Yap", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: birim * 0.04)),
        ),
      ],
    );
  }

  // 4. FOOTER (Gizlilik Metni ve Buton)
  Widget _buildFooter(double birim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text("Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.", style: TextStyle(fontSize: birim * 0.030, color: Colors.black87, height: 1.4)),
        ),
        SizedBox(width: birim * 0.05),
        InkWell(
          onTap: _isLoading ? null : _kayitOl,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: birim * 0.18,
            height: birim * 0.13,
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
    final size = MediaQuery.of(context).size;
    final double responsiveBirim = size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 228, 242, 247),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Arka Plan
            Positioned.fill(child: Image.asset('assets/inekler.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox())),

            // Scroll ve Layout
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Ekranın her yerinde kaydırma sağlar
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06, vertical: 20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Stack(
                              children: [
                                // Blur Efekti
                                Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.transparent))),
                                
                                // İçerik Kartı
                                Container(
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
                                      _buildHeader(context, responsiveBirim),
                                      const SizedBox(height: 10),
                                      Text("Kayıt Ol", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.09, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1)),
                                      const SizedBox(height: 20),
                                      
                                      // Form Alanları (Klavye sorununa karşı visiblePassword kullanımı)
                                      _buildTextField(controller: _adController, hintText: "Ad", icon: Icons.person_outline, birim: responsiveBirim, keyboardType: TextInputType.visiblePassword),
                                      _buildTextField(controller: _soyadController, hintText: "Soyad", icon: Icons.person_outline, birim: responsiveBirim, keyboardType: TextInputType.visiblePassword),
                                      _buildTextField(controller: _emailController, hintText: "E-posta", icon: Icons.alternate_email, birim: responsiveBirim, keyboardType: TextInputType.visiblePassword),
                                      _buildTextField(controller: _sifreController, hintText: "Şifre", icon: Icons.vpn_key_outlined, birim: responsiveBirim, isPassword: true),

                                      const SizedBox(height: 8),
                                      Text("Rol Seçin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsiveBirim * 0.04, color: Colors.black87)),
                                      const SizedBox(height: 10),
                                      
                                      // Rol Seçimi
                                      Row(
                                        children: [
                                          _buildRoleCard(responsiveBirim, rolAdi: "Üretici", gorselYolu: 'assets/uretici.png', value: 'Uretici'),
                                          const SizedBox(width: 10),
                                          _buildRoleCard(responsiveBirim, rolAdi: "Tüketici", gorselYolu: 'assets/tuketici.png', value: 'Tuketici'),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 25),
                                      _buildFooter(responsiveBirim),
                                      SizedBox(height: responsiveBirim * 0.02),
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