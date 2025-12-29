import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TuketiciProfilEkrani extends StatefulWidget {
  const TuketiciProfilEkrani({super.key});

  @override
  State<TuketiciProfilEkrani> createState() => _TuketiciProfilEkraniState();
}

class _TuketiciProfilEkraniState extends State<TuketiciProfilEkrani> {
  final User? user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _ciftlikBilgisiController = TextEditingController();
  final TextEditingController _hakkimdaController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();

  bool _isSaving = false;

  // Ürün listesindeki renk paleti
  final List<Color> _temaRenkleri = [
    const Color(0xFFB92A2F), // Domates Kırmızısı
    const Color(0xFF2D5A27), // Koyu Yaprak Yeşili
    const Color(0xFFE23E44), // Parlak Kırmızı
    const Color(0xFF4F772D), // Çimen Yeşili
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _ciftlikBilgisiController.dispose();
    _hakkimdaController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  // --- ÜRÜN KARTI ---
  Widget _buildProductCard(String name, int index, double birim) {
    Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];
    
    return Container(
      width: birim * 0.35,
      margin: EdgeInsets.only(right: birim * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: birim * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.eco,
              color: Colors.black.withOpacity(0.1),
              size: birim * 0.15,
            ),
          ),
          SizedBox(height: birim * 0.02),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: birim * 0.035,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- DÜZENLEME PENCERESİ (MODAL) ---
  void _showEditSheet() {
    final size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: size.height * 0.85,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: birim * 0.06,
              right: birim * 0.06,
              top: birim * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.80),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                      width: birim * 0.12,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10))),
                  SizedBox(height: birim * 0.06),
                  Text("Profili Düzenle",
                      style: TextStyle(
                          fontSize: birim * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  SizedBox(height: birim * 0.08),
                  
                  _glassInputField(_adSoyadController, "Ad Soyad", Icons.person_outline, birim),
                  SizedBox(height: birim * 0.05),
                  _glassInputField(_ciftlikBilgisiController, "Çiftlik Bilgisi", Icons.agriculture_outlined, birim),
                  SizedBox(height: birim * 0.05),
                  _glassInputField(_konumController, "Konum", Icons.location_on_outlined, birim),
                  SizedBox(height: birim * 0.05),
                  _glassInputField(_hakkimdaController, "Hakkımda", Icons.description_outlined, birim, maxLines: 3),
                  
                  SizedBox(height: birim * 0.1),
                  ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isSaving = true);
                              await FirebaseFirestore.instance
                                  .collection('kullanicilar')
                                  .doc(user!.uid)
                                  .update({
                                'adSoyad': _adSoyadController.text,
                                'ciftlikBilgisi': _ciftlikBilgisiController.text,
                                'hakkimda': _hakkimdaController.text,
                                'konum': _konumController.text,
                              });
                              setState(() => _isSaving = false);
                              if (mounted) Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E201C),
                      minimumSize: Size(double.infinity, birim * 0.14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      elevation: 5,
                    ),
                    child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Kaydet",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: birim * 0.045)),
                  ),
                  SizedBox(height: birim * 0.08),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- ARKA PLAN KATMANLARI (GÜNCELLENDİ) ---
  Widget _buildBackgroundLayers() {
    return Stack(
      children: [
        // KATMAN 1: Tema Grisi (Zemin)
        Container(color: const Color(0xFFE7E9E8)),

        // KATMAN 2: İnekler Resmi
        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(), 
          ),
        ),

        // KATMAN 3: Glassmorphism (DAHA AZ BLUR, DAHA ÇOK ŞEFFAFLIK)
        Positioned.fill(
          child: BackdropFilter(
            // GÜNCELLEME: Blur 10'dan 3'e düşürüldü (İnekler netleşti)
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              // GÜNCELLEME: Opaklık 0.3'ten 0.1'e düşürüldü (Daha şeffaf)
              color: Colors.white.withOpacity(0.1), 
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;

    return Stack(
      children: [
        // Arka Plan Katmanları
        _buildBackgroundLayers(),

        // İçerik (Scaffold şeffaf)
        Scaffold(
          backgroundColor: Colors.transparent,
          
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              var data = snapshot.data!.data() as Map<String, dynamic>?;

              String adSoyad = data?['adSoyad'] ?? "İsimsiz";
              String ciftlikBilgisi = data?['ciftlikBilgisi'] ?? "Çiftlik Bilgisi Yok";
              String hakkimda = data?['hakkimda'] ?? "Açıklama eklenmedi.";
              String konum = data?['konum'] ?? "Konum girilmedi.";

              if (_adSoyadController.text.isEmpty) _adSoyadController.text = adSoyad;
              if (_ciftlikBilgisiController.text.isEmpty) _ciftlikBilgisiController.text = ciftlikBilgisi;
              if (_hakkimdaController.text.isEmpty) _hakkimdaController.text = hakkimda;
              if (_konumController.text.isEmpty) _konumController.text = konum;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.06),
                    _buildKapakVeProfil(data?['kapakUrl'], data?['profilUrl'], size, birim),
                    SizedBox(height: birim * 0.12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(adSoyad,
                            style: TextStyle(
                                fontSize: birim * 0.065, fontWeight: FontWeight.bold)),
                        SizedBox(width: birim * 0.015),
                        Icon(Icons.verified, color: Colors.blue, size: birim * 0.06),
                      ],
                    ),
                    Center(
                      child: Text(ciftlikBilgisi,
                          style: TextStyle(color: Colors.black54, fontSize: birim * 0.042)),
                    ),
                    SizedBox(height: birim * 0.08),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: birim * 0.05),
                      child: Column(
                        children: [
                          _glassInputFieldStatic(hakkimda, "Hakkımda", Icons.info_outline, birim, maxLines: 3),
                          SizedBox(height: birim * 0.04),
                          _glassInputFieldStatic(ciftlikBilgisi, "Çiftlik Bilgisi", Icons.agriculture_outlined, birim),
                          SizedBox(height: birim * 0.04),
                          _glassInputFieldStatic(konum, "Konum", Icons.location_on_outlined, birim),
                        ],
                      ),
                    ),
                    
                    // ÜRÜNLERİM BÖLÜMÜ
                    SizedBox(height: birim * 0.08),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                      child: Text(
                        "Ürünlerim",
                        style: TextStyle(
                          fontSize: birim * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: birim * 0.03),
                    SizedBox(
                      height: birim * 0.5,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('urunler')
                            .where('ureticiId', isEqualTo: user?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                "Henüz ürün eklenmemiş.",
                                style: TextStyle(color: Colors.black54, fontSize: birim * 0.035),
                              ),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                            itemBuilder: (context, index) {
                              var urunData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              return _buildProductCard(
                                urunData['urunAdi'] ?? "Ürün",
                                index,
                                birim,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.15),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- STATİK BİLGİ ALANLARI ---
  Widget _glassInputFieldStatic(String value, String label, IconData icon, double birim, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          // Kutuların iç rengi 0.4 yapılarak arka planla daha iyi uyum sağlandı
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.4))),
      child: TextFormField(
        key: ValueKey(value), 
        initialValue: value,
        readOnly: true,
        maxLines: maxLines,
        style: TextStyle(fontSize: birim * 0.04, fontWeight: FontWeight.normal, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              fontSize: birim * 0.048, color: Colors.black54, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.black87, size: birim * 0.06),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          contentPadding:
              EdgeInsets.symmetric(vertical: birim * 0.05, horizontal: birim * 0.05),
        ),
      ),
    );
  }

  // --- KAPAK VE PROFİL RESMİ ---
  Widget _buildKapakVeProfil(String? kapakUrl, String? profilUrl, Size size, double birim) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: birim * 0.05),
          height: size.height * 0.18,
          width: double.infinity,
          decoration: BoxDecoration(
              // Kapak rengi SİYAH
              color: const Color(0xFF1E201C),
              borderRadius: BorderRadius.circular(25)),
          child: Stack(
            children: [
              if (kapakUrl != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(kapakUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: size.height * 0.18)),
              Positioned(
                top: birim * 0.04,
                right: birim * 0.04,
                child: GestureDetector(
                  onTap: _showEditSheet,
                  child: Container(
                    padding: EdgeInsets.all(birim * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: birim * 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -(birim * 0.12),
          child: Container(
            padding: EdgeInsets.all(birim * 0.02),
            decoration: const BoxDecoration(
                color: Color(0xFFE7E9E8), shape: BoxShape.circle),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Color(0xFF1E201C),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: birim * 0.14,
                backgroundColor: Colors.white,
                backgroundImage: profilUrl != null
                    ? NetworkImage(profilUrl)
                    : const AssetImage('assets/uretici.png') as ImageProvider,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- DÜZENLEME KUTUCUKLARI ---
  Widget _glassInputField(TextEditingController controller, String label,
      IconData icon, double birim,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.4))),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: TextInputType.visiblePassword, 
        style: TextStyle(fontSize: birim * 0.04, fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              fontSize: birim * 0.048, color: Colors.black54, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.black87, size: birim * 0.06),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          contentPadding:
              EdgeInsets.symmetric(vertical: birim * 0.05, horizontal: birim * 0.05),
        ),
      ),
    );
  }
}