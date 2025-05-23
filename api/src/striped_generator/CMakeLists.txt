# windows/striped_generator/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(striped_generator)

add_library(striped_generator SHARED
  striped_generator.cpp
)
set_target_properties(striped_generator PROPERTIES
    PREFIX ""
    OUTPUT_NAME "striped_generator"
    WINDOWS_EXPORT_ALL_SYMBOLS ON
)



target_include_directories(striped_generator PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
