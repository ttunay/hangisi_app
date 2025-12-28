import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UrunlerEkrani extends StatefulWidget {
  const UrunlerEkrani({super.key});

  @override
  State<UrunlerEkrani> createState() => _UrunlerEkraniState();
}

class _UrunlerEkraniState extends State<UrunlerEkrani> {
  final TextEditingController _aramaController = TextEditingController();
  String _aramaKelimesi = "";

  final List<Color> _temaRenkleri = [
    const Color(0xFF2D5A27), const Color(0xFFB92A2F), 
    const Color(0xFF8B5A2B), const Color(0xFF4F772D), 
    const Color(0xFFD35400), const Color(0xFF6A994E),
  ];

  void _urunDetayPaneli(String id, Map<String, dynamic> urun, Color kartRengi) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(birim * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: birim * 0.06),
              Container(
                width: double.infinity,
                height: birim * 0.4,
                decoration: BoxDecoration(color: kartRengi, borderRadius: BorderRadius.circular(25)),
                child: const Icon(Icons.eco, size: 80, color: Colors.black12), 
              ),
              SizedBox(height: birim * 0.06),
              Text(urun['urunAdi'] ?? "", style: TextStyle(fontSize: birim * 0.08, fontWeight: FontWeight.bold)),
              Text("Barkod: ${urun['barkod'] ?? '-'}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              SizedBox(height: birim * 0.04),
              _detaySatiri(Icons.description_outlined, "Açıklama", urun['aciklama'] ?? "-", birim),
              _detaySatiri(Icons.grass_outlined, "Tohum", urun['tohum'] ?? "-", birim),
              _detaySatiri(Icons.opacity_outlined, "Gübre", urun['gubre'] ?? "-", birim),
              _detaySatiri(Icons.sanitizer_outlined, "İlaçlama", urun['ilac'] ?? "-", birim),
              SizedBox(height: birim * 0.08),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _urunDuzenle(id, urun); }, icon: const Icon(Icons.edit_outlined), label: const Text("Düzenle"))),
                  SizedBox(width: birim * 0.04),
                  Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); _urunSil(id); }, icon: const Icon(Icons.delete_outline), label: const Text("Sil"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB92A2F), foregroundColor: Colors.white))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detaySatiri(IconData icon, String baslik, String icerik, double birim) {
    return Padding(
      padding: EdgeInsets.only(bottom: birim * 0.04),
      child: Row(
        children: [
          Icon(icon, size: birim * 0.06, color: const Color(0xFF2D5A27)), 
          SizedBox(width: birim * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: TextStyle(color: Colors.grey, fontSize: birim * 0.035)),
                Text(
                  icerik, 
                  style: TextStyle(fontSize: birim * 0.045, fontWeight: FontWeight.w500, color: Colors.black87)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _urunDuzenle(String urunId, Map<String, dynamic> urun) {
    final TextEditingController adEdit = TextEditingController(text: urun['urunAdi']);
    final TextEditingController aciklamaEdit = TextEditingController(text: urun['aciklama']);
    final TextEditingController barkodEdit = TextEditingController(text: urun['barkod']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 30, right: 30, top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ürünü Düzenle", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: adEdit, decoration: InputDecoration(labelText: "Ürün Adı", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            TextField(controller: barkodEdit, decoration: InputDecoration(labelText: "Barkod (Benzersiz)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            TextField(controller: aciklamaEdit, decoration: InputDecoration(labelText: "Açıklama", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))), maxLines: 3),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E201C), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('urunler').doc(urunId).update({'urunAdi': adEdit.text, 'aciklama': aciklamaEdit.text, 'barkod': barkodEdit.text});
                Navigator.pop(context);
              },
              child: const Text("Değişiklikleri Kaydet", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _urunSil(String urunId) async {
    bool? onay = await showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Ürünü Sil"), content: const Text("Emin misiniz?"), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Vazgeç")), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sil"))]));
    if (onay == true) await FirebaseFirestore.instance.collection('urunler').doc(urunId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final double birim = MediaQuery.of(context).size.shortestSide;
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
        builder: (context, userSnapshot) {
          String adSoyad = userSnapshot.hasData ? userSnapshot.data!['adSoyad'] ?? "Üretici" : "Üretici";
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.fromLTRB(birim * 0.06, birim * 0.06, birim * 0.06, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Merhaba", style: TextStyle(fontSize: birim * 0.045, color: Colors.grey.shade600)), Text(adSoyad, style: TextStyle(fontSize: birim * 0.07, fontWeight: FontWeight.bold))])),
                Padding(padding: EdgeInsets.symmetric(horizontal: birim * 0.06, vertical: birim * 0.04), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: TextField(onChanged: (val) => setState(() => _aramaKelimesi = val.toLowerCase()), decoration: const InputDecoration(hintText: "Ürünlerinizi arayın...", prefixIcon: Icon(Icons.search), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15))))),
                Padding(padding: EdgeInsets.symmetric(horizontal: birim * 0.06, vertical: birim * 0.02), child: Text("Ürünlerim", style: TextStyle(fontSize: birim * 0.055, fontWeight: FontWeight.bold))),
                Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('urunler').where('ureticiId', isEqualTo: user?.uid).snapshots(), builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var urunlerDocs = snapshot.data!.docs.where((doc) => doc['urunAdi'].toString().toLowerCase().contains(_aramaKelimesi)).toList();
                  return ListView.builder(padding: EdgeInsets.symmetric(horizontal: birim * 0.06), itemCount: urunlerDocs.length, itemBuilder: (context, index) {
                    var urun = urunlerDocs[index].data() as Map<String, dynamic>;
                    return _buildUrunKarti(urunlerDocs[index].id, urun, index, birim);
                  });
                })),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUrunKarti(String id, Map<String, dynamic> urun, int index, double birim) {
    Color kartRengi = _temaRenkleri[index % _temaRenkleri.length];
    return GestureDetector(
      onTap: () => _urunDetayPaneli(id, urun, kartRengi),
      child: Container(
        margin: EdgeInsets.only(bottom: birim * 0.05),
        height: birim * 0.45,
        padding: EdgeInsets.all(birim * 0.05),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(30), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))]
        ),
        child: Row(
          children: [
            // GÖRSEL SOLDA (flex: 2)
            Expanded(
              flex: 2, 
              child: Container(
                height: double.infinity, 
                decoration: BoxDecoration(color: kartRengi, borderRadius: BorderRadius.circular(22)), 
                child: Icon(Icons.eco, color: Colors.black.withOpacity(0.1), size: birim * 0.18)
              )
            ),
            SizedBox(width: birim * 0.04),
            // BİLGİLER SAĞDA (flex: 3)
            Expanded(
              flex: 3, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(urun['urunAdi'] ?? "", style: TextStyle(fontSize: birim * 0.055, fontWeight: FontWeight.w900, color: const Color(0xFF1E201C))), 
                  SizedBox(height: birim * 0.01), 
                  Text(urun['aciklama'] ?? "", style: TextStyle(color: Colors.grey.shade700, fontSize: birim * 0.032, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis), 
                  SizedBox(height: birim * 0.03), 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                    decoration: BoxDecoration(color: kartRengi.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), 
                    child: Text("Barkod: ${urun['barkod'] ?? '-'}", style: TextStyle(fontSize: birim * 0.028, fontWeight: FontWeight.bold, color: kartRengi))
                  )
                ]
              )
            ),
          ],
        ),
      ),
    );
  }
}