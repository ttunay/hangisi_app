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
  final TextEditingController _hakkimdaController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();

  bool _isSaving = false;

  final List<Color> _temaRenkleri = [
    const Color(0xFF2D5A27), 
    const Color(0xFFB92A2F), 
    const Color(0xFF8B5A2B), 
    const Color(0xFF4F772D)
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _hakkimdaController.dispose();
    _konumController.dispose();
    super.dispose();
  }

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
          height: size.height * 0.75,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: birim * 0.06,
              right: birim * 0.06,
              top: birim * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: SingleChildScrollView(
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
                  _glassInputField(_konumController, "Konum", Icons.location_on_outlined, birim),
                  SizedBox(height: birim * 0.05),
                  _glassInputField(_hakkimdaController, "Hakkımda",
                      Icons.description_outlined, birim,
                      maxLines: 3),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kullanicilar')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var data = snapshot.data!.data() as Map<String, dynamic>?;

          String adSoyad = data?['adSoyad'] ?? "Tüketici";
          String hakkimda = data?['hakkimda'] ?? "Açıklama eklenmedi.";
          String konum = data?['konum'] ?? "Konum girilmedi.";
          List favoriIds = data?['favoriler'] ?? [];

          if (_adSoyadController.text.isEmpty) _adSoyadController.text = adSoyad;
          if (_hakkimdaController.text.isEmpty) _hakkimdaController.text = hakkimda;
          if (_konumController.text.isEmpty) _konumController.text = konum;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.06),
                _buildKapakVeProfil(data?['kapakUrl'], data?['profilUrl'], size, birim),
                SizedBox(height: birim * 0.12),
                Center(
                  child: Column(
                    children: [
                      Text(adSoyad,
                          style: TextStyle(
                              fontSize: birim * 0.065, fontWeight: FontWeight.bold)),
                      Text("Bilinçli Tüketici",
                          style: TextStyle(color: Colors.black54, fontSize: birim * 0.042)),
                    ],
                  ),
                ),
                SizedBox(height: birim * 0.08),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: birim * 0.05),
                  child: Column(
                    children: [
                      _glassInputFieldStatic(hakkimda, "Hakkımda", Icons.info_outline, birim, maxLines: 3),
                      SizedBox(height: birim * 0.04),
                      _glassInputFieldStatic(konum, "Konum", Icons.location_on_outlined, birim),
                    ],
                  ),
                ),
                SizedBox(height: birim * 0.08),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                  child: Text("Favori Ürünlerim", style: TextStyle(fontSize: birim * 0.05, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                SizedBox(height: birim * 0.03),
                SizedBox(
                  height: birim * 0.5,
                  child: favoriIds.isEmpty 
                    ? Center(child: Text("Henüz favori ürününüz yok.", style: TextStyle(color: Colors.black54, fontSize: birim * 0.035)))
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('urunler').snapshots(),
                        builder: (context, urunSnap) {
                          if (!urunSnap.hasData) return const SizedBox();
                          var favoriListesi = urunSnap.data!.docs.where((doc) => favoriIds.contains(doc.id)).toList();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: favoriListesi.length,
                            padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                            itemBuilder: (context, index) {
                              var urunData = favoriListesi[index].data() as Map<String, dynamic>;
                              return _buildProductCard(urunData['urunAdi'] ?? "Ürün", index, birim);
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
    );
  }

  Widget _buildProductCard(String name, int index, double birim) {
    Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];
    return Container(
      width: birim * 0.35,
      margin: EdgeInsets.only(right: birim * 0.04),
      child: Column(
        children: [
          Container(
            height: birim * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(color: kartRengi, borderRadius: BorderRadius.circular(22)),
            child: Icon(Icons.eco, color: Colors.black.withOpacity(0.1), size: birim * 0.15),
          ),
          SizedBox(height: birim * 0.02),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: birim * 0.035, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

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
              color: const Color(0xFF2D5A27),
              borderRadius: BorderRadius.circular(25)),
          child: Stack(
            children: [
              if (kapakUrl != null && kapakUrl.isNotEmpty)
                ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(kapakUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: size.height * 0.18,
                        errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF2D5A27)))),
              Positioned(
                top: birim * 0.04,
                right: birim * 0.04,
                child: GestureDetector(
                  onTap: _showEditSheet,
                  child: Container(
                    padding: EdgeInsets.all(birim * 0.02),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
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
            padding: EdgeInsets.all(birim * 0.02), // Üreticideki ile aynı dış boşluk
            decoration: const BoxDecoration(color: Color(0xFFE7E9E8), shape: BoxShape.circle),
            child: Container(
              padding: const EdgeInsets.all(1.5), // Siyah hattı oluşturan katman
              decoration: const BoxDecoration(color: Color(0xFF1E201C), shape: BoxShape.circle),
              child: CircleAvatar(
                radius: birim * 0.14,
                backgroundColor: Colors.white,
                backgroundImage: (profilUrl != null && profilUrl.isNotEmpty)
                    ? NetworkImage(profilUrl)
                    : const AssetImage('assets/tuketici.png') as ImageProvider,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassInputFieldStatic(String value, String label, IconData icon, double birim, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.4))),
      child: TextFormField(
        key: ValueKey(value), 
        initialValue: value,
        readOnly: true,
        maxLines: maxLines,
        style: TextStyle(fontSize: birim * 0.04, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: birim * 0.048, color: Colors.black54, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.black87, size: birim * 0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: birim * 0.05, horizontal: birim * 0.05),
        ),
      ),
    );
  }

  Widget _glassInputField(TextEditingController controller, String label, IconData icon, double birim, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.4))),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: birim * 0.04),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: birim * 0.048, color: Colors.black54, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.black87, size: birim * 0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: birim * 0.05, horizontal: birim * 0.05),
        ),
      ),
    );
  }
}