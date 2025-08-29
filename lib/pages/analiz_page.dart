import 'package:flutter/material.dart';

class AnalizPage extends StatefulWidget {
  const AnalizPage({super.key});

  @override
  State<AnalizPage> createState() => _AnalizPageState();
}

class _AnalizPageState extends State<AnalizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analiz')),
      body: const Center(child: Text('Merhaba, Analiz Sayfasına Hoşgeldiniz!')),
    );
  }
}
