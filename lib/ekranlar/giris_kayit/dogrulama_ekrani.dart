import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../servisler/auth_servisi.dart';
import '../uretici/uretici_ana_ekran.dart';
import '../tuketici/tuketici_ana_ekran.dart';

class DogrulamaEkrani extends StatefulWidget {
  final String email;
  const DogrulamaEkrani({super.key, required this.email});

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      _timer?.cancel();
      String? rol = await _authServisi.kullaniciRolunuGetir(user.uid);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => rol == 'Uretici' 
              ? const AnaEkran() 
              : const TuketiciAnaEkran()
          ),
          (route) => false,
        );
      }
    }
  }

  void _onayMailiTekrarGonder() async {
    setState(() => _isLoading = true);
    try {
      await _authServisi.dogrulamaMailiGonder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doğrulama bağlantısı tekrar gönderildi.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double responsiveBirim = size.shortestSide;

    return Scaffold(
      backgroundColor: Color(0xFFE7E9E8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/inekler.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: responsiveBirim * 0.06),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveBirim * 0.07, 
                              vertical: responsiveBirim * 0.08
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(128),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withAlpha(153), width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Text(
                                    "Doğrulama Gerekli",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: responsiveBirim * 0.09,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                SizedBox(height: responsiveBirim * 0.08),
                                Icon(
                                  Icons.mark_email_unread_outlined,
                                  size: responsiveBirim * 0.22,
                                  color: Colors.green.shade700,
                                ),
                                SizedBox(height: responsiveBirim * 0.06),
                                Text(
                                  "Doğrulama bağlantısı e-posta adresinize gönderildi.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsiveBirim * 0.038,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: responsiveBirim * 0.02),
                                Text(
                                  widget.email,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsiveBirim * 0.035,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                
                                // --- BURADAKİ BOŞLUK AZALTILDI (0.1 -> 0.06) ---
                                SizedBox(height: responsiveBirim * 0.06),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Doğrulama bağlantısı almadıysanız tekrar göndermeyi deneyiniz.",
                                        style: TextStyle(
                                          fontSize: responsiveBirim * 0.028,
                                          color: Colors.black45,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: responsiveBirim * 0.05),
                                    InkWell(
                                      onTap: _isLoading ? null : _onayMailiTekrarGonder,
                                      child: Container(
                                        width: responsiveBirim * 0.15, 
                                        height: responsiveBirim * 0.13,
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
                                                size: responsiveBirim * 0.065,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: responsiveBirim * 0.04),
                                Center(
                                  child: Text(
                                    "Doğrulandıktan sonra otomatik olarak yönlendirileceksiniz.",
                                    style: TextStyle(
                                      fontSize: responsiveBirim * 0.025,
                                      color: Colors.black38,
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
        ],
      ),
    );
  }
}