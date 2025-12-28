import 'package:flutter/material.dart';
import 'dart:ui'; // Buzlu cam efekti için
import '../../yapilandirma/tema.dart';
import 'kayit_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  bool _sifreGizli = true;

  // --- RESPONSIVE INPUT DECORATION ---
  // Boyutları sabit piksel değil, responsive birime göre ayarlıyoruz.
  InputDecoration _inputDecoration(double birim, {
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha(179), // ~0.7 opaklık
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.black45, 
        fontSize: birim * 0.04 // Responsive font
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: birim * 0.05, 
        horizontal: birim * 0.05
      ),
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

  @override
  Widget build(BuildContext context) {
    // EKRAN BOYUTLARINI AL
    final size = MediaQuery.of(context).size;
    
    // RESPONSIVE BİRİM (Kısa Kenar):
    // Telefon yan da olsa dik de olsa yazı ve kutu boyutları
    // bu değere göre oranlanacak. Böylece devasa olmazlar.
    final double responsiveBirim = size.shortestSide;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      // Klavye açıldığında tasarımın yukarı kaymasını sağlar
      resizeToAvoidBottomInset: true, 
      
      // ORIENTATION BUILDER: Ekranın dönüşünü dinler
      body: OrientationBuilder(
        builder: (context, orientation) {
          // Ekran yatay modda mı?
          final bool isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // 1. KATMAN: ARKA PLAN (DÖNEN VE KAPLAYAN)
              // ============================================================
              Positioned.fill(
                // RotatedBox: Ekran yan ise arka plan resmini de çevirir.
                // Böylece desen bozulmaz ve ekranı tam kaplar.
                child: RotatedBox(
                  quarterTurns: isLandscape ? 3 : 0, 
                  child: Image.asset(
                    'assets/giris_bg.png', 
                    fit: BoxFit.cover, 
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(); 
                    },
                  ),
                ),
              ),

              // ============================================================
              // 2. KATMAN: GİRİŞ KARTI (MERKEZLİ VE KAYDIRILABİLİR)
              // ============================================================
              Center(
                // SingleChildScrollView: Ekran yan döndüğünde dikey alan
                // çok azalır. İçeriğin sığması için kaydırma özelliği şarttır.
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Padding(
                    // Yanlardan boşluk (Kısa kenarın %6'sı)
                    padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
                    
                    // ConstrainedBox: Tablet gibi geniş ekranlarda
                    // kartın aşırı uzamasını engeller (Maksimum 450px).
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            // İç boşluklar (Responsive)
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveBirim * 0.07, 
                              vertical: responsiveBirim * 0.05 // Dikeyde sıkı tutuldu
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
                                // --- ÜST KISIM (Marka & Kayıt Ol) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "hangisi?",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: responsiveBirim * 0.045,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const KayitEkrani()),
                                        );
                                      },
                                      child: Text(
                                        "Kayıt Ol",
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
                                  "Giriş Yap",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: responsiveBirim * 0.09, // Büyük Responsive Başlık
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -1,
                                  ),
                                ),

                                SizedBox(height: responsiveBirim * 0.06),

                                // --- E-POSTA ---
                                TextField(
                                  style: TextStyle(fontSize: responsiveBirim * 0.04),
                                  decoration: _inputDecoration(
                                    responsiveBirim,
                                    hintText: "E-posta Adresi",
                                    icon: Icons.alternate_email,
                                  ),
                                ),

                                SizedBox(height: responsiveBirim * 0.03),

                                // --- ŞİFRE ---
                                TextField(
                                  obscureText: _sifreGizli,
                                  style: TextStyle(fontSize: responsiveBirim * 0.04),
                                  decoration: _inputDecoration(
                                    responsiveBirim,
                                    hintText: "Şifre",
                                    icon: Icons.vpn_key_outlined,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _sifreGizli ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.black45,
                                        size: responsiveBirim * 0.05,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _sifreGizli = !_sifreGizli;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                // --- ŞİFREMİ UNUTTUM ---
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Şifrenizi mi unuttunuz?",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                        fontSize: responsiveBirim * 0.032,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: responsiveBirim * 0.02),

                                // --- ALT KISIM (Metin + Buton) ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Devam ederek, Gizlilik Politikamızı ve Kullanım Koşullarımızı kabul etmiş olursunuz.",
                                        style: TextStyle(
                                          fontSize: responsiveBirim * 0.028,
                                          color: Colors.black45,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    
                                    SizedBox(width: responsiveBirim * 0.05),

                                    // İLERLEME BUTONU
                                    InkWell(
                                      onTap: () {
                                        // Giriş işlemleri
                                      },
                                      child: Container(
                                        width: responsiveBirim * 0.18,
                                        height: responsiveBirim * 0.13,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E201C),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: responsiveBirim * 0.07,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: responsiveBirim * 0.05),
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