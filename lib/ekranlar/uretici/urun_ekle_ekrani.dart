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

    if (_adController.text.trim().isEmpty ||
        _barkodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lütfen Ürün Adı ve Barkod alanlarını doldurun!")),
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

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color.fromARGB(255, 228, 242, 247)),
        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          _buildBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kullanicilar')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String adSoyad = "Üretici";
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  adSoyad = data['adSoyad'] ?? "Üretici";
                }

                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            birim * 0.06, birim * 0.06, birim * 0.06, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Merhaba",
                                style: TextStyle(
                                    fontSize: birim * 0.050,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold)),
                            Text(adSoyad,
                                style: TextStyle(
                                    fontSize: birim * 0.07,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                      ),

                      // --- KAYDIRILABİLİR KISIM (Form) ---
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: birim * 0.06, vertical: birim * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // --- TEK BÜYÜK KUTU (FORM KARTI) ---
                              Container(
                                padding: EdgeInsets.all(birim * 0.05),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Yazıyı sola yasla
                                  children: [
                                    // --- BAŞLIK BURAYA TAŞINDI ---
                                    Text("Yeni Ürün Ekle",
                                        style: TextStyle(
                                            fontSize: birim * 0.060,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E201C))),
                                    SizedBox(height: birim * 0.04), 
                                    // -----------------------------

                                    _inputAlan(_adController, "Ürün Adı",
                                        Icons.shopping_bag_outlined, birim),
                                    SizedBox(height: birim * 0.04),
                                    _inputAlan(_barkodController, "Barkod (Örnek: DOM-01)",
                                        Icons.qr_code_scanner, birim),
                                    SizedBox(height: birim * 0.04),
                                    _inputAlan(_tohumController, "Tohum Bilgisi",
                                        Icons.grass, birim),
                                    SizedBox(height: birim * 0.04),
                                    _inputAlan(_gubreController, "Gübre Bilgisi ",
                                        Icons.opacity, birim),
                                    SizedBox(height: birim * 0.04),
                                    _inputAlan(_ilacController, "İlaçlama Bilgisi",
                                        Icons.sanitizer, birim),
                                    SizedBox(height: birim * 0.04),
                                    _inputAlan(_aciklamaController, "Açıklama",
                                        Icons.description, birim,
                                        maxLines: 3),
                                  ],
                                ),
                              ),
                              // -----------------------------------

                              SizedBox(height: birim * 0.03),

                              // Kaydet Butonu
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E201C),
                                    minimumSize: Size(
                                        birim * 0.35, birim * 0.15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30)),
                                    elevation: 1,
                                  ),
                                  onPressed: _isLoading ? null : _urunKaydet,
                                  child: _isLoading
                                      ? SizedBox(
                                          height: birim * 0.06,
                                          width: birim * 0.06,
                                          child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : Text("Ürünü Kaydet",
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: birim * 0.040,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),

                              // Alt menünün altında kalmaması için boşluk
                              SizedBox(height: birim * 0.2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- GÜNCELLENEN INPUT ALANI ---
  Widget _inputAlan(TextEditingController controller, String label,
      IconData icon, double birim,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: birim * 0.04, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontSize: birim * 0.04, color: Colors.grey.shade600),
        prefixIcon: Icon(icon,
            color: const Color(0xFF1E201C), size: birim * 0.06),
        
        // Çerçeve Ayarları
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E201C), width: 1.5),
        ),
        
        contentPadding: EdgeInsets.symmetric(
            horizontal: birim * 0.04, vertical: birim * 0.04),
      ),
    );
  }
}