# 只编译 Dobby (libdobby.a) for Android arm64-v8a

不需要 ADOFAI 的其他文件，只要一个 **libdobby.a**（静态库）。

## 最简用法（无电脑也能做）

1. 新建一个干净的 GitHub 仓库（比如 `dobby-android`）
2. 只放这几个文件：
   ```
   build.yml        ← .github/workflows/build.yml
   build.sh
   CMakeLists.txt
   README.md
   ```
3. Push → Actions → Run workflow
4. 等 ~3 分钟 → 下载 Artifact `libdobby-arm64-v8a`
   里面的 `libdobby.a` 就是你要的东西

**Dobby 源码由 Actions 自动克隆**（build.sh 第 2 步），你完全不用手动下载。

## 产物

- `libdobby.a`（arm64-v8a, android-21, NDK r25c）
- 静态库，可直接链进你自己的 `libadofai_mod.so`

## 链进你自己的 so（用法示例）

```cmake
add_library(adofai_mod SHARED core/hook.c)
target_include_directories(adofai_mod PRIVATE dobby/include)
target_link_libraries(adofai_mod
    ${CMAKE_SOURCE_DIR}/path/to/libdobby.a
    log dl
)
```

## 本地编译（有 NDK 时）

```bash
# 先把 Dobby 源码放进 Dobby/ 目录
git clone --depth=1 --branch v0.3.9 https://github.com/jmpews/Dobby.git Dobby

export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/25.2.9519653
./build.sh
# 产物：./libdobby.a
```

## 注意

- ABI：arm64-v8a（如需要 armeabi-v7a 可改 build.sh 的 ABI 变量）
- NDK：r25c（Dobby 汇编兼容性最好）
- 静态库 libdobby.a，不是 .so
