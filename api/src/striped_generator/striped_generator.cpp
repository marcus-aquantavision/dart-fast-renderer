#include "striped_generator.h"
#include <cstdint>
#include <cstring>
#include <iostream>

void generate_striped_image_directional(uint8_t* buffer, int width, int height, int frameIndex, int direction) {
    const int stride = width * 4;

    // std::cout << "[CPP] generate_striped_image called - frameIndex: " << frameIndex << ", size: " << width << "x" << height << std::endl;

    std::memset(buffer, 128, stride * height);

    int baseOffset = direction == 0 ? frameIndex * 2 : width - ((frameIndex * 2) % width);
    int redX = baseOffset % width;
    int greenX = (baseOffset + width / 3) % width;
    int blueX = (baseOffset + 2 * width / 3) % width;

    for (int y = 0; y < height; ++y) {
        int offset;

        offset = y * stride + redX * 4;
        buffer[offset + 0] = 0;
        buffer[offset + 1] = 0;
        buffer[offset + 2] = 255;
        buffer[offset + 3] = 255;

        offset = y * stride + greenX * 4;
        buffer[offset + 0] = 0;
        buffer[offset + 1] = 255;
        buffer[offset + 2] = 0;
        buffer[offset + 3] = 255;

        offset = y * stride + blueX * 4;
        buffer[offset + 0] = 255;
        buffer[offset + 1] = 0;
        buffer[offset + 2] = 0;
        buffer[offset + 3] = 255;
    }
}
