import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jpeg_encode_ffi/jpeg_encode_ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  int _time = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RepaintBoundary(
        key: _appKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Jpeg Encode'),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  FilledButton(onPressed: _screenshot, child: const Text('截图')),
                  Text('耗时: $_timeµs'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _screenshot() async {
    var pixelRatio = MediaQuery.devicePixelRatioOf(context);
    var boundary =
    _appKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var img = boundary.toImageSync(pixelRatio: pixelRatio);
    var begin = DateTime.now().microsecondsSinceEpoch;
    var dir = (await getTemporaryDirectory()).path;
    var o = path.join(dir, '${DateTime.now().millisecondsSinceEpoch}.jpeg');

    await encodeJpegImageToFile(img, o);
    setState(() {
      _time = DateTime.now().microsecondsSinceEpoch - begin;
    });
  }
}
