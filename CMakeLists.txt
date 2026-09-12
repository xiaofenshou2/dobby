# 独立编译 Dobby 为静态库 libdobby.a (arm64-v8a, android-21)
# 用法：把本文件和 build.sh 放到 Dobby 仓库根目录，或直接用 build.yml（自动克隆）

cmake_minimum_required(VERSION 3.18)
project(dobby C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# 强制静态库，不生成 .so
set(GENERATE_SHARED OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(DOBBY_GENERATE_SHARED OFF CACHE BOOL "" FORCE)

# 若作为子目录被外层 CMakeLists 引用，这里直接 add_subdirectory(Dobby) 即可
if(NOT DEFINED DOBBY_ROOT)
    set(DOBBY_ROOT ${CMAKE_SOURCE_DIR})
endif()

add_subdirectory(${DOBBY_ROOT} ${CMAKE_BINARY_DIR}/dobby_build)

# 产物名固定为 libdobby.a（Dobby 内部 target 名就是 dobby）
# 构建后可在 build/libs/arm64-v8a/libdobby.a 找到
