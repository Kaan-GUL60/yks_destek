import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

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

  // --- PLATFORM İKONLARI İÇİN YARDIMCI METODLAR ---
  IconData get _undoIcon =>
      Platform.isIOS ? CupertinoIcons.arrow_turn_up_left : Icons.undo;
  IconData get _redoIcon =>
      Platform.isIOS ? CupertinoIcons.arrow_turn_up_right : Icons.redo;
  IconData get _deleteIcon =>
      Platform.isIOS ? CupertinoIcons.trash : Icons.delete_forever;
  IconData get _brushIcon =>
      Platform.isIOS ? CupertinoIcons.paintbrush : Icons.brush;
  IconData get _eraserIcon => Platform.isIOS
      ? CupertinoIcons.xmark_circle
      : Icons.cleaning_services_outlined;
  // Şekiller için Material ikonları evrenseldir, değiştirmeye gerek yoktur.
  IconData get _lineIcon => Icons.horizontal_rule;
  IconData get _rectIcon => Icons.crop_square;
  IconData get _circleIcon => Icons.circle_outlined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çözüm Çizimi'),
        centerTitle: true, // iOS standardı
        actions: [
          IconButton(
            icon: Icon(_undoIcon),
            onPressed: _controller.canUndo() ? () => _controller.undo() : null,
          ),
          IconButton(
            icon: Icon(_redoIcon),
            onPressed: _controller.canRedo() ? () => _controller.redo() : null,
          ),
          IconButton(
            icon: Icon(_deleteIcon),
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
                Icon(
                  Platform.isIOS ? CupertinoIcons.scribble : Icons.line_weight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  // İYİLEŞTİRME: Platforma Duyarlı Slider
                  child: Platform.isIOS
                      ? CupertinoSlider(
                          min: 2,
                          max: 30,
                          value: _stroke,
                          activeColor: _color,
                          onChanged: (v) {
                            setState(() => _stroke = v);
                            _controller.setStyle(strokeWidth: v);
                          },
                        )
                      : Slider(
                          min: 2,
                          max: 30,
                          value: _stroke,
                          activeColor: _color,
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
                icon: Icon(_brushIcon, color: Colors.red),
                isSelected: !_isEraser && _color == Colors.red,
                onPressed: () => _setPen(Colors.red, _stroke),
              ),
              IconButton(
                tooltip: 'Mavi kalem',
                icon: Icon(_brushIcon, color: Colors.blue),
                isSelected: !_isEraser && _color == Colors.blue,
                onPressed: () => _setPen(Colors.blue, _stroke),
              ),
              IconButton(
                tooltip: 'Siyah kalem',
                icon: Icon(_brushIcon, color: Colors.black),
                isSelected: !_isEraser && _color == Colors.black,
                onPressed: () => _setPen(Colors.black, _stroke),
              ),
              IconButton(
                tooltip: 'Çizgi',
                icon: Icon(_lineIcon),
                onPressed: () {
                  _isEraser = false;
                  _controller.setPaintContent(StraightLine());
                  _controller.setStyle(color: _color, strokeWidth: _stroke);
                },
              ),
              IconButton(
                tooltip: 'Dikdörtgen',
                icon: Icon(_rectIcon),
                onPressed: () {
                  _isEraser = false;
                  _controller.setPaintContent(Rectangle());
                  _controller.setStyle(color: _color, strokeWidth: _stroke);
                },
              ),
              IconButton(
                tooltip: 'Çember',
                icon: Icon(_circleIcon),
                onPressed: () {
                  _isEraser = false;
                  _controller.setPaintContent(Circle());
                  _controller.setStyle(color: _color, strokeWidth: _stroke);
                },
              ),
              const VerticalDivider(width: 24),
              IconButton(
                tooltip: 'Silgi',
                icon: Icon(_eraserIcon),
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
