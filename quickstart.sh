#!/bin/bash
# 一键准备：克隆本仓库 + Dobby 源码，然后本地构建
set -e

echo "== 克隆 Dobby v0.3.9 =="
if [ ! -d "Dobby" ]; then
    git clone --depth=1 --branch v0.3.9 https://github.com/jmpews/Dobby.git Dobby
fi

echo "== 构建 libdobby.a =="
chmod +x build.sh
./build.sh

echo "== 完成 =="
ls -la libdobby.a
