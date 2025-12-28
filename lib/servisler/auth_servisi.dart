import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- KAYIT OL (AD VE SOYAD AYRI) ---
  Future<User?> kayitOl({
    required String email,
    required String sifre,
    required String ad,
    required String soyad,
    required String rol,
  }) async {
    try {
      // DİKKAT: Burada 'password' kullanılmalı
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: sifre, 
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('kullanicilar').doc(user.uid).set({
          'ad': ad,
          'soyad': soyad,
          'adSoyad': '$ad $soyad',
          'email': email,
          'rol': rol,
          'uid': user.uid,
          'kayitTarihi': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // --- GİRİŞ YAP ---
  Future<User?> girisYap(String email, String sifre) async {
    try {
      // HATA BURADAYDI: Parametre adı 'password' olmalı
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: sifre, // 'sifre:' değil 'password:' olmalı
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // --- KULLANICI ROLÜNÜ GETİR ---
  Future<String?> kullaniciRolunuGetir(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('kullanicilar').doc(uid).get();
      if (doc.exists) {
        return doc.get('rol');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- DOĞRULAMA MAİLİ GÖNDER ---
  Future<void> dogrulamaMailiGonder() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // --- KULLANICIYI YENİLE ---
  Future<void> kullaniciyiYenile() async {
    await _auth.currentUser?.reload();
  }

  // --- ÇIKIŞ YAP ---
  Future<void> cikisYap() async {
    await _auth.signOut();
  }
}
