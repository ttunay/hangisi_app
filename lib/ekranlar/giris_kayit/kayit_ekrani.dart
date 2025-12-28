import 'package:flutter/material.dart';
import 'dart:ui'; // Buzlu cam efekti için
import '../../yapilandirma/tema.dart';
import 'giris_ekrani.dart';
import 'dogrulama_ekrani.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;
  
  // Seçilen rolü tutan değişken (Varsayılan: null)
  String? _secilenRol;

  // --- RESPONSIVE INPUT DECORATION (Giriş Ekranı ile Aynı) ---
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
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black54, size: birim * 0.055),
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Colors.green, width: 2), 
      ),
    );
  }

  // --- ROL SEÇİM KUTUSU WIDGET'I ---
  Widget _buildRoleCard(double birim, {
    required String rolAdi,
    required String gorselYolu,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(birim * 0.04),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.withAlpha(30) : Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              // Seçiliyse yeşil, değilse beyazımsı çerçeve
              color: isSelected ? Colors.green : Colors.white.withAlpha(153),
              width: isSelected ? 3 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rol Görseli
              Image.asset(
                gorselYolu,
                width: birim * 0.20, // Responsive görsel boyutu
                height: birim * 0.20,
                fit: BoxFit.contain,
              ),
              SizedBox(height: birim * 0.03),
              // Rol Adı
              Text(
                rolAdi,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: birim * 0.045,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double responsiveBirim = size.shortestSide;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      resizeToAvoidBottomInset: true, 
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // --- 1. KATMAN: DÖNEN ARKA PLAN ---
              Positioned.fill(
                child: RotatedBox(
                  quarterTurns: isLandscape ? 3 : 0, 
                  child: Image.asset(
                    'assets/giris_bg.png', 
                    fit: BoxFit.cover, 
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),

              // --- 2. KATMAN: BUZLU CAM KAYIT KARTI ---
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                                // --- ÜST KISIM (Marka & Giriş Yap) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "hangisi",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: responsiveBirim * 0.045,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Giriş ekranına dön
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Giriş Yap",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: responsiveBirim * 0.04,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: responsiveBirim * 0.02),

                                // --- BAŞLIK ---
                                Text(
                                  "Kayıt Ol",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: responsiveBirim * 0.09,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -1,
                                  ),
                                ),
                                SizedBox(height: responsiveBirim * 0.05),

                                // --- FORM ALANLARI ---
                                // Ad Soyad
                                TextField(
                                  style: TextStyle(fontSize: responsiveBirim * 0.04),
                                  decoration: _inputDecoration(responsiveBirim, hintText: "Ad Soyad", icon: Icons.person_outline),
                                ),
                                SizedBox(height: responsiveBirim * 0.03),
                                
                                // E-posta
                                TextField(
                                  style: TextStyle(fontSize: responsiveBirim * 0.04),
                                  decoration: _inputDecoration(responsiveBirim, hintText: "E-posta Adresi", icon: Icons.alternate_email),
                                ),
                                SizedBox(height: responsiveBirim * 0.03),

                                // Şifre
                                TextField(
                                  obscureText: _sifreGizli,
                                  style: TextStyle(fontSize: responsiveBirim * 0.04),
                                  decoration: _inputDecoration(
                                    responsiveBirim,
                                    hintText: "Şifre",
                                    icon: Icons.vpn_key_outlined,
                                    suffixIcon: IconButton(
                                      icon: Icon(_sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: responsiveBirim * 0.05),
                                      onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsiveBirim * 0.03),

                                // Şifre Tekrar
                                TextField(
                                  obscureText: _sifreTekrarGizli,
                                  style: TextStyle(fontSize: responsiveBirim * 0.04),
                                  decoration: _inputDecoration(
                                    responsiveBirim,
                                    hintText: "Şifre Tekrar",
                                    icon: Icons.vpn_key_outlined,
                                    suffixIcon: IconButton(
                                      icon: Icon(_sifreTekrarGizli ? Icons.visibility_off : Icons.visibility, color: Colors.black45, size: responsiveBirim * 0.05),
                                      onPressed: () => setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsiveBirim * 0.05),

                                // --- ROL SEÇİMİ BAŞLIĞI ---
                                Text(
                                  "Rolünüzü Seçin",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: responsiveBirim * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: responsiveBirim * 0.03),

                                // --- ROL SEÇİM KUTULARI (YAN YANA) ---
                                Row(
                                  children: [
                                    // ÜRETİCİ KUTUSU
                                    _buildRoleCard(
                                      responsiveBirim,
                                      rolAdi: "Üretici",
                                      // Görsel adını projenizdekiyle eşleştirin
                                      gorselYolu: 'assets/uretici.png', 
                                      isSelected: _secilenRol == 'Uretici',
                                      onTap: () => setState(() => _secilenRol = 'Uretici'),
                                    ),
                                    SizedBox(width: responsiveBirim * 0.04), // Kutular arası boşluk
                                    // TÜKETİCİ KUTUSU
                                    _buildRoleCard(
                                      responsiveBirim,
                                      rolAdi: "Tüketici",
                                      // Görsel adını projenizdekiyle eşleştirin
                                      gorselYolu: 'assets/tuketici.png',
                                      isSelected: _secilenRol == 'Tuketici',
                                      onTap: () => setState(() => _secilenRol = 'Tuketici'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: responsiveBirim * 0.05),

                                // --- ALT KISIM (Yasal Metin + Kayıt Butonu) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Kayıt olarak, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.",
                                        style: TextStyle(fontSize: responsiveBirim * 0.028, color: Colors.black45, height: 1.4),
                                      ),
                                    ),
                                    SizedBox(width: responsiveBirim * 0.05),
                                    // KAYIT OL BUTONU
                                    InkWell(
  onTap: () {
    // 1. Rol seçimi kontrolü
    if (_secilenRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir rol seçiniz.")),
      );
      return; // Fonksiyonu durdur
    }
    
    // 2. TextField'ların doluluğunu kontrol edebilirsiniz (Opsiyonel)
    
    // 3. Her şey tamamsa Doğrulama Ekranına git
    // Not: Buraya kullanıcının girdiği mail adresini parametre olarak verebilirsiniz.
    // Şimdilik örnek bir mail yazıyorum.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DogrulamaEkrani(email: "ornek@mail.com"),
      ),
    );
  },
  child: Container(
    // ... (Container tasarımı aynı kalacak) ...
  ),
),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}