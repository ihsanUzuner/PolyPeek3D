@echo off
rem Developer install: builds from source and installs to C:\PolyPeek3D (current user).
rem End users should use the Setup.exe from the Releases page instead.
cd /d "%~dp0"
echo.
echo === PolyPeek3D install (from source) ===
echo.

where dotnet >nul 2>&1
if errorlevel 1 goto nodotnet

taskkill /f /im PolyPeek3D.exe >nul 2>&1
if exist dist rmdir /s /q dist
if exist obj rmdir /s /q obj
if exist bin rmdir /s /q bin

echo [1/3] Building...
dotnet build PolyPeek3D.csproj -c Release -o dist
if errorlevel 1 goto fail

echo.
echo [2/3] Copying to C:\PolyPeek3D ...
robocopy dist C:\PolyPeek3D /E /NFL /NDL /NJH /NJS >nul
if errorlevel 8 goto fail

echo [3/3] Writing file associations...
reg import "%~dp0install.reg"
if errorlevel 1 goto fail
ie4uinit.exe -show >nul 2>&1

echo.
echo DONE. Double-click a 3D model file.
echo Note: if the icons do not change right away, sign out and back in.
echo.
pause
exit /b 0

:nodotnet
echo .NET SDK not found. Run this first:
echo     winget install Microsoft.DotNet.SDK.8
echo Then open a NEW window and run Install.bat again.
pause
exit /b 1

:fail
echo.
echo An ERROR occurred. See the message above.
pause
exit /b 1
