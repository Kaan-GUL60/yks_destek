import 'package:flutter/material.dart';

class FavorilerPage extends StatefulWidget {
  const FavorilerPage({super.key});

  @override
  State<FavorilerPage> createState() => _FavorilerPageState();
}

class _FavorilerPageState extends State<FavorilerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoriler')),
      body: const Center(
        child: Text('Merhaba, Favoriler Sayfasına Hoşgeldiniz!'),
      ),
    );
  }
}
