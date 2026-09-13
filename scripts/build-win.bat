@echo off
chcp 65001 >nul
setlocal
REM QQMusicApi Windows 本地打包脚本: 产出 dist\qqmusic-api-win-x64.exe

set "ROOT=%~dp0.."
cd /d "%ROOT%"

REM 1. 创建/复用打包虚拟环境
if not exist ".venv-pack\Scripts\python.exe" (
    echo [1/4] 创建打包虚拟环境 .venv-pack ...
    python -m venv .venv-pack || goto :error
) else (
    echo [1/4] 复用已有虚拟环境 .venv-pack
)

REM 2. 安装依赖(项目本体 + web 依赖 + PyInstaller)
echo [2/4] 安装依赖 ...
".venv-pack\Scripts\python.exe" -m pip install --upgrade pip -q || goto :error
".venv-pack\Scripts\python.exe" -m pip install -e . fastapi uvicorn "pydantic-settings[toml]" loguru griffe pyinstaller -q || goto :error

REM 3. PyInstaller 打包为单文件 exe
echo [3/4] PyInstaller 打包 ...
".venv-pack\Scripts\pyinstaller.exe" --noconfirm --clean --onefile --name qqmusic-api-win-x64 --paths . --hidden-import web.src.app --hidden-import web.src.routes --hidden-import web.src.modules --hidden-import uvicorn.logging --hidden-import uvicorn.loops.auto --hidden-import uvicorn.protocols.http.auto --hidden-import uvicorn.protocols.websockets.auto --hidden-import uvicorn.lifespan.on web\run.py || goto :error

REM 4. 附带默认配置(已存在则跳过)
echo [4/4] 附带默认配置 ...
if not exist "dist\config.toml" copy "web\config.example.toml" "dist\config.toml" >nul

echo.
echo 打包完成: %ROOT%\dist\qqmusic-api-win-x64.exe
echo 使用方式: 将 qqmusic-api-win-x64.exe 与 config.toml 放同一目录后运行
exit /b 0

:error
echo.
echo 打包失败！请检查上方错误信息
exit /b 1
