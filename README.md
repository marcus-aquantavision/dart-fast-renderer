# Dart Fast Renderer - Windows Setup

This project demonstrates a high-performance texture renderer using Flutter and a native C++ backend. The application uses FFI to bridge between Dart and C++ for fast frame updates, and renders frames into two texture windows independently.

**Note:** This is a demo showcasing the render performance of the [texture\_rgba\_renderer](https://pub.dev/packages/texture_rgba_renderer/example) package.

## Prerequisites

* Windows 10 or later
* [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
* Visual Studio with C++ build tools
* PowerShell

## Setup Instructions

1. **Clone the repository**

   ```
   git clone https://github.com/your-username/dart-fast-renderer.git
   cd dart-fast-renderer
   ```

2. **Build the native C++ DLL**
   Run the provided build script to compile the `striped_generator.dll`:

   ```
   ./build.ps1
   ```

   This generates the `striped_generator.dll` in the `build/Release` directory.

3. **Initialize the Flutter application**
   Navigate to the `app` directory and initialize Flutter:

   ```
   cd app
   flutter create .
   ```

4. **Run the application in release mode**
   To maximize performance, run in release mode on Windows:

   ```
   flutter run --release -d windows
   ```

## Notes

* The application opens two texture windows displaying independent RGB animations.
* FPS is capped via a timed render loop and displayed in the top center overlay.
* Make sure the generated DLL path in `native_bindings.dart` matches the actual build output location.

## Troubleshooting

* If the DLL fails to load, confirm that:

  * The DLL is built in `Release` mode.
  * The path is correct relative to the app executable.

* If no textures appear:

  * Ensure the `generate_striped_image_directional` symbol exists in the DLL.
  * Check for correct RGBA channel ordering in the C++ code.
  * Wrap each `Texture` in a fixed-size `SizedBox`.

For additional help, consult the Flutter and Dart FFI documentation.
