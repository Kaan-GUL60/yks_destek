import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
              Text("Çok yakında..."),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                "Uygulamamız şuanda kısıtlı fonksiyonlarla kapalı alpha sürümündedir. ",
              ),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                "Sorun yaşıyorsanız uygulamanın en güncel sürümünü kullanıp kullanmadığınızdan emin olunuz.",
              ),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                "Uygulama en çok 2 günde bir girerek aktifliğinizi korursanız memnun oluruz.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
