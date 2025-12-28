import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServisi {
  final FirebaseAuth _yetki = FirebaseAuth.instance;
  final FirebaseFirestore _veritabani = FirebaseFirestore.instance;

  // --- KAYIT OL FONKSİYONU ---
  Future<User?> kayitOl({
    required String email,
    required String sifre,
    required String adSoyad,
    required String rol, // 'Uretici' veya 'Tuketici'
  }) async {
    try {
      // 1. Kullanıcıyı Firebase Auth'da oluştur
      UserCredential kullaniciKimligi = await _yetki.createUserWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      // 2. Kullanıcı bilgilerini Firestore 'kullanicilar' koleksiyonuna yaz
      await _veritabani.collection('kullanicilar').doc(kullaniciKimligi.user!.uid).set({
        'uid': kullaniciKimligi.user!.uid,
        'email': email,
        'adSoyad': adSoyad,
        'rol': rol,
        'kayitTarihi': FieldValue.serverTimestamp(),
      });

      return kullaniciKimligi.user;
    } catch (e) {
      rethrow;
    }
  }

  // --- DOĞRULAMA MAİLİ GÖNDER ---
  Future<void> dogrulamaMailiGonder() async {
    User? kullanici = _yetki.currentUser;
    if (kullanici != null && !kullanici.emailVerified) {
      await kullanici.sendEmailVerification();
    }
  }
}