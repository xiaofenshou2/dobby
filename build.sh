#!/bin/bash
set -e

echo "[1/5] 探测 Android NDK ..."
# 优先使用环境变量，否则找常见路径（GitHub Actions 通常在这里）
NDK_HOME=${ANDROID_NDK_HOME:-/usr/local/lib/android/sdk/ndk/r25c}
if [ ! -d "$NDK_HOME" ]; then
  # 兜底查找（兼容你截图里的路径，但强制用 r25c 最好）
  NDK_HOME=$(ls -d /usr/local/lib/android/sdk/ndk/r25* 2>/dev/null | head -1)
fi
echo "NDK = $NDK_HOME"
TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64

echo "[2/5] 准备 Dobby 源码 ..."
mkdir -p third_party
if [ ! -f "third_party/Dobby/CMakeLists.txt" ]; then
  echo "克隆 Dobby v0.3.9 ..."
  rm -rf third_party/Dobby
  git clone --depth=1 --branch v0.3.9 https://github.com/jmpews/Dobby.git third_party/Dobby
else
  echo "Dobby 源码已存在"
fi
SRC_DIR=$PWD/third_party/Dobby

echo "[3/5] CMake 配置 ..."
mkdir -p build
cd build
cmake -S $SRC_DIR -B . \
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
