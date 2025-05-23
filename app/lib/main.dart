import 'dart:ffi';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:texture_rgba_renderer/texture_rgba_renderer.dart';
import 'package:ffi/ffi.dart';
import 'native_bindings.dart';

typedef NativeOnRgbaNative = Void Function(
    Pointer<Void>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef NativeOnRgbaDart = void Function(
    Pointer<Void>, Pointer<Uint8>, int, int, int, int);

void main() => runApp(const MaterialApp(home: TextureRgbaDemo()));

class TextureRgbaDemo extends StatefulWidget {
  const TextureRgbaDemo({super.key});

  @override
  State<TextureRgbaDemo> createState() => _TextureRgbaDemoState();
}

class _TextureRgbaDemoState extends State<TextureRgbaDemo> {
  static const int width = 1028;
  static const int height = 768;
  static const int bytesPerPixel = 4;

  final _plugin = TextureRgbaRenderer();
  int textureId1 = -1;
  int textureId2 = -1;
  int texturePtr1 = 0;
  int texturePtr2 = 0;
  int frameIndex = 0;

  late Pointer<Uint8> nativeBuffer1;
  late Pointer<Uint8> nativeBuffer2;
  late NativeOnRgbaDart nativeOnRgba;

  late Future<void> _loopFuture;

  final List<DateTime> _frameTimes = [];
  double _avgFps = 0.0;
  DateTime _lastFpsUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final lib = DynamicLibrary.process();
    nativeOnRgba = lib
        .lookup<NativeFunction<NativeOnRgbaNative>>(
            'FlutterRgbaRendererPluginOnRgba')
        .asFunction<NativeOnRgbaDart>();

    _initTextures();
  }

  Future<void> _initTextures() async {
    final bufferLength = width * height * bytesPerPixel;

    nativeBuffer1 = calloc<Uint8>(bufferLength);
    nativeBuffer2 = calloc<Uint8>(bufferLength);

    final id1 = await _plugin.createTexture(1);
    final ptr1 = await _plugin.getTexturePtr(1);
    final id2 = await _plugin.createTexture(2);
    final ptr2 = await _plugin.getTexturePtr(2);

    if (id1 == -1 || id2 == -1 || ptr1 == 0 || ptr2 == 0) {
      throw Exception("Failed to initialize textures");
    }

    setState(() {
      textureId1 = id1;
      texturePtr1 = ptr1;
      textureId2 = id2;
      texturePtr2 = ptr2;
    });

    _loopFuture = _startLoop();
  }

  Future<void> _startLoop() async {
    final length = width * height * bytesPerPixel;

    while (mounted) {
      final frameStart = DateTime.now();

      generateStripedImageDirectional(
          nativeBuffer1, width, height, frameIndex, 0);
      generateStripedImageDirectional(
          nativeBuffer2, width, height, frameIndex, 1);

      nativeOnRgba(Pointer<Void>.fromAddress(texturePtr1), nativeBuffer1,
          length, width, height, width * bytesPerPixel);
      nativeOnRgba(Pointer<Void>.fromAddress(texturePtr2), nativeBuffer2,
          length, width, height, width * bytesPerPixel);

      // Track frame time for FPS calculation
      _frameTimes.add(frameStart);
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }

      // Update FPS once per second
      if (DateTime.now().difference(_lastFpsUpdate).inMilliseconds > 1000) {
        if (_frameTimes.length >= 2) {
          final diff =
              _frameTimes.last.difference(_frameTimes.first).inMilliseconds;
          _avgFps = (_frameTimes.length - 1) * 1000 / diff;
          setState(() {}); // Update UI
        }
        _lastFpsUpdate = DateTime.now();
      }

      final elapsed = DateTime.now().difference(frameStart);
      final remaining =
          const Duration(milliseconds: 1) - elapsed; // Cap FPS

      // debugPrint('[DART] Frame $frameIndex | Render Time: ${elapsed.inMilliseconds} ms');
      frameIndex++;

      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
    }
  }

  @override
  void dispose() {
    debugPrint('[DART] Disposing resources');
    _plugin.closeTexture(1);
    _plugin.closeTexture(2);
    calloc.free(nativeBuffer1);
    calloc.free(nativeBuffer2);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = textureId1 != -1 && textureId2 != -1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isReady
            ? Stack(
                alignment: Alignment.topCenter,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 320,
                        height: 240,
                        child: Texture(textureId: textureId1),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 320,
                        height: 240,
                        child: Texture(textureId: textureId2),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      color: Colors.black87,
                      child: Text(
                        'FPS: ${_avgFps.toStringAsFixed(1)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
