import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UreticiDetaySayfasi extends StatelessWidget {
  final String ureticiId;
  final String adSoyad;

  const UreticiDetaySayfasi(
      {super.key, required this.ureticiId, required this.adSoyad});

  final List<Color> _temaRenkleri = const [
    Color.fromARGB(255, 250, 245, 197),
    Color.fromARGB(255, 243, 204, 203),
    Color.fromARGB(255, 226, 194, 164),
    Color.fromARGB(255, 205, 233, 182),
    Color.fromARGB(255, 188, 209, 233),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double birim = size.shortestSide;
    final double avatarDiameter = birim * 0.30;
    final double contentPadding = 30.0;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(color: const Color.fromARGB(255, 228, 242, 247))),
          Positioned.fill(
            child: Image.asset(
              'assets/inekler.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(ureticiId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var data = snapshot.data!.data() as Map<String, dynamic>?;
              String guncelAd = data?['adSoyad'] ?? adSoyad;
              String ciftlik = data?['ciftlikBilgisi'] ?? "Çiftlik Bilgisi Yok";
              String hakkimda = data?['hakkimda'] ?? "Henüz bilgi girilmemiş.";
              String konum = data?['konum'] ?? "Konum Yok";

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: avatarDiameter / 2),
                          constraints:
                              BoxConstraints(minHeight: size.height * 0.8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(40)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                contentPadding, 24, contentPadding, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: (avatarDiameter / 2) + 5),
                                Text(
                                  guncelAd,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E201C)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ciftlik,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 12),
                                // Konum
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 16, color: Colors.deepOrange),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          konum,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                              height: 1.1),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Text("Hakkında",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800)),
                                const SizedBox(height: 5),
                                Text(hakkimda,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        height: 1.5),
                                    textAlign: TextAlign.left),
                                const SizedBox(height: 30),
                                Text("Üreticinin Ürünleri",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800)),
                                const SizedBox(height: 15),

                                // Üreticinin Ürünleri Listesi
                                SizedBox(
                                  height: birim * 0.45,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('urunler')
                                        .where('ureticiId', isEqualTo: ureticiId)
                                        .snapshots(),
                                    builder: (context, urunSnapshot) {
                                      if (!urunSnapshot.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (urunSnapshot.data!.docs.isEmpty) {
                                        return Center(
                                            child: Text("Henüz ürün yok.",
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade500)));
                                      }

                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: urunSnapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          var urun = urunSnapshot
                                              .data!.docs[index]
                                              .data() as Map<String, dynamic>;
                                          Color renk = _temaRenkleri[
                                              index % _temaRenkleri.length];
                                          
                                          return Container(
                                            width: birim * 0.28,
                                            margin:
                                                const EdgeInsets.only(right: 15),
                                            child: Column(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: renk,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25)),
                                                    child: Icon(Icons.eco,
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        size: birim * 0.15),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
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
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                        // Avatar Resmi
                        Positioned(
                          top: 0,
                          left: contentPadding,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 6),
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