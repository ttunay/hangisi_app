import 'dart:ui'; // Glassmorphism (Blur) için gerekli kütüphane
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class UreticiProfilEkrani extends StatefulWidget {
  const UreticiProfilEkrani({super.key});

  @override
  State<UreticiProfilEkrani> createState() => _UreticiProfilEkraniState();
}

class _UreticiProfilEkraniState extends State<UreticiProfilEkrani> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  
  // Controllerlar
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _ciftlikBilgisiController = TextEditingController();
  final TextEditingController _hakkimdaController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();

  bool _isSaving = false;

  // --- TEMA RENKLERİ ---
  final List<Color> _temaRenkleri = [
    const Color.fromARGB(255, 191, 231, 185), // Koyu Yeşil
    const Color.fromARGB(255, 239, 209, 240), // Kırmızı
    const Color.fromARGB(255, 146, 193, 231), // Açık Yeşil
    const Color.fromARGB(255, 203, 228, 164), // Kahverengi
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _ciftlikBilgisiController.dispose();
    _hakkimdaController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  // --- ARKA PLAN (Glassmorphism Eklendi) ---
  Widget _buildBackground() {
    return Stack(
      children: [
        // 1. Zemin Rengi
        Container(color: Color.fromARGB(255, 215, 244, 255)), 
        
        // 2. Resim
        Positioned.fill(
          child: Image.asset(
            'assets/inekler.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),

        // 3. BUZLU CAM EFEKTİ (GLASSMORPHISM)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Bulanıklık miktarı
            child: Container(
              color: Colors.white.withOpacity(0.3), // Hafif beyaz perde
            ),
          ),
        ),
      ],
    );
  }

  // --- DÜZENLEME MODALI ---
  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran genişleyebilmesi için şart
      backgroundColor: Colors.transparent, // Arka planı şeffaf yapıyoruz ki köşeler yuvarlak kalsın
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.60, // İlk açılışta ekranın %65'ini kaplasın
        minChildSize: 0.4, // En az %40'a kadar küçülebilsin
        maxChildSize: 0.95, // En fazla %95'e kadar (neredeyse tam ekran) büyüyebilsin
        expand: false, // İçerik kadar yer kaplaması için false
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            // Klavye açıldığında padding vererek içeriği yukarı itiyoruz
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              // BU KISIM ÇOK ÖNEMLİ:
              // DraggableScrollableSheet'in verdiği controller'ı buraya bağlıyoruz.
              // Böylece hem sayfa kayıyor hem de liste scroll oluyor.
              controller: scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gri Çizgi (Tutacak)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      "Profili Düzenle",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E201C),
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildInput(_adSoyadController, "Ad Soyad", Icons.person),
                    const SizedBox(height: 15),
                    _buildInput(_ciftlikBilgisiController, "Çiftlik İsmi", Icons.agriculture),
                    const SizedBox(height: 15),
                    _buildInput(_konumController, "Konum", Icons.location_on),
                    const SizedBox(height: 15),
                    _buildInput(_hakkimdaController, "Hakkımda", Icons.description, maxLines: 3),

                    const SizedBox(height: 30),

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
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Kaydet",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 70, 70, 70)),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF2D5A27))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;

    // Profil resmi çapı
    final double avatarDiameter = birim * 0.30;
    
    // PP'nin soldan ne kadar içeride olacağı
    final double contentPadding = 30.0; 

    return Stack(
      children: [
        // 1. ARKA PLAN
        _buildBackground(),

        // 2. İÇERİK
        Scaffold(
          backgroundColor: Colors.transparent,
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              var data = snapshot.data!.data() as Map<String, dynamic>?;
              String adSoyad = data?['adSoyad'] ?? "İsimsiz Üretici";
              String ciftlik = data?['ciftlikBilgisi'] ?? "Çiftlik Bilgisi Yok";
              String hakkimda = data?['hakkimda'] ?? "Henüz bilgi girilmemiş.";
              String konum = data?['konum'] ?? "Konum Yok";

              // Edit controllerlarını güncelle
              if (_adSoyadController.text.isEmpty) _adSoyadController.text = adSoyad;
              if (_ciftlikBilgisiController.text.isEmpty) _ciftlikBilgisiController.text = ciftlik;
              if (_hakkimdaController.text.isEmpty) _hakkimdaController.text = hakkimda;
              if (_konumController.text.isEmpty) _konumController.text = konum;

              return CustomScrollView(
                slivers: [
                  // --- A. ÜST BOŞLUK ---
                 SliverAppBar(
  // BURAYI GÜNCELLE: 
  // 0.85 yaparsan, ekranın %85'i boş (resim) olur, kart en altta %15'lik kısımda başlar.
  expandedHeight: size.height * 0.53, 
  
  pinned: false, 
  floating: false,
  snap: false,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  systemOverlayStyle: SystemUiOverlayStyle.dark, 
  flexibleSpace: FlexibleSpaceBar(
    background: Container(color: Colors.transparent), 
  ),
),

                  // --- B. PROFİL KARTI VE İÇERİK ---
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. BEYAZ KART
                        Container(
                          margin: EdgeInsets.only(top: avatarDiameter / 2), 
                          constraints: BoxConstraints(minHeight: size.height * 0.7),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(contentPadding, 24, contentPadding, 100), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                // Boşluk
                                SizedBox(height: (avatarDiameter / 2) + 5),
                                
                                // İSİM VE BİLGİLER
                                Text(
                                  adSoyad, 
                                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF1E201C))
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ciftlik, 
                                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600)
                                ),
                                const SizedBox(height: 12),
                                
                                // KONUM ROZETİ
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 30, 77, 24).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Color(0xFF2D5A27)),
                                      const SizedBox(width: 4),
                                      Flexible(child: Text(konum, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D5A27)), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // HAKKIMDA
                                Text("Hakkımda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                                const SizedBox(height: 5),
                                Text(hakkimda, style: TextStyle(color: Colors.grey.shade600, height: 1.5), textAlign: TextAlign.left),

                                const SizedBox(height: 25),

                                // İSTATİSTİKLER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem("Ürünler", "12"),
                                    _buildStatItem("Takipçi", "1.2k"),
                                    _buildStatItem("Puan", "4.8"),
                                  ],
                                ),

                                const SizedBox(height: 25),

                                // ÜRÜNLER
                                Text("Ürünlerim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                                const SizedBox(height: 15),
                                
                                SizedBox(
                                  // Liste yüksekliği: Kutu (140) + Text + Boşluklar için yeterli alan
                                  height: 200, 
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('urunler').where('ureticiId', isEqualTo: user?.uid).snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                      if (snapshot.data!.docs.isEmpty) return Center(child: Text("Henüz ürün yok.", style: TextStyle(color: Colors.grey.shade500)));
                                      
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          var urun = snapshot.data!.docs[index];
                                          return _buildProductCard(urun['urunAdi'], index);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. PROFİL RESMİ
                        Positioned(
                          top: 0,
                          left: contentPadding,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 6),
                            ),
                            child: CircleAvatar(
                              radius: avatarDiameter / 2, 
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: const AssetImage('assets/uretici.png'),
                            ),
                          ),
                        ),

                        // 3. DÜZENLE BUTONU
                        Positioned(
                          top: (avatarDiameter / 2) + 20, 
                          right: contentPadding, 
                          child: InkWell(
                            onTap: _showEditSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                "Profili düzenle",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0), 
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _buildStatItem(String label, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromARGB(255, 146, 193, 231)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 146, 193, 231))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 146, 193, 231))), 
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, int index) {
    // Baz rengi alıyoruz
    Color baseColor = _temaRenkleri[index % _temaRenkleri.length];
    
    // HSL kullanarak KOYU (Kutu) ve AÇIK (İkon) tonları üretiyoruz
    HSLColor hsl = HSLColor.fromColor(baseColor);
    Color darkBoxColor = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor(); // Biraz koyulaştır
    Color lightIconColor = hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor(); // İyice aç

    return Container(
      // Genişlik (Metin ortalaması ve tıklama alanı için)
      width: 110, 
      margin: const EdgeInsets.only(right: 20),
      // BEYAZ KUTU (Decoration) KALDIRILDI
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // Kutu Boyutu
            height: 110, width: 110, 
            decoration: BoxDecoration(
              color: darkBoxColor, // KOYU TON
              borderRadius: BorderRadius.circular(20), 
              // Hafif bir gölge ekleyelim ki boşlukta kaybolmasın
              boxShadow: [
                BoxShadow(
                  color: darkBoxColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            // İkon Boyutu
            child: Icon(Icons.eco, color: lightIconColor, size: 60),
          ),
          const SizedBox(height: 12),
          // İsim
          Text(
            name, 
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: Color.fromARGB(255, 0, 0, 0), // Koyu yazı rengi
            ), 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}