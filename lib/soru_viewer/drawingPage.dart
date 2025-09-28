// drawing_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPage extends StatefulWidget {
  final String imagePath;
  const DrawingPage({super.key, required this.imagePath});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  final DrawingController _controller = DrawingController();
  Color _color = Colors.red;
  double _stroke = 4.0;
  bool _isEraser = false;

  @override
  void initState() {
    super.initState();
    _controller.setPaintContent(SmoothLine());
    _controller.setStyle(color: _color, strokeWidth: _stroke);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPen(Color color, double width) {
    _isEraser = false;
    _controller.setPaintContent(SmoothLine());
    _controller.setStyle(color: color, strokeWidth: width);
    setState(() {
      _color = color;
      _stroke = width;
    });
  }

  void _setEraser(double width) {
    _isEraser = true;
    _controller.setPaintContent(Eraser());
    _controller.setStyle(strokeWidth: width);
    setState(() => _stroke = width);
  }

  Future<void> _shareImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/solution_drawing.png').create();
      await file.writeAsBytes(pngBytes);
      // Dosyayı paylaşma işlemi buraya gelecek.
    } catch (e) {
      debugPrint('Paylaşma sırasında hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çözüm Çizimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _controller.canUndo() ? () => _controller.undo() : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _controller.canRedo() ? () => _controller.redo() : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _controller.clear(),
          ),
          //IconButton(icon: const Icon(Icons.share), onPressed: _shareImage),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                const Icon(Icons.line_weight),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    min: 2,
                    max: 30,
                    value: _stroke,
                    onChanged: (v) {
                      setState(() => _stroke = v);
                      _controller.setStyle(strokeWidth: v);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RepaintBoundary(
            key: _globalKey,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned.fill(
                  child: DrawingBoard(
                    controller: _controller,
                    showDefaultTools: false,
                    showDefaultActions: false,

                    // 🚨 ÇÖZÜM: Yakınlaştırmayı devre dışı bırakır.
                    transformationController:
                        TransformationController(), // zorunlu
                    background: Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                tooltip: 'Kırmızı kalem',
                icon: Icon(Icons.brush, color: Colors.red),
                isSelected: !_isEraser && _color == Colors.red,
                onPressed: () => _setPen(Colors.red, _stroke),
              ),
              IconButton(
                tooltip: 'Mavi kalem',
                icon: Icon(Icons.brush, color: Colors.blue),
                isSelected: !_isEraser && _color == Colors.blue,
                onPressed: () => _setPen(Colors.blue, _stroke),
              ),
              IconButton(
                tooltip: 'Siyah kalem',
                icon: Icon(Icons.brush, color: Colors.black),
                isSelected: !_isEraser && _color == Colors.black,
                onPressed: () => _setPen(Colors.black, _stroke),
              ),
              IconButton(
                tooltip: 'Çizgi',
                icon: const Icon(Icons.horizontal_rule),
                onPressed: () {
                  _isEraser = false;
                  _controller.setPaintContent(StraightLine());
                  _controller.setStyle(color: _color, strokeWidth: _stroke);
                },
              ),
              IconButton(
                tooltip: 'Dikdörtgen',
                icon: const Icon(Icons.crop_square),
                onPressed: () {
                  _isEraser = false;
                  _controller.setPaintContent(Rectangle());
                  _controller.setStyle(color: _color, strokeWidth: _stroke);
                },
              ),
              IconButton(
                tooltip: 'Çember',
                icon: const Icon(Icons.circle_outlined),
                onPressed: () {
                  _isEraser = false;
                  _controller.setPaintContent(Circle());
                  _controller.setStyle(color: _color, strokeWidth: _stroke);
                },
              ),
              const VerticalDivider(width: 24),
              IconButton(
                tooltip: 'Silgi',
                icon: const Icon(Icons.cleaning_services_outlined),
                isSelected: _isEraser,
                onPressed: () => _setEraser(_stroke),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
