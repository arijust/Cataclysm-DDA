@echo off
SETLOCAL

cd ..\msvc-full-features
set PATH=%PATH%;%VSAPPIDDIR%\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd
for /F "tokens=*" %%i in ('git describe --tags --always --dirty --match "cdda-experimental-*"') do set VERSION=%%i
if "%VERSION%"=="" (
set VERSION=Please install `git` to generate VERSION
)
findstr /c:%VERSION% ..\src\version.h > NUL 2> NUL
if %ERRORLEVEL% NEQ 0 (
echo Generating "version.h"...
echo VERSION defined as "%VERSION%"
>..\src\version.h echo #define VERSION "%VERSION%"
)

if /I "%~1"=="true" (
echo Compiling shader artifacts...
where shadercross >NUL 2>&1
if errorlevel 1 (
where glslangValidator >NUL 2>&1
if errorlevel 1 (
echo Shader compile failed: neither glslangValidator nor shadercross found on PATH.
echo See doc/c++/COMPILING.md SDL3 section for toolchain install.
exit /b 1
)
echo SDL_shadercross not found; producing SPIR-V only.
echo The D3D12 GPU backend needs DXIL artifacts; variant_pass will
echo probe-fail at runtime and the GPU sprite shader path stays inert.
echo Atlas fallback remains active. See doc/c++/COMPILING.md SDL3 section.
python ..\tools\build_shaders.py --shader-dir ..\data\shaders --formats spv --stamp ..\data\shaders\build-spv.stamp
) else (
python ..\tools\build_shaders.py --shader-dir ..\data\shaders --formats dxil --stamp ..\data\shaders\build-dxil.stamp
)
if errorlevel 1 (
echo Shader compile failed. See doc/c++/COMPILING.md SDL3 section for toolchain install.
exit /b 1
)
)
