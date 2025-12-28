import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../servisler/auth_servisi.dart';
import '../uretici/uretici_ana_ekran.dart';
import '../tuketici/tuketici_ana_ekran.dart';
import 'giris_ekrani.dart';

class DogrulamaEkrani extends StatefulWidget {
  final String email;
  const DogrulamaEkrani({super.key, required this.email});

  @override
  State<DogrulamaEkrani> createState() => _DogrulamaEkraniState();
}

class _DogrulamaEkraniState extends State<DogrulamaEkrani> {
  Timer? _timer;
  bool _isChecking = false;
  final AuthServisi _authServisi = AuthServisi();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _checkEmailVerified(otomatik: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified({bool otomatik = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      _timer?.cancel();
      String? rol = await _authServisi.kullaniciRolunuGetir(user.uid);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => rol == 'Uretici' ? const UreticiAnaEkran() : const TuketiciAnaEkran()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double responsiveBirim = size.shortestSide;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E9E8),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/giris_bg.png', fit: BoxFit.cover)),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.07, vertical: responsiveBirim * 0.08),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(128),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withAlpha(153), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mark_email_unread_outlined, size: responsiveBirim * 0.2, color: Colors.green),
                        SizedBox(height: responsiveBirim * 0.05),
                        Text("E-postanızı Onaylayın", style: TextStyle(fontFamily: 'Inter', fontSize: responsiveBirim * 0.07, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: responsiveBirim * 0.03),
                        Text(
                          "Bağlantı ${widget.email} adresine gönderildi.\nLütfen mailinizi onaylayıp butona basınız.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: responsiveBirim * 0.035, color: Colors.black87, height: 1.5),
                        ),
                        SizedBox(height: responsiveBirim * 0.08),
                        InkWell(
                          onTap: () async {
                            setState(() => _isChecking = true);
                            await _checkEmailVerified();
                            if (mounted) setState(() => _isChecking = false);
                          },
                          child: Container(
                            width: double.infinity,
                            height: responsiveBirim * 0.14,
                            decoration: BoxDecoration(color: const Color(0xFF1E201C), borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: _isChecking 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("Bağlantıya Tıkladım", style: TextStyle(color: Colors.white, fontSize: responsiveBirim * 0.04, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveBirim * 0.04),
                        TextButton(
                          onPressed: () => _authServisi.dogrulamaMailiGonder(),
                          child: Text("Tekrar Gönder", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: responsiveBirim * 0.035)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}