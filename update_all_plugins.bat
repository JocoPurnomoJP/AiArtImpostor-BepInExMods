@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
:: Base URL for the plugins folder on GitHub
set "DLL_URL1=https://github.com/JocoPurnomoJP/AiArtImpostor-BepInExMods/raw/main/plugins/ModApplyToggle.dll"
set "DLL_URL2=https://github.com/JocoPurnomoJP/AiArtImpostor-BepInExMods/raw/main/plugins/ModConcealRole.dll"
set "DLL_URL3=https://github.com/JocoPurnomoJP/AiArtImpostor-BepInExMods/raw/main/plugins/ModShowThemeList.dll"

:: Destination folder for the downloaded DLLs
set "DEST_FOLDER=.\BepInEx\plugins"
:: Log file name
set "LOG_FILE=update_plugins_log.txt"

:: --- Script Start ---
echo ===========================================
echo      AiArtImpostor Plugin Update Script
echo ===========================================
echo.
echo log: Starting plugin update process. >> "%LOG_FILE%"

:: --- 1. Check destination folder existence (assume it is created by init.bat) ---
echo === 1. Destination Folder Check ===
echo.
echo Checking if destination folder "%DEST_FOLDER%" exists...
if not exist "%DEST_FOLDER%" (
    echo ERROR: Destination folder "%DEST_FOLDER%" not found.
    echo Please run init.bat first to create the necessary folders.
    echo log: ERROR: Destination folder "%DEST_FOLDER%" not found. Script aborted. >> "%LOG_FILE%"
    goto :error_exit
)
echo Destination folder "%DEST_FOLDER%" found.
echo log: Destination folder "%DEST_FOLDER%" found. >> "%LOG_FILE%"
echo.


:: --- 2. Download and copy DLL files (Individual processing) ---
echo === 2. Downloading and Copying Plugins ===
echo.
set "DLL_DEST_DIR=.\BepInEx\plugins"

:ModApplyToggle_start
echo === Downloading ModApplyToggle.dll ===
echo.
set "DLL_FULL_PATH=%DLL_DEST_DIR%\ModApplyToggle.dll"
echo Downloading ModApplyToggle.dll...
echo log: Starting ModApplyToggle.dll download from %DLL_URL% >> "%LOG_FILE%"
curl -L -s -o "%DLL_FULL_PATH%" "%DLL_URL1%" >nul 2>&1
if errorlevel 1 goto :ModApplyToggle_dll_download_error
echo ModApplyToggle.dll downloaded and placed.
echo log: ModApplyToggle.dll downloaded and placed. >> "%LOG_FILE%"
echo.
goto :ModConcealRole_start

:ModApplyToggle_dll_download_error
echo ERROR: Failed to download ModApplyToggle.dll.
echo log: Failed to download ModApplyToggle.dll (curl error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :error_exit_loop

:ModConcealRole_start
echo === Downloading ModConcealRole.dll ===
echo.
set "DLL_FULL_PATH=%DLL_DEST_DIR%\ModConcealRole.dll"
echo Downloading ModConcealRole.dll...
echo log: Starting ModConcealRole.dll download from %DLL_URL% >> "%LOG_FILE%"
curl -L -s -o "%DLL_FULL_PATH%" "%DLL_URL2%" >nul 2>&1
if errorlevel 1 goto :ModConcealRole_dll_download_error
echo ModConcealRole.dll downloaded and placed.
echo log: ModConcealRole.dll downloaded and placed. >> "%LOG_FILE%"
echo.
goto :ModShowThemeList_start

:ModConcealRole_dll_download_error
echo ERROR: Failed to download ModConcealRole.dll.
echo log: Failed to download ModConcealRole.dll (curl error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :error_exit_loop


:ModShowThemeList_start
echo === Downloading ModShowThemeList.dll ===
echo.
set "DLL_FULL_PATH=%DLL_DEST_DIR%\ModShowThemeList.dll"
echo Downloading ModShowThemeList.dll...
echo log: Starting ModShowThemeList.dll download from %DLL_URL% >> "%LOG_FILE%"
curl -L -s -o "%DLL_FULL_PATH%" "%DLL_URL3%" >nul 2>&1
if errorlevel 1 goto :ModShowThemeList_dll_download_error
echo ModShowThemeList.dll downloaded and placed.
echo log: ModShowThemeList.dll downloaded and placed. >> "%LOG_FILE%"
echo.
goto :update_success

:ModShowThemeList_dll_download_error
echo ERROR: Failed to download ModShowThemeList.dll.
echo log: Failed to download ModShowThemeList.dll (curl error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit


:: --- Script Completion ---
:update_success
echo === 3. Update Complete ===
echo.
echo **************************************
echo *       Plugins Updated!       *
echo **************************************
echo.
echo All specified DLLs have been downloaded and placed in "%DEST_FOLDER%".
echo If any files already existed, they have been overwritten.
echo.
echo log: Plugin update process finished. >> "%LOG_FILE%"
goto :end

:error_exit_loop
echo.
echo One or more plugins failed to download correctly. Please check "%LOG_FILE%" for details.
echo log: Plugin update process encountered errors. >> "%LOG_FILE%"
goto :error_exit

:error_exit
echo.
echo An error occurred during the update process. Please check "%LOG_FILE%" for details.
echo log: Script exited with error. >> "%LOG_FILE%"
pause
exit /b 1

:end
echo log: Script finished at %date% %time%. >> "%LOG_FILE%"
echo Press any key to close this window...
pause > nul
exit /b 0