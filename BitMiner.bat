@echo off
rem ---- BITMINER: opens the game in its own small window in the corner of the screen ----
setlocal enabledelayedexpansion

set "TARGET=https://alberthang885-dev.github.io/bitminer/"
if "%~1"=="local" (
  set "HTML=%~dp0bitminer.html"
  call set "HTML=%%HTML:\=/%%"
  call set "TARGET=file:///%%HTML%%"
)
set "PROFILE=%LOCALAPPDATA%\BitMiner\profile"

set "WIDTH=856"
set "HEIGHT=648"

rem ---- find Chrome, then Edge ----
set "BROWSER="
for %%B in (
  "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
  "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
  "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
  "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
) do if not defined BROWSER if exist %%B set "BROWSER=%%~B"

if not defined BROWSER (
  echo Could not find Chrome or Edge - opening in your default browser instead.
  start "" "%TARGET%"
  exit /b
)

rem ---- put the window in the bottom-right corner of the working area ----
set "POSX=40"
set "POSY=40"
for /f "tokens=1,2" %%A in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $w=[System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea; ''{0} {1}'' -f ($w.Right-%WIDTH%-12),($w.Bottom-%HEIGHT%-12)" 2^>nul') do (
  set "POSX=%%A"
  set "POSY=%%B"
)
if !POSX! lss 0 set "POSX=0"
if !POSY! lss 0 set "POSY=0"

start "" powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0BitMiner-panic.ps1"
start "" "%BROWSER%" --app="%TARGET%" --user-data-dir="%PROFILE%" --window-size=%WIDTH%,%HEIGHT% --window-position=!POSX!,!POSY! --allow-file-access-from-files --disable-features=Translate
exit /b
