# jpeg_encode_ffi

Encode images into Jpeg format through native FFI binding.

![example](./doc/example.jpg)

## Getting Started

```yaml
dependencies:
  flutter_ticker: ^0.0.1+3
```

```dart
encodeJpegImageToFile(ui.Image image, String path, {int quality = 95});
encodeJpegToFile(Uint8List pixels,int width,int height,int comp,String path, {int quality = 95})
```