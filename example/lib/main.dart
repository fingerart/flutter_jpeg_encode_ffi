import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jpeg_encode_ffi/jpeg_encode_ffi.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appKey = GlobalKey();
  int? _time;
  String _pngSize = '0', _jpegSize = '0';

  get _debugTip => kDebugMode ? ' (Not optimal in debug mode)' : '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepaintBoundary(
        key: _appKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Jpeg Encode',
              style: TextStyle(
                shadows: [Shadow(color: Colors.white, blurRadius: 5)],
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0x00FFFFFF),
          ),
          extendBodyBehindAppBar: true,
          body: AnimatedMeshGradient(
            colors: const [
              Color(0xFFC4F0AF),
              Color(0xFFFDEED4),
              Color(0xFFEAFFEC),
              Color(0xFFDAE8FF),
            ],
            options: AnimatedMeshGradientOptions(),
            child: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                spacing: 15,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    onPressed: _screenshot,
                    child: const Text('Screenshot & Encode'),
                  ),
                  if (_time != null) ...[
                    Text('Duration: ${_time}ms$_debugTip'),
                    Text('PNG ${_pngSize}kB  🗜️  JPEG ${_jpegSize}kB'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _screenshot() async {
    await Future.delayed(Duration(milliseconds: 20));

    var pixelRatio = MediaQuery.devicePixelRatioOf(context);
    var boundary =
        _appKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var img = boundary.toImageSync(pixelRatio: pixelRatio);
    var begin = DateTime.now().millisecondsSinceEpoch;
    var dir = (await getTemporaryDirectory()).path;
    var rawOutput = path.join(dir, '$begin.png');
    var jpegOutput = path.join(dir, '$begin.jpeg');

    await encodeJpegImageToFile(img, jpegOutput);
    _time = DateTime.now().millisecondsSinceEpoch - begin;
    var pngByteData = await img.toByteData(format: ImageByteFormat.png);
    var rawFile = File(rawOutput);
    var jpegFile = File(jpegOutput);
    await rawFile.writeAsBytes(pngByteData!.buffer.asUint8List());
    _pngSize = (rawFile.statSync().size / 1000).toStringAsFixed(2);
    _jpegSize = (jpegFile.statSync().size / 1000).toStringAsFixed(2);
    setState(() {});

    _saveToGallery(rawOutput, jpegOutput);
  }

  void _saveToGallery(String png, String jpeg) async {
    PhotoManager.editor.saveImageWithPath(png);
    PhotoManager.editor.saveImageWithPath(jpeg);
  }
}
