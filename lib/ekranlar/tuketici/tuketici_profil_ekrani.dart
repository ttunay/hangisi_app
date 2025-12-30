import 'dart:ui'; // Glassmorphism ve PointerDeviceKind için gerekli
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class TuketiciProfilEkrani extends StatefulWidget {
  const TuketiciProfilEkrani({super.key});

  @override
  State<TuketiciProfilEkrani> createState() => _TuketiciProfilEkraniState();
}

class _TuketiciProfilEkraniState extends State<TuketiciProfilEkrani> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Controllerlar
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _hakkimdaController = TextEditingController();
  final TextEditingController _konumController = TextEditingController();

  bool _isSaving = false;

  // --- TEMA RENKLERİ ---
  final List<Color> _temaRenkleri = [
    const Color.fromARGB(255, 250, 245, 197),
    const Color.fromARGB(255, 243, 204, 203),
    const Color.fromARGB(255, 226, 194, 164),
    const Color.fromARGB(255, 205, 233, 182),
    const Color.fromARGB(255, 188, 209, 233),
    const Color.fromARGB(255, 182, 236, 232),
  ];

  @override
  void dispose() {
    _adSoyadController.dispose();
    _hakkimdaController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  // --- ARKA PLAN ---
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

  // --- DÜZENLEME MODALI ---
  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _buildInput(_konumController, "Konum", Icons.location_on),
                    const SizedBox(height: 15),
                    _buildInput(_hakkimdaController, "Hakkımda",
                        Icons.description,
                        maxLines: 3),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
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
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          minimumSize: const Size(45, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Kaydet",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16),
                              ),
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

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 70, 70, 70)),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF2D5A27))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;
    final double avatarDiameter = birim * 0.30;
    final double contentPadding = 30.0;

    return Stack(
      children: [
        _buildBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              var data = snapshot.data!.data() as Map<String, dynamic>?;
              String adSoyad = data?['adSoyad'] ?? "İsimsiz Kullanıcı";
              String hakkimda =
                  data?['hakkimda'] ?? "Henüz bilgi girilmemiş.";
              String konum = data?['konum'] ?? "Konum Yok";

              // Favori listesini burada çekiyoruz
              List favoriler = data?['favoriler'] ?? [];

              if (_adSoyadController.text.isEmpty)
                _adSoyadController.text = adSoyad;
              if (_hakkimdaController.text.isEmpty)
                _hakkimdaController.text = hakkimda;
              if (_konumController.text.isEmpty)
                _konumController.text = konum;

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverAppBar(
                      stretch: true,
                      expandedHeight: size.height * 0.10,
                      pinned: false,
                      floating: false,
                      snap: false,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      systemOverlayStyle: SystemUiOverlayStyle.dark,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [StretchMode.zoomBackground],
                        background: Container(color: Colors.transparent),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: avatarDiameter / 2),
                            constraints:
                                BoxConstraints(minHeight: size.height * 0.7),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(40)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  contentPadding, 24, contentPadding, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: (avatarDiameter / 2) + 5),
                                  Text(
                                    adSoyad,
                                    style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E201C)),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.deepOrange.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 14,
                                            color: Colors.deepOrange),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            konum,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Text("Hakkımda",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade900)),
                                  const SizedBox(height: 5),
                                  Text(hakkimda,
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          height: 1.5),
                                      textAlign: TextAlign.left),
                                  const SizedBox(height: 25),
                                  
                                  // --- GÜNCELLENEN İSTATİSTİK KISMI ---
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // Burayı güncelledik: Gerçek liste uzunluğunu gösteriyor
                                      _buildStatItem("Favoriler",
                                          "${favoriler.length}"),
                                      _buildStatItem("Takip", "124"),
                                      _buildStatItem("Puan", "4.8"),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 25),
                                  Text("Favorilerim",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade900)),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 200,
                                    child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(
                                        dragDevices: {
                                          PointerDeviceKind.touch,
                                          PointerDeviceKind.mouse,
                                        },
                                      ),
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('urunler')
                                            .snapshots(),
                                        builder: (context, urunSnapshot) {
                                          if (!urunSnapshot.hasData)
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());

                                          var favoriUrunler = urunSnapshot
                                              .data!.docs
                                              .where((doc) {
                                            return favoriler
                                                .contains(doc.id);
                                          }).toList();

                                          if (favoriUrunler.isEmpty) {
                                            return Center(
                                                child: Text(
                                                    "Henüz favori ürününüz yok.",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade500)));
                                          }

                                          return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.zero,
                                            itemCount: favoriUrunler.length,
                                            itemBuilder: (context, index) {
                                              var urun = favoriUrunler[index]
                                                      .data()
                                                  as Map<String, dynamic>;
                                              return _buildProductCard(
                                                  urun['urunAdi'],
                                                  index,
                                                  birim);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: contentPadding,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 6),
                              ),
                              child: CircleAvatar(
                                radius: avatarDiameter / 2,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage:
                                    const AssetImage('assets/tuketici.png'),
                              ),
                            ),
                          ),
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
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Container(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // İSTATİSTİK KUTULARI
  Widget _buildStatItem(String label, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color.fromARGB(255, 146, 193, 231)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0))),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: Color.fromARGB(255, 0, 0, 0))),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, int index, double birim) {
    Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];

    return Container(
      width: birim * 0.28,
      margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ]),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                  color: kartRengi,
                  borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.eco,
                  color: Colors.black.withOpacity(0.1), size: birim * 0.15),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E201C),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}