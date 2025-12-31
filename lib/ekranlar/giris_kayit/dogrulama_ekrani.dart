import 'dart:async'; // Timer için
import 'dart:ui'; // Blur için (BackdropFilter + ImageFilter)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../servis/auth_servisi.dart';
import '../uretici/uretici_ana_ekran.dart';
import '../tuketici/tuketici_ana_ekran.dart';

class DogrulamaEkrani extends StatefulWidget {
  final String email;

  const DogrulamaEkrani({
    super.key,
    required this.email,
  });

  @override
  State<DogrulamaEkrani> createState() => _DogrulamaEkraniState();
}

class _DogrulamaEkraniState extends State<DogrulamaEkrani> {
  Timer? _timer;
  bool _isLoading = false;
  final AuthServisi _authServisi = AuthServisi();

  @override
  void initState() {
    super.initState();

    // 3 saniyede bir doğrulama kontrolü
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    // Ekran kapanırken timer durdurulur
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();

    if (user != null && user.emailVerified) {
      _timer?.cancel();

      final String? rol = await _authServisi.kullaniciRolunuGetir(user.uid);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              rol == 'Uretici' ? const AnaEkran() : const TuketiciAnaEkran(),
        ),
        (route) => false,
      );
    }
  }

  void _onayMailiTekrarGonder() async {
    setState(() => _isLoading = true);

    try {
      await _authServisi.dogrulamaMailiGonder();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doğrulama bağlantısı tekrar gönderildi.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ölçeklendirme birimi: ekranın kısa kenarı
    final double birim = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 242, 247),
      body: Stack(
        children: [
          // 1) Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/inekler.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // 2) ÖNEMLİ DÜZELTME:
          // Login/Kayıt ekranındaki gibi LayoutBuilder + ConstrainedBox kullanıyoruz.
          // Böylece SingleChildScrollView tüm ekranı kaplar
          // ve fare tekeri ekranın her yerinde çalışır.
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: birim * 0.06),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: [
                              // Blur katmanı
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),

                              // İçerik kartı
                              Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                    birim * 0.07, // sol
                                    birim * 0.08, // üst
                                    birim * 0.07, // sağ
                                    birim * 0.04, // alt
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(128),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(153),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Doğrulama Gerekli",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: birim * 0.09,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      SizedBox(height: birim * 0.08),

                                      Icon(
                                        Icons.mark_email_unread_outlined,
                                        size: birim * 0.22,
                                        color: const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      SizedBox(height: birim * 0.06),

                                      Text(
                                        "Doğrulama bağlantısı e-posta adresinize gönderildi.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: birim * 0.038,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: birim * 0.02),

                                      Text(
                                        widget.email,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: birim * 0.035,
                                          color: Colors.black54,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      SizedBox(height: birim * 0.06),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Doğrulama bağlantısı almadıysanız tekrar göndermeyi deneyiniz.",
                                              style: TextStyle(
                                                fontSize: birim * 0.028,
                                                color: Colors.black45,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: birim * 0.05),

                                          InkWell(
                                            onTap: _isLoading ? null : _onayMailiTekrarGonder,
                                            child: Container(
                                              width: birim * 0.15,
                                              height: birim * 0.13,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E201C),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              child: _isLoading
                                                  ? const Center(
                                                      child: SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.refresh,
                                                      color: Colors.white,
                                                      size: birim * 0.065,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: birim * 0.04),

                                      Text(
                                        "Doğrulandıktan sonra otomatik olarak yönlendirileceksiniz.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: birim * 0.025,
                                          color: Colors.black38,
                                        ),
                                      ),

                                      SizedBox(height: birim * 0.03),

                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Vazgeç",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: birim * 0.035,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
