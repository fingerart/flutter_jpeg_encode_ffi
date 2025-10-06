[![pub package](https://img.shields.io/pub/v/jpeg_encode_ffi.svg)](https://pub.dartlang.org/packages/jpeg_encode_ffi)
[![GitHub stars](https://img.shields.io/github/stars/fingerart/flutter_jpeg_encode_ffi)](https://github.com/fingerart/flutter_jpeg_encode_ffi/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fingerart/flutter_jpeg_encode_ffi)](https://github.com/fingerart/flutter_jpeg_encode_ffi/network)
[![GitHub license](https://img.shields.io/github/license/fingerart/flutter_jpeg_encode_ffi)](https://github.com/fingerart/flutter_jpeg_encode_ffi/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/fingerart/flutter_jpeg_encode_ffi)](https://github.com/fingerart/flutter_jpeg_encode_ffi/issues)

Encode images into Jpeg format through native FFI binding.

![example](https://raw.githubusercontent.com/fingerart/flutter_jpeg_encode_ffi/main/doc/example.jpg)

> [!TIP]
> If this package is useful to you, please remember to give it a star✨ ([Pub](https://pub.dev/packages/jpeg_encode_ffi) | [GitHub](https://github.com/fingerart/flutter_jpeg_encode_ffi)).

## Getting Started

```yaml
dependencies:
  jpeg_encode_ffi: ^0.0.1+2
```

```dart
import 'package:jpeg_encode_ffi/jpeg_encode_ffi.dart';

// Encode the image to a file in JPEG format.
encodeJpegImageToFile(ui.Image image, String path, {int quality = 95});

// Encode image pixels to file in JPEG format.
encodeJpegToFile(
  Uint8List pixels,
  int width,
  int height,
  int comp,
  String path, 
  {int quality = 95}
)
```

## Other Dart and Flutter libraries

- [flutter_hypertext](https://pub.dev/packages/flutter_hypertext): A highly extensible rich text widget that can automatically parse styles.
- [flutter_ticker](https://pub.dev/packages/flutter_ticker): A flutter text widget with scrolling text change animation.
- [varint](https://pub.dev/packages/varint): A Dart library for encoding and decoding variable-length quantity (VLQ).
