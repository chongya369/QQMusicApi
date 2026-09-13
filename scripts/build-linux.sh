#!/usr/bin/env bash
# QQMusicApi Linux 本地打包脚本: 产出 dist/qqmusic-api-linux-x64
# 前置要求: python3 及 venv 模块 (Debian/Ubuntu: apt install python3 python3-venv)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# 1. 创建/复用打包虚拟环境
if [ ! -x ".venv-pack/bin/python" ]; then
    echo "[1/4] 创建打包虚拟环境 .venv-pack ..."
    if ! python3 -m venv .venv-pack; then
        echo "错误: 创建 venv 失败, 请先安装 python3-venv (Debian/Ubuntu: sudo apt install python3-venv)" >&2
        exit 1
    fi
else
    echo "[1/4] 复用已有虚拟环境 .venv-pack"
fi

# 2. 安装依赖(项目本体 + web 依赖 + PyInstaller)
echo "[2/4] 安装依赖 ..."
".venv-pack/bin/python" -m pip install --upgrade pip -q
".venv-pack/bin/python" -m pip install -e . fastapi uvicorn "pydantic-settings[toml]" loguru griffe pyinstaller -q

# 3. PyInstaller 打包为单文件可执行程序
echo "[3/4] PyInstaller 打包 ..."
".venv-pack/bin/pyinstaller" --noconfirm --clean --onefile --name qqmusic-api-linux-x64 --paths . \
    --hidden-import web.src.app \
    --hidden-import web.src.routes \
    --hidden-import web.src.modules \
    --hidden-import uvicorn.logging \
    --hidden-import uvicorn.loops.auto \
    --hidden-import uvicorn.protocols.http.auto \
    --hidden-import uvicorn.protocols.websockets.auto \
    --hidden-import uvicorn.lifespan.on \
    web/run.py

# 4. 附带默认配置(已存在则跳过)
echo "[4/4] 附带默认配置 ..."
[ -f dist/config.toml ] || cp web/config.example.toml dist/config.toml

echo
echo "打包完成: $ROOT/dist/qqmusic-api-linux-x64"
echo "使用方式: 将 qqmusic-api-linux-x64 与 config.toml 放同一目录后运行"
