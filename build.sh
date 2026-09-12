#!/bin/bash
# 只编译 Dobby -> libdobby.a (arm64-v8a)
set -e

echo "[1/5] 探测 Android NDK ..."
NDK="${ANDROID_NDK_HOME:-${NDK_HOME}}"
[ -z "$NDK" ] && [ -n "$ANDROID_NDK_HOME" ] && NDK="$ANDROID_NDK_HOME"
if [ -z "$NDK" ]; then
    NDK_DIR="$(dirname $(which ndk-build 2>/dev/null) 2>/dev/null)"
    [ -n "$NDK_DIR" ] && NDK="$NDK_DIR/.."
fi
if [ ! -d "$NDK" ]; then
    echo "ERROR: 找不到 NDK，请设置 ANDROID_NDK_HOME"; exit 1
fi
echo "NDK = $NDK"

ABI="${ABI:-arm64-v8a}"
API="${API:-21}"
TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"
[ -f "$TOOLCHAIN" ] || { echo "ERROR: 找不到 android.toolchain.cmake"; exit 1; }

echo "[2/5] 准备 Dobby 源码 ..."
if [ ! -f "Dobby/CMakeLists.txt" ]; then
    [ -d "Dobby" ] || mkdir -p Dobby
    # 若当前目录已是 Dobby 仓库（含 CMakeLists.txt），就地使用
    if [ -f "CMakeLists.txt" ] && grep -q "Dobby" CMakeLists.txt 2>/dev/null; then
        echo "当前目录即为 Dobby 源码，就地编译"
        SRC_DIR="."
    else
        echo "ERROR: 未找到 Dobby/CMakeLists.txt" 
        echo "请把 Dobby 源码放到 Dobby/ 目录，或把本脚本放进 Dobby 仓库根目录运行"
        exit 1
    fi
else
    SRC_DIR="Dobby"
fi
echo "SRC_DIR = $SRC_DIR"

# 编成静态库（不生成 libdobby.so）
export GENERATE_SHARED=OFF
export BUILD_SHARED_LIBS=OFF

echo "[3/5] CMake 配置 ..."
rm -rf build && mkdir build && cd build
cmake "$SRC_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API" \
    -DCMAKE_BUILD_TYPE=Release \
    -DGENERATE_SHARED=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DDOBBY_DEBUG=OFF \
    -DDOBBY_GENERATE_SHARED=OFF

echo "[4/5] 编译 ..."
cmake --build . -j$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)

echo "[5/5] 收集 libdobby.a ..."
cd ..
FOUND=""
for p in \
    "build/libs/${ABI}/libdobby.a" \
    "build/libdobby.a" \
    "build/lib/libdobby.a" \
    "build/src/libdobby.a" \
    "build/dobby/libdobby.a"; do
    if [ -f "$p" ]; then FOUND="$p"; break; fi
done

# 兜底：全树找 libdobby.a
if [ -z "$FOUND" ]; then
    FOUND="$(find build -name 'libdobby.a' 2>/dev/null | head -n1)"
fi

if [ -z "$FOUND" ]; then
    echo "ERROR: 未找到 libdobby.a，列出 build/ 内容供排查："
    find build -type f -name '*.a' -o -name '*.so' | head -50
    exit 1
fi

cp "$FOUND" libdobby.a
echo "=== 成功 ==="
echo "产物: $(pwd)/libdobby.a ($(stat -c%s libdobby.a 2>/dev/null || stat -f%z libdobby.a) bytes)"
