@echo off
rem Removes everything the developer install (Install.bat) put on this PC:
rem   C:\PolyPeek3D, PolyPeek3D's file associations, and %LOCALAPPDATA%\PolyPeek3D (settings, log, WebView2 data).
rem Other programs' associations are not touched. If you used Setup.exe, uninstall from Windows Settings - Apps instead.
setlocal
echo.
echo === Removing PolyPeek3D (dev install) ===
echo.
taskkill /f /im PolyPeek3D.exe >nul 2>&1
for %%E in (fbx glb gltf obj ply dae 3ds stl 3mf amf stp step) do (
  rem default program: only if it is still PolyPeek3D - another program may have taken it over since
  reg query "HKCU\Software\Classes\.%%E" /ve 2>nul | findstr /i /l /c:"PolyPeek3D.%%E" >nul && reg delete "HKCU\Software\Classes\.%%E" /ve /f >nul 2>&1
  rem the user's own Always-open-with choice, if it points to PolyPeek3D
  reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%E\UserChoice" /s 2>nul | findstr /i /l /c:"PolyPeek3D" >nul && reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%E\UserChoice" /f >nul 2>&1
  reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%E\UserChoiceLatest" /s 2>nul | findstr /i /l /c:"PolyPeek3D" >nul && reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%E\UserChoiceLatest" /f >nul 2>&1
  reg delete "HKCU\Software\Classes\.%%E\OpenWithProgids" /v "PolyPeek3D.%%E" /f >nul 2>&1
  reg delete "HKCU\Software\Classes\PolyPeek3D.%%E" /f >nul 2>&1
)
if exist "C:\PolyPeek3D" rmdir /s /q "C:\PolyPeek3D"
if exist "%LOCALAPPDATA%\PolyPeek3D" rmdir /s /q "%LOCALAPPDATA%\PolyPeek3D"
ie4uinit.exe -show >nul 2>&1
echo Removed: C:\PolyPeek3D, the file associations and the settings.
echo.
pause
