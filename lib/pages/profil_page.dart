import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Mailinizi doğrulamadıysanız, lütfen doğrulayın."),
              Gap(10),
              ElevatedButton(
                onPressed: () async {
                  if (_auth.currentUser != null &&
                      !_auth.currentUser!.emailVerified) {
                    try {
                      await _auth.currentUser!.sendEmailVerification();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lütfen daha sonra tekrar deneyin.'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kullanıcı bulunamadı veya zaten doğrulandı.',
                        ),
                      ),
                    );
                  }
                },
                child: Text("Doğrulama Maili Gönder"),
              ),
              Gap(10),
              Text("Uygulamamız geliştirilmeye devam ediyor."),
              Gap(10),
              Text(
                "Yaşadığınız sorunları bize iletisim@kgstech.net mail adresi üzerinden bildirebilirsiniz.",
                textAlign: TextAlign.center,
              ),
              Gap(10),
              Text(
                "Yapay zeka özellikleri yakında aktif edilecektir.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
