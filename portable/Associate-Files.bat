@echo off
rem Portable: writes PolyPeek3D's file associations for the current user, pointing to this folder.
rem Keep the format table in step with install.reg and installer\PolyPeek3D.iss.
setlocal
set "APP=%~dp0"
if not exist "%APP%PolyPeek3D.exe" (echo PolyPeek3D.exe not found. & pause & exit /b 1)
echo Writing PolyPeek3D file associations (current user only)...
for %%E in (fbx glb gltf obj ply dae 3ds) do (
  reg add "HKCU\Software\Classes\.%%E" /ve /d "PolyPeek3D.%%E" /f >nul
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%E\UserChoice" /f >nul 2>&1
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%E\UserChoiceLatest" /f >nul 2>&1
)
for %%E in (fbx glb gltf obj ply dae 3ds stl 3mf amf stp step) do (
  reg add "HKCU\Software\Classes\.%%E\OpenWithProgids" /v "PolyPeek3D.%%E" /t REG_SZ /d "" /f >nul
)
call :prog fbx fbx "FBX 3D Model"
call :prog glb glb "GLB 3D Model"
call :prog gltf gltf "glTF 3D Model"
call :prog obj obj "OBJ 3D Model"
call :prog ply ply "PLY 3D Model"
call :prog dae dae "DAE 3D Model"
call :prog 3ds 3ds "3DS 3D Model"
call :prog stl stl "STL 3D Model"
call :prog 3mf generic "3MF 3D Model"
call :prog amf generic "AMF 3D Model"
call :prog stp generic "STEP CAD Model"
call :prog step generic "STEP CAD Model"
ie4uinit.exe -show >nul 2>&1
echo.
echo DONE. If you move this folder, run this file again.
echo Note: if the icons do not change right away, sign out and back in.
pause
exit /b 0

:prog
reg add "HKCU\Software\Classes\PolyPeek3D.%1" /ve /d "%~3" /f >nul
reg add "HKCU\Software\Classes\PolyPeek3D.%1\DefaultIcon" /ve /d "%APP%icons\%2.ico" /f >nul
reg add "HKCU\Software\Classes\PolyPeek3D.%1\shell\open\command" /ve /d "\"%APP%PolyPeek3D.exe\" \"%%1\"" /f >nul
exit /b 0
