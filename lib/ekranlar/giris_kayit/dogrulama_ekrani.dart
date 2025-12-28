import 'package:flutter/material.dart';
import 'dart:ui'; // Buzlu cam efekti için
import '../../yapilandirma/tema.dart';
import 'giris_ekrani.dart'; // Başarılı olursa giriş ekranına dönmek için

class DogrulamaEkrani extends StatefulWidget {
  final String email; // Hangi maile kod gittiğini göstermek için

  const DogrulamaEkrani({super.key, required this.email});

  @override
  State<DogrulamaEkrani> createState() => _DogrulamaEkraniState();
}

class _DogrulamaEkraniState extends State<DogrulamaEkrani> {
  // Her bir kutucuk için odak ve metin kontrolcüleri
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  // --- TEK BİR RAKAM KUTUCUĞU ---
  Widget _buildDigitBox(int index, double birim) {
    return Container(
      width: birim * 0.16, // Responsive genişlik
      height: birim * 0.16, // Kare olması için
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Hafif saydam beyaz
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // Odaklanınca Yeşil, değilse silik beyaz çerçeve
          color: _focusNodes[index].hasFocus ? Colors.green : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          autofocus: index == 0, // İlk kutu otomatik açılsın
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1, // Sadece 1 rakam
          style: TextStyle(
            fontSize: birim * 0.08, 
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
          decoration: const InputDecoration(
            counterText: "", // Alttaki karakter sayacını gizle
            border: InputBorder.none, // Varsayılan çizgiyi kaldır
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Rakam girildiyse sonraki kutuya geç
              if (index < 3) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              } else {
                // Son kutuysa klavyeyi kapat
                FocusScope.of(context).unfocus();
              }
            } else {
              // Silindiyse önceki kutuya dön
              if (index > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              }
            }
            setState(() {}); // Çerçeve rengini güncellemek için
          },
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
                    'assets/inekler.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),

              // --- 2. KATMAN: DOĞRULAMA KARTI ---
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
                              children: [
                                // --- ÜST KISIM (Geri Dön Butonu) ---
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black54),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                
                                SizedBox(height: responsiveBirim * 0.02),

                                // --- BAŞLIK ---
                                Text(
                                  "Doğrulama Kodu",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: responsiveBirim * 0.07,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                
                                SizedBox(height: responsiveBirim * 0.03),

                                // --- AÇIKLAMA ---
                                Text(
                                  "Lütfen ${widget.email}\nadresine gönderilen 4 haneli kodu giriniz.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsiveBirim * 0.035,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),

                                SizedBox(height: responsiveBirim * 0.08),

                                // --- 4'LÜ KUTUCUK YAPISI ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(4, (index) => _buildDigitBox(index, responsiveBirim)),
                                ),

                                SizedBox(height: responsiveBirim * 0.08),

                                // --- SAYAÇ ---
                                Text(
                                  "04:59",
                                  style: TextStyle(
                                    fontSize: responsiveBirim * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green, // Kurumsal renk
                                  ),
                                ),

                                SizedBox(height: responsiveBirim * 0.02),

                                // --- TEKRAR GÖNDER ---
                                TextButton(
                                  onPressed: () {
                                    // Kod tekrar gönderme işlemi
                                  },
                                  child: Text(
                                    "Kodu almadınız mı? Tekrar Gönder",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsiveBirim * 0.035,
                                    ),
                                  ),
                                ),

                                SizedBox(height: responsiveBirim * 0.05),

                                // --- DOĞRULA BUTONU ---
                                InkWell(
                                  onTap: () {
                                    // Kodları birleştir
                                    String kod = _controllers.map((e) => e.text).join();
                                    if (kod.length == 4) {
                                      // Başarılı doğrulama simülasyonu
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Hesabınız doğrulandı! Giriş yapabilirsiniz.")),
                                      );
                                      // Giriş ekranına yönlendir (Tüm geçmişi silerek)
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const GirisEkrani()),
                                        (route) => false,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Lütfen 4 haneli kodu eksiksiz giriniz.")),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity, // Tam genişlik
                                    height: responsiveBirim * 0.14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E201C), // Siyah tema butonu
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        )
                                      ]
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Doğrula",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveBirim * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}