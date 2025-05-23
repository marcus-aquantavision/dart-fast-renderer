#pragma once

#include <cstdint>

#ifdef _WIN32
  #define EXPORT __declspec(dllexport)
#else
  #define EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

EXPORT void generate_striped_image_directional(uint8_t* buffer, int width, int height, int frameIndex, int direction);

#ifdef __cplusplus
}
#endif
