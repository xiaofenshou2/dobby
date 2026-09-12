#!/bin/bash
set -e

echo "[1/6] 强制清理旧构建..."
rm -rf build output third_party
mkdir -p third_party

echo "[2/6] 使用环境 NDK 27 ..."
NDK_HOME="/usr/local/lib/android/sdk/ndk/27.3.1"
if [ ! -d "$NDK_HOME" ]; then
  NDK_HOME=$(ls -d /usr/local/lib/android/sdk/ndk/27* 2>/dev/null | head -1)
fi
echo "最终使用 NDK = $NDK_HOME"
export ANDROID_NDK_HOME=$NDK_HOME

echo "[3/6] 克隆 Dobby (chiteroman/master，规避 arm64 asm 报错) ..."
DOBBY_DIR="third_party/Dobby"
git clone --depth=1 -b master https://github.com/chiteroman/Dobby.git "$DOBBY_DIR"
SRC_DIR=$PWD/$DOBBY_DIR

echo "[4/6] CMake 配置 (arm64-v8a) ..."
mkdir -p build && cd build
cmake -S "$SRC_DIR" -B . \
  -DCMAKE_TOOLCHAIN_FILE=$NDK_HOME/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DDOBBY_GENERATE_SHARED=OFF \
  -DDOBBY_DISABLE_NOOP=true \
  -DCMAKE_BUILD_TYPE=Release \
  -G "Unix Makefiles"

echo "[5/6] 编译 ..."
make -j$(nproc)

echo "[6/6] 提取产物 ..."
mkdir -p ../output
cp libdobby.a ../output/ 2>/dev/null || cp */libdobby.a ../output/ 2>/dev/null || true
echo "✅ 完成！产物在 output/libdobby.a"
