import 'dart:ui'; // Blur efekti için gerekli
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UrunEkleEkrani extends StatefulWidget {
  const UrunEkleEkrani({super.key});

  @override
  State<UrunEkleEkrani> createState() => _UrunEkleEkraniState();
}

class _UrunEkleEkraniState extends State<UrunEkleEkrani> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false; 
  
  final _adController = TextEditingController();
  final _barkodController = TextEditingController();
  final _tohumController = TextEditingController();
  final _gubreController = TextEditingController();
  final _ilacController = TextEditingController();
  final _aciklamaController = TextEditingController();

  @override
  void dispose() {
    _adController.dispose();
    _barkodController.dispose();
    _tohumController.dispose();
    _gubreController.dispose();
    _ilacController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  void _formuSifirla() {
    _adController.clear();
    _barkodController.clear();
    _tohumController.clear();
    _gubreController.clear();
    _ilacController.clear();
    _aciklamaController.clear();
  }

  Future<void> _urunKaydet() async {
    if (user == null || _isLoading) return;

    if (_adController.text.trim().isEmpty || _barkodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen Ürün Adı ve Barkod alanlarını doldurun!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('urunler').add({
        'ureticiId': user!.uid,
        'urunAdi': _adController.text.trim(),
        'barkod': _barkodController.text.trim(), 
        'tohum': _tohumController.text.trim(),
        'gubre': _gubreController.text.trim(),
        'ilac': _ilacController.text.trim(),
        'aciklama': _aciklamaController.text.trim(),
        'tarih': Timestamp.now(),
      });

      if (mounted) {
        _formuSifirla();
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ürün başarıyla kaydedildi!")),
        );
        
        // Klavye açıksa kapat
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e")),
        );
      }
    }
  }

  // --- ARKA PLAN KATMANLARI ---
  Widget _buildBackground() {
    return Stack(
      children: [
        // 1. Gri Zemin
        Container(color: Color.fromARGB(255, 215, 244, 255)), //ZEMİN RENGİ

        // 2. İnekler Resmi
        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),

        // 3. Buzlu Cam (Glassmorphism)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Hafif blur
            child: Container(
              color: Colors.white.withOpacity(0.35), // Hafif beyaz perde
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekranın kısa kenarını referans al (Yatay/Dikey uyumu için)
    final double birim = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Boşluğa tıklayınca klavye kapanır
      child: Stack(
        children: [
          // Katman 1-2-3: Arka Plan
          _buildBackground(),

          // Katman 4: İçerik
          Scaffold(
            backgroundColor: Colors.transparent, // Arka planı görmek için şeffaf
            resizeToAvoidBottomInset: true, // Klavye açılınca yukarı kayması için
            
            body: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
              builder: (context, snapshot) {
                String adSoyad = "Üretici";
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  adSoyad = data['adSoyad'] ?? "Üretici";
                }

                return SafeArea(
                  child: SingleChildScrollView(
                    // Fare tekeri ve kaydırma her zaman çalışsın
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(birim * 0.06, birim * 0.06, birim * 0.06, birim * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Başlıklar
                        Text("Merhaba", style: TextStyle(fontSize: birim * 0.050, color: Colors.black54, fontWeight: FontWeight.bold)),
                        Text(adSoyad, style: TextStyle(fontSize: birim * 0.07, fontWeight: FontWeight.bold, color: Colors.black87)),
                        
                        SizedBox(height: birim * 0.08),

                        Text("Yeni Ürün Ekle", 
                          style: TextStyle(fontSize: birim * 0.060, fontWeight: FontWeight.bold, color: const Color(0xFF1E201C))
                        ),
                        
                        SizedBox(height: birim * 0.04),

                        // Form Alanları (Dynamic Spacing)
                        _inputAlan(_adController, "Ürün Adı", Icons.shopping_bag_outlined, birim),
                        SizedBox(height: birim * 0.04),
                        _inputAlan(_barkodController, "Barkod (Örn: DOM-01)", Icons.qr_code_scanner, birim),
                        SizedBox(height: birim * 0.04),
                        _inputAlan(_tohumController, "Kullanılan Tohum", Icons.grass, birim),
                        SizedBox(height: birim * 0.04),
                        _inputAlan(_gubreController, "Kullanılan Gübre", Icons.opacity, birim),
                        SizedBox(height: birim * 0.04),
                        _inputAlan(_ilacController, "İlaçlama Bilgisi", Icons.sanitizer, birim),
                        SizedBox(height: birim * 0.04),
                        _inputAlan(_aciklamaController, "Ürün Açıklaması", Icons.description, birim, maxLines: 2),
                        SizedBox(height: birim * 0.08),

                        // Kaydet Butonu
                         Center(
                           child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1E201C),         
                                minimumSize: Size(birim*0.35, birim * 0.15), // Buton yüksekliği responsive
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 1,
                              ),
                              onPressed: _isLoading ? null : _urunKaydet,
                              child: _isLoading 
                                ? SizedBox(
                                    height: birim * 0.06, 
                                    width: birim * 0.06, 
                                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  ) 
                                : Text("Ürünü Kaydet", 
                                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: birim * 0.040, fontWeight: FontWeight.bold)
                                  ),
                            ),
                         ),
                        
                        SizedBox(height: birim * 0.05),
      
                        // Alt menünün altında kalmaması için boşluk
                        SizedBox(height: birim * 0.2), 
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputAlan(TextEditingController controller, String hint, IconData icon, double birim, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        // Arka planı hafif şeffaf beyaz yaptık ki glassmorphism ile uyumlu olsun
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: birim * 0.04, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: birim * 0.04, color: Colors.black54),
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0), size: birim * 0.06),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: birim * 0.05, vertical: birim * 0.04),
        ),
      ),
    );
  }
}