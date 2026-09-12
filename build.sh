#!/bin/bash
set -e

echo "[1/5] 探测 Android NDK ..."
# 强制优先使用 r25c，避免兜底到 ndk 27
NDK_HOME=${ANDROID_NDK_HOME:-/usr/local/lib/android/sdk/ndk/r25c}
if [ ! -d "$NDK_HOME" ]; then
  NDK_HOME=$(ls -d /usr/local/lib/android/sdk/ndk/r25* 2>/dev/null | head -1)
fi
echo "NDK = $NDK_HOME"

echo "[2/5] 准备 Dobby 源码 ..."
mkdir -p third_party
DOBBY_DIR="third_party/Dobby"
rm -rf "$DOBBY_DIR"
# 直接克隆默认主干（master），不指定不存在的版本分支
git clone --depth=1 https://github.com/jmpews/Dobby.git "$DOBBY_DIR"
SRC_DIR=$PWD/$DOBBY_DIR

echo "[3/5] CMake 配置 ..."
mkdir -p build
cd build
cmake -S "$SRC_DIR" -B . \
  -DCMAKE_TOOLCHAIN_FILE=$NDK_HOME/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DDOBBY_GENERATE_SHARED=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -G "Unix Makefiles"

echo "[4/5] 编译 ..."
make -j$(nproc)

echo "[5/5] 提取产物 ..."
mkdir -p ../output
cp libdobby.a ../output/ 2>/dev/null || cp */libdobby.a ../output/ 2>/dev/null || true
echo "完成！产物在 output/libdobby.a"
