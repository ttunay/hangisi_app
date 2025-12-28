import 'package:flutter/material.dart';
import 'dart:ui';
import 'kayit_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  bool _sifreGizli = true;

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

    // Klavye dışına tıklayınca kapatmak için GestureDetector ekledik
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFE7E9E8),
        resizeToAvoidBottomInset: true,
        body: OrientationBuilder(
          builder: (context, orientation) {
            final bool isLandscape = orientation == Orientation.landscape;

            return Stack(
              children: [
                // 1. ARKA PLAN
                Positioned.fill(
                  child: RotatedBox(
                    quarterTurns: isLandscape ? 3 : 0, 
                    child: Image.asset(
                      'assets/inekler.png', 
                      fit: BoxFit.cover, 
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                ),

                // 2. İÇERİK
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
                            color: Colors.transparent, // Kaydırma için zemin
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 450),
                                    
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      // --- KRİTİK DÜZELTME BURADA ---
                                      child: Stack(
                                        children: [
                                          // KATMAN A: BULANIKLIK (Arkada ve Sabit)
                                          // Positioned.fill kullanarak içeriğin arkasını tam kaplamasını sağladık.
                                          Positioned.fill(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: Container(color: Colors.transparent),
                                            ),
                                          ),
                                          
                                          // KATMAN B: İÇERİK (Önde ve Tıklanabilir)
                                          // Material widget'ı dokunma olaylarını (tap) garanti altına alır.
                                          Material(
                                            type: MaterialType.transparency,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: responsiveBirim * 0.07, 
                                                vertical: responsiveBirim * 0.05
                                              ),
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
                                                    children: [
                                                      Text("hangisi", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.045, color: Colors.black54, fontWeight: FontWeight.w500)),
                                                      TextButton(
                                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KayitEkrani())),
                                                        child: Text("Kayıt Ol", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: responsiveBirim * 0.04)),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: responsiveBirim * 0.02),
                                                  Text("Giriş Yap", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.09, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1)),
                                                  SizedBox(height: responsiveBirim * 0.06),
                                                  
                                                  // TEXTFIELD'LAR (Artık hepsi çalışacak)
                                                  TextField(
                                                    style: TextStyle(fontSize: responsiveBirim * 0.04), 
                                                    decoration: _inputDecoration(responsiveBirim, hintText: "E-posta Adresi", icon: Icons.alternate_email)
                                                  ),
                                                  
                                                  SizedBox(height: responsiveBirim * 0.03),
                                                  
                                                  TextField(
                                                    obscureText: _sifreGizli, 
                                                    style: TextStyle(fontSize: responsiveBirim * 0.04), 
                                                    decoration: _inputDecoration(
                                                      responsiveBirim, 
                                                      hintText: "Şifre", 
                                                      icon: Icons.vpn_key_outlined, 
                                                      suffixIcon: IconButton(icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: responsiveBirim * 0.05), onPressed: () => setState(() => _sifreGizli = !_sifreGizli))
                                                    )
                                                  ),

                                                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text("Şifremi Unuttum", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: responsiveBirim * 0.032)))),
                                                  SizedBox(height: responsiveBirim * 0.02),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(child: Text("Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.", style: TextStyle(fontSize: responsiveBirim * 0.028, color: Colors.black45, height: 1.4))),
                                                      SizedBox(width: responsiveBirim * 0.05),
                                                      InkWell(onTap: () {}, child: Container(width: responsiveBirim * 0.18, height: responsiveBirim * 0.13, decoration: BoxDecoration(color: const Color(0xFF1E201C), borderRadius: BorderRadius.circular(30)), child: Icon(Icons.arrow_forward, color: Colors.white, size: responsiveBirim * 0.07))),
                                                    ],
                                                  ),
                                                  SizedBox(height: responsiveBirim * 0.02),
                                                  Center(child: Padding(padding: EdgeInsets.only(top: responsiveBirim * 0.02), child: Text("Lütfen sorumlu bir şekilde kullanın!", style: TextStyle(fontSize: responsiveBirim * 0.025, color: Colors.black38)))),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // --- KRİTİK DÜZELTME SONU ---
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