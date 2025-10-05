@echo off
setlocal enabledelayedexpansion
chcp 65001

cls
title BepInEx & Pxslware Patcher
color 0e

set "paths[1]=C:\Program Files (x86)\Steam\steamapps\common\Gorilla Tag"
set "paths[2]=D:\SteamLibrary\steamapps\common\Gorilla Tag"
set "paths[3]=C:\Program Files\Oculus\Software\Software\another-axiom-gorilla-tag"
set "paths[4]=D:\Steam\steamapps\common\Gorilla Tag"

set "gamePath="
for /L %%i in (1,1,4) do (
    if exist "!paths[%%i]!" (
        set "gamePath=!paths[%%i]!"
        goto :FoundPath
    )
)

:: Ask user for path if not found
color 0c
set /p gamePath=Gorilla Tag directory not found. Please enter path: 
if not exist "%gamePath%" (
    echo Directory does not exist. Exiting...
    pause
    exit /b
)

:FoundPath
color 0e
echo Gorilla Tag found at: %gamePath%
timeout /t 1 >nul

cls
title [###-------] Downloading latest BepInEx
echo Downloading latest BepInEx...
for /f "tokens=*" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/BepInEx/BepInEx/releases/latest').assets | Where-Object { $_.name -like '*win_x64*.zip' } | Select-Object -ExpandProperty browser_download_url"') do (
    set "bepinexUrl=%%i"
)

if "%bepinexUrl%"=="" (
    color 0c
    echo Failed to fetch latest BepInEx release.
    pause
    exit /b
)

curl -L "%bepinexUrl%" -o "%~dp0BepInEx_latest.zip"
powershell -Command "Expand-Archive -Path '%~dp0BepInEx_latest.zip' -DestinationPath '%gamePath%' -Force"

cls
title [####------] Creating directories
mkdir "%gamePath%\BepInEx\config" 2>nul
mkdir "%gamePath%\BepInEx\plugins" 2>nul

cls
title [#####-----] Downloading latest config
curl -L "https://raw.githubusercontent.com/iiDk-the-actual/ModInfo/refs/heads/main/BepInEx.cfg" -o "%gamePath%\BepInEx\config\BepInEx.cfg"

cls
title [######----] Downloading Pxslware
echo Fetching latest pxslware.dll release...
for /f "tokens=*" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/PxslGames/pxslware/releases/latest').assets | Where-Object { $_.name -like '*.dll' } | Select-Object -ExpandProperty browser_download_url"') do (
    set "pxslwareUrl=%%i"
)

if "%pxslwareUrl%"=="" (
    color 0c
    echo Failed to get latest pxslware.dll release.
    pause
    exit /b
)

curl -L "%pxslwareUrl%" -o "%gamePath%\BepInEx\plugins\pxslware.dll"

cls
title [##########] Finished
echo BepInEx and pxslware.dll successfully installed!
del "%~dp0BepInEx_latest.zip" 2>nul
pause
exit /b