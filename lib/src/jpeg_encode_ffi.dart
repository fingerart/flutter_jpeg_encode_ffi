import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:jpeg_encode_ffi/src/jpeg_encode_ffi_bindings_generated.dart';

/// Encodes the image [image] to a file at [path] in JPEG format.
///
/// [pixels] Image byte array
/// [comp] Number of image channels
/// [path] Save path
Future<void> encodeJpegImageToFile(
  ui.Image image,
  String output, {
  int quality = 95,
}) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (bytes == null) {
    throw Exception('Could not converts image to byte array.');
  }
  final pixels = bytes.buffer.asUint8List();
  await encodeJpegToFile(
    pixels,
    image.width,
    image.height,
    4,
    output,
    quality: quality,
  );
}

/// Encodes the image [pixels] to a file at [path] in JPEG format
///
/// [pixels] Image byte array
/// [width] Image width
/// [height] Image height
/// [comp] Number of image channels (only 1, 3, 4 are supported)
/// [path] Save path
Future<void> encodeJpegToFile(
  Uint8List pixels,
  int width,
  int height,
  int comp,
  String path, {
  int quality = 95,
}) async {
  assert(pixels.isNotEmpty, 'pixels is empty');
  assert(width > 0 || height > 0, 'invalid width or height');
  assert(
    comp == 1 || comp == 3 || comp == 4,
    'component input 2 is not supported',
  );

  final helperIsolateSendPort = await _helperIsolateSendPort;
  final id = _nextRequestId++;
  final request = _EncodeRequest(
    id,
    pixels,
    width,
    height,
    quality,
    comp,
    path,
  );

  final completer = Completer<int>();
  _requests[id] = completer;
  helperIsolateSendPort.send(request);

  final result = await completer.future;
  if (result == 0) throw Exception('Native encode jpeg fail');
}

const String _libName = 'jpeg_encode_ffi';

/// The dynamic library in which the symbols for [JpegEncodeFfiBindings] can be found.
final ffi.DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return ffi.DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final _bindings = JpegEncodeFfiBindings(_dylib);

mixin _Freeable {
  void free();
}

/// Encodes the request.
class _EncodeRequest with _Freeable {
  _EncodeRequest(
    this.id,
    this.pixels,
    this.width,
    this.height,
    this.quality,
    this.component,
    this.outputPath, {
    // ignore: unused_element_parameter
    this.allocator = calloc,
  });

  final int id;
  final Uint8List pixels;
  final int width;
  final int height;
  final int quality;
  final int component;
  final String outputPath;
  final ffi.Allocator allocator;

  ffi.Pointer<ffi.Uint8>? _pixelsPtr;

  ffi.Pointer<ffi.Uint8> get pixelsPtr {
    if (_pixelsPtr == null) {
      var ptr = allocator<ffi.Uint8>(pixels.length);
      ptr.asTypedList(pixels.length).setAll(0, pixels);
      _pixelsPtr = ptr;
    }
    return _pixelsPtr!;
  }

  ffi.Pointer<ffi.Char>? _pathPtr;

  ffi.Pointer<ffi.Char> get pathPtr {
    _pathPtr ??= outputPath.toNativeUtf8(allocator: allocator).cast();
    return _pathPtr!;
  }

  @override
  void free() {
    if (_pixelsPtr != null) {
      allocator.free(_pixelsPtr!);
      _pixelsPtr = null;
    }
    if (_pathPtr != null) {
      allocator.free(_pathPtr!);
      _pathPtr = null;
    }
  }
}

/// Encodes the response
class _EncodeResponse {
  final int id;
  final int result;

  const _EncodeResponse(this.id, this.result);
}

/// Counter to identify [_EncodeRequest]s and [_EncodeResponse]s.
int _nextRequestId = 0;

/// Mapping from [_EncodeRequest] `id`s to the completers corresponding to the correct future of the pending request.
final _requests = <int, Completer<int>>{};

/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is _EncodeResponse) {
        // The helper isolate sent us a response to a request we sent.
        final completer = _requests[data.id]!;
        _requests.remove(data.id);
        completer.complete(data.result);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final helperReceivePort = ReceivePort()
      ..listen((dynamic data) {
        // On the helper isolate listen to requests and respond to them.
        if (data is _EncodeRequest) {
          try {
            final result = _bindings.jo_write_jpg(
              data.pathPtr,
              data.pixelsPtr.cast(),
              data.width,
              data.height,
              data.component,
              data.quality,
            );
            final response = _EncodeResponse(data.id, result);
            sendPort.send(response);
            return;
          } finally {
            data.free();
          }
        }
        throw UnsupportedError(
          'Unsupported message type: ${data.runtimeType}',
        );
      });

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();
