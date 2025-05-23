import 'dart:ffi';
import 'dart:io';

typedef NativeGenImageDirectionalFn = Void Function(
    Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef DartGenImageDirectionalFn = void Function(
    Pointer<Uint8>, int, int, int, int);

final String dllPath = Platform.isWindows
    ? File('../build/Release/striped_generator.dll').absolute.path
    : throw UnsupportedError('Only Windows is supported.');

final DynamicLibrary _lib = () {
  print('Attempting to load DLL from: $dllPath');
  return DynamicLibrary.open(dllPath);
}();

final DartGenImageDirectionalFn generateStripedImageDirectional = _lib
  .lookup<NativeFunction<NativeGenImageDirectionalFn>>('generate_striped_image_directional')
  .asFunction();
