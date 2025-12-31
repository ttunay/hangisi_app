import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UreticiDetaySayfasi extends StatelessWidget {
  // Bu sayfa, üreticiye ait bilgileri göstermek için üretici id'sini alır
  final String ureticiId;

  // Keşfet ekranından geldiği için adSoyad parametresi de alınır (fallback amaçlı)
  final String adSoyad;

  const UreticiDetaySayfasi({
    super.key,
    required this.ureticiId,
    required this.adSoyad,
  });

  // Üreticinin ürün kartlarında kullanılacak pastel renkler
  final List<Color> _temaRenkleri = const [
    Color.fromARGB(255, 250, 245, 197),
    Color.fromARGB(255, 243, 204, 203),
    Color.fromARGB(255, 226, 194, 164),
    Color.fromARGB(255, 205, 233, 182),
    Color.fromARGB(255, 188, 209, 233),
  ];

  @override
  Widget build(BuildContext context) {
    // Ekran boyutları
    final Size size = MediaQuery.of(context).size;

    // İstediğin standart responsive birim (kısa kenar)
    final double birim = size.shortestSide;

    // Avatar çapı (orijinal oran korunuyor)
    final double avatarDiameter = birim * 0.30;

    // Beyaz panelin iç padding değerleri (orijinal)
    final double contentPadding = 30.0;

    return Scaffold(
      // AppBar transparent olduğu için body'nin arkasına taşmasını istiyoruz
      extendBodyBehindAppBar: true,

      // Üst AppBar: Geri butonu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Body: Arka plan + üretici stream + içerik
      body: Stack(
        children: [
          // 1) Arka plan rengi
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 228, 242, 247),
            ),
          ),

          // 2) Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/inekler.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // 3) Üretici bilgilerini canlı dinleyen StreamBuilder
          //    "kullanicilar/{ureticiId}" dokümanını dinler
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(ureticiId)
                .snapshots(),
            builder: (context, snapshot) {
              // Veri gelene kadar loading
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Doküman verisini map'e çevir
              final data = snapshot.data!.data() as Map<String, dynamic>?;

              // Firestore'dan gelen veriler (fallback'lerle)
              final String guncelAd = data?['adSoyad'] ?? adSoyad;
              final String ciftlik =
                  data?['ciftlikBilgisi'] ?? "Çiftlik Bilgisi Yok";
              final String hakkimda =
                  data?['hakkimda'] ?? "Henüz bilgi girilmemiş.";
              final String konum = data?['konum'] ?? "Konum Yok";

              // Sayfa kaydırılabilir olsun (profil sayfası gibi)
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // AppBar'ın içerik üstüne binmemesi için üstten boşluk
                    SizedBox(height: size.height * 0.12),

                    // Profil paneli: Beyaz alan + üstte taşan avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Beyaz panel (avatar üstte taşacak)
                        Container(
                          margin: EdgeInsets.only(top: avatarDiameter / 2),
                          constraints: BoxConstraints(
                            minHeight: size.height * 0.8,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              contentPadding,
                              24,
                              contentPadding,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar için boşluk
                                SizedBox(height: (avatarDiameter / 2) + 5),

                                // Üretici adı
                                Text(
                                  guncelAd,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E201C),
                                  ),
                                ),

                                // Çiftlik bilgisi (alt satır)
                                const SizedBox(height: 2),
                                Text(
                                  ciftlik,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),

                                // Konum chip
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.deepOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          konum,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                            height: 1.1,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Hakkında bölümü
                                const SizedBox(height: 25),
                                Text(
                                  "Hakkında",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  hakkimda,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),

                                // Üreticinin ürünleri başlığı
                                const SizedBox(height: 30),
                                Text(
                                  "Üreticinin Ürünleri",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Üreticinin ürünleri yatay listesi
                                SizedBox(
                                  height: birim * 0.45,
                                  child: StreamBuilder<QuerySnapshot>(
                                    // urunler koleksiyonu: ureticiId eşleşenleri getir
                                    stream: FirebaseFirestore.instance
                                        .collection('urunler')
                                        .where('ureticiId',
                                            isEqualTo: ureticiId)
                                        .snapshots(),
                                    builder: (context, urunSnapshot) {
                                      // Ürünler gelene kadar loading
                                      if (!urunSnapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      // Üreticinin ürünü yoksa mesaj
                                      if (urunSnapshot.data!.docs.isEmpty) {
                                        return Center(
                                          child: Text(
                                            "Henüz ürün yok.",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        );
                                      }

                                      // Yatay ürün listesi
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: urunSnapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          // Her ürün dokümanını map'e çevir
                                          final urun = urunSnapshot
                                              .data!.docs[index]
                                              .data() as Map<String, dynamic>;

                                          // Kart rengi: tema listesinden sırayla
                                          final Color renk = _temaRenkleri[
                                              index % _temaRenkleri.length];

                                          return Container(
                                            width: birim * 0.28,
                                            margin: const EdgeInsets.only(
                                              right: 15,
                                            ),
                                            child: Column(
                                              children: [
                                                // Üst kare alan (ikon/görsel)
                                                AspectRatio(
                                                  aspectRatio: 1.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: renk,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    child: Icon(
                                                      Icons.eco,
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      size: birim * 0.15,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),

                                                // Ürün adı
                                                Text(
                                                  urun['urunAdi'] ?? "",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF1E201C),
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),

                                // Alt boşluk
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),

                        // Avatar (panelin üstüne taşan)
                        Positioned(
                          top: 0,
                          left: contentPadding,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 6,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: avatarDiameter / 2,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage:
                                  const AssetImage('assets/uretici.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
