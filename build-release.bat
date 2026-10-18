@echo off
rem Builds release\PolyPeek3D-Setup-<ver>.exe (needs Inno Setup) and release\PolyPeek3D-<ver>-portable.zip
setlocal
cd /d "%~dp0"
rem the version number lives only in the VERSION file
set "VER="
if exist VERSION set /p VER=<VERSION
if defined VER set "VER=%VER: =%"
if not defined VER (echo VERSION file is missing or empty. & goto fail)

echo.
echo === PolyPeek3D %VER% release build ===
echo.
where dotnet >nul 2>&1
if errorlevel 1 (echo .NET SDK not found: winget install Microsoft.DotNet.SDK.8 & goto fail)

if exist dist rmdir /s /q dist
if exist obj rmdir /s /q obj
if exist bin rmdir /s /q bin
if exist release rmdir /s /q release

echo [1/4] Building...
dotnet build PolyPeek3D.csproj -c Release -o dist
if errorlevel 1 goto fail

echo [2/4] Preparing the package folder...
mkdir release\app
robocopy dist release\app /E /NFL /NDL /NJH /NJS >nul
if errorlevel 8 goto fail
del /q release\app\*.pdb 2>nul
del /q release\app\Microsoft.Web.WebView2.Wpf*.dll 2>nul
del /q release\app\*.xml 2>nul
rem if WebView2Loader.dll is in the root, the runtimes subfolder is not needed
if exist release\app\WebView2Loader.dll if exist release\app\runtimes rmdir /s /q release\app\runtimes
copy /y LICENSE release\app\ >nul
copy /y THIRD-PARTY-NOTICES.txt release\app\ >nul
xcopy /e /i /y licenses release\app\licenses >nul

echo [3/4] Portable zip...
mkdir release\PolyPeek3D
robocopy release\app release\PolyPeek3D /E /NFL /NDL /NJH /NJS >nul
copy /y portable\*.bat release\PolyPeek3D\ >nul
copy /y README.md release\PolyPeek3D\ >nul
copy /y README-TR.md release\PolyPeek3D\ >nul
powershell -NoProfile -Command "Compress-Archive -Path 'release\PolyPeek3D' -DestinationPath 'release\PolyPeek3D-%VER%-portable.zip' -Force"
if errorlevel 1 goto fail
rmdir /s /q release\PolyPeek3D

echo [4/4] Setup.exe...
set ISCC=
where ISCC >nul 2>&1 && set ISCC=ISCC
if not defined ISCC if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
if not defined ISCC (
  echo Inno Setup not found. Install it with:  winget install JRSoftware.InnoSetup
  echo The zip is ready, Setup.exe was skipped.
  goto done
)
"%ISCC%" /Qp /DAppVer=%VER% installer\PolyPeek3D.iss
if errorlevel 1 goto fail

:done
echo.
echo DONE. Output folder: %~dp0release
dir /b release | findstr /v /i "^app$"
if not defined CI pause
exit /b 0

:fail
echo.
echo An ERROR occurred. See the message above.
if not defined CI pause
exit /b 1
