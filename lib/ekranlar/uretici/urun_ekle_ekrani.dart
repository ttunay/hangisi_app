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

  // Formu sıfırlamak için yardımcı fonksiyon
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
        // İşlem başarılı olduğunda yapılacaklar:
        _formuSifirla(); // 1. Yazıları temizle
        setState(() => _isLoading = false); // 2. Yüklenme işaretini durdur
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ürün başarıyla kaydedildi!")),
        );
        
        // Eğer sayfadan çıkmak yerine kalmak isterseniz pop satırını silebilirsiniz
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false); // Hata durumunda da yüklenmeyi durdur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          String adSoyad = "Üretici";
          if (snapshot.hasData && snapshot.data!.exists) {
            adSoyad = snapshot.data!['adSoyad'] ?? "Üretici";
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(birim * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Merhaba", style: TextStyle(fontSize: birim * 0.045, color: Colors.grey.shade600)),
                  Text(adSoyad, style: TextStyle(fontSize: birim * 0.07, fontWeight: FontWeight.bold)),
                  
                  const SizedBox(height: 25),

                  Text("Yeni Ürün Ekle", 
                    style: TextStyle(fontSize: birim * 0.055, fontWeight: FontWeight.bold, color: const Color(0xFF1E201C))
                  ),
                  
                  SizedBox(height: birim * 0.06),

                  _inputAlan(_adController, "Ürün Adı", Icons.shopping_bag_outlined),
                  const SizedBox(height: 15),
                  _inputAlan(_barkodController, "Benzersiz Barkod (Örn: DOM-01)", Icons.qr_code_scanner),
                  const SizedBox(height: 15),
                  _inputAlan(_tohumController, "Kullanılan Tohum", Icons.grass),
                  const SizedBox(height: 15),
                  _inputAlan(_gubreController, "Kullanılan Gübre", Icons.opacity),
                  const SizedBox(height: 15),
                  _inputAlan(_ilacController, "İlaçlama Bilgisi", Icons.sanitizer),
                  const SizedBox(height: 15),
                  _inputAlan(_aciklamaController, "Ürün Açıklaması / Hikayesi", Icons.description, maxLines: 4),

                  SizedBox(height: birim * 0.08),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A27),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _urunKaydet,
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ) 
                      : const Text("Ürünü Kaydet", 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputAlan(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2D5A27)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}