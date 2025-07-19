@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
set "REPO_ZIP_URL=https://github.com/JocoPurnomoJP/AiArtImpostor-BepInExMods/archive/refs/heads/main.zip"
set "DLL_URL=https://github.com/JocoPurnomoJP/AiArtImpostor-BepInExMods/raw/main/plugins/ModApplyToggle.dll"
set "LOG_FILE=init_log.txt"
set "TEMP_DIR_NAME=_temp_bepinex_setup"
set "TEMP_FULL_PATH=%CD%\%TEMP_DIR_NAME%"
set "ZIP_FILE_PATH=%TEMP_FULL_PATH%\repo.zip"

echo Initializing log... > "%LOG_FILE%"

echo ===========================================
echo   AiArtImpostor BepInEx Mod Setup Script
echo ===========================================
echo.

:: --- 1. init.batを実行しているフォルダが適切か確認 ---
echo === 1. Environment Check ===
echo.
echo Checking for "AIArtImpostor.exe"...
if not exist "AIArtImpostor.exe" goto :exe_not_found
echo "AIArtImpostor.exe" found. Proceeding.
echo log: "AIArtImpostor.exe" found. >> "%LOG_FILE%"
echo.
goto :continue_phase2

:exe_not_found
echo ERROR: "AIArtImpostor.exe" not found in this directory.
echo Please place init.bat in the same folder as "AIArtImpostor.exe".
echo log: "AIArtImpostor.exe" not found. Script aborted. >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:: --- 2. リポジトリのinitフォルダの中身をダウンロードして配置 ---
:continue_phase2
echo === 2. Downloading and Extracting Files ===
echo.
echo Creating temporary directory: "%TEMP_FULL_PATH%"
if exist "%TEMP_FULL_PATH%" rmdir /s /q "%TEMP_FULL_PATH%" >nul 2>&1
mkdir "%TEMP_FULL_PATH%" >nul 2>&1
if errorlevel 1 goto :temp_dir_creation_error
echo Temporary directory created.
echo log: Temporary directory created. >> "%LOG_FILE%"
echo.
goto :continue_download_zip

:temp_dir_creation_error
echo ERROR: Failed to create temporary directory "%TEMP_FULL_PATH%".
echo Check disk space or write permissions.
echo log: Failed to create temporary directory. >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:continue_download_zip
echo Downloading GitHub repository ZIP file...
echo (This may take a moment. Please wait...)
echo log: Starting ZIP download from %REPO_ZIP_URL% >> "%LOG_FILE%"
curl -L -s -o "%ZIP_FILE_PATH%" "%REPO_ZIP_URL%" >nul 2>&1
if errorlevel 1 goto :curl_download_error
echo ZIP file downloaded.
echo log: ZIP file downloaded. >> "%LOG_FILE%"
goto :continue_extract_zip

:curl_download_error
echo ERROR: Failed to download ZIP file.
echo Check your internet connection or if curl is installed.
echo log: Failed to download ZIP file (curl error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:continue_extract_zip
echo Extracting ZIP file to temporary directory...
echo log: Starting ZIP extraction. >> "%LOG_FILE%"
tar -xf "%ZIP_FILE_PATH%" -C "%TEMP_FULL_PATH%" >nul 2>&1
if errorlevel 1 goto :tar_extract_error
echo ZIP file extraction complete.
echo log: ZIP file extraction complete. >> "%LOG_FILE%"
goto :continue_get_root_dir

:tar_extract_error
echo ERROR: Failed to extract ZIP file.
echo Your Windows might not have tar command built-in or ZIP is corrupt.
echo log: Failed to extract ZIP file (tar error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:continue_get_root_dir
:: Get the extracted root folder name (e.g., AiArtImpostor-BepInExMods-main)
set "EXTRACTED_ROOT_DIR="
for /d %%d in ("%TEMP_FULL_PATH%\*") do set "EXTRACTED_ROOT_DIR=%%d"

if not exist "%EXTRACTED_ROOT_DIR%" goto :extracted_root_not_found
echo log: Extracted root directory: "%EXTRACTED_ROOT_DIR%" >> "%LOG_FILE%"
echo Copying required files to game directory...
goto :continue_copy_bepinex

:extracted_root_not_found
echo ERROR: Extracted root folder not found.
echo ZIP file might not have extracted correctly.
echo log: Extracted root folder not found. >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:continue_copy_bepinex
:: Copy BepInEx folder contents
if not exist "%EXTRACTED_ROOT_DIR%\init\BepInEx" goto :bepinex_source_not_found_warn
echo Copying BepInEx folder...
xcopy "%EXTRACTED_ROOT_DIR%\init\BepInEx" ".\BepInEx\" /E /I /Y >nul 2>&1
if errorlevel 1 goto :xcopy_bepinex_error
echo BepInEx folder copied.
echo log: BepInEx folder copied. >> "%LOG_FILE%"
goto :continue_copy_dotnet_folder

:xcopy_bepinex_error
echo ERROR: Failed to copy BepInEx folder.
echo log: Failed to copy BepInEx folder (xcopy error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:bepinex_source_not_found_warn
echo WARNING: "init\BepInEx" not found in downloaded ZIP. Skipping BepInEx copy.
echo log: WARNING: "init\BepInEx" not found in ZIP. >> "%LOG_FILE%"
goto :continue_copy_dotnet_folder

:continue_copy_dotnet_folder
:: *** NEW: Copy 'dotnet' folder contents ***
if not exist "%EXTRACTED_ROOT_DIR%\init\dotnet" goto :dotnet_source_not_found_warn
echo Copying dotnet folder...
xcopy "%EXTRACTED_ROOT_DIR%\init\dotnet" ".\dotnet\" /E /I /Y >nul 2>&1
if errorlevel 1 goto :xcopy_dotnet_error
echo dotnet folder copied.
echo log: dotnet folder copied. >> "%LOG_FILE%"
goto :continue_copy_doorstop

:xcopy_dotnet_error
echo ERROR: Failed to copy dotnet folder.
echo log: Failed to copy dotnet folder (xcopy error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:dotnet_source_not_found_warn
echo WARNING: "init\dotnet" not found in downloaded ZIP. Skipping dotnet copy.
echo This might be expected if your game already has this folder.
echo log: WARNING: "init\dotnet" not found in ZIP. >> "%LOG_FILE%"
goto :continue_copy_doorstop

:continue_copy_doorstop
:: Copy doorstop_config.ini
if not exist "%EXTRACTED_ROOT_DIR%\init\doorstop_config.ini" goto :doorstop_source_not_found_warn
echo Copying doorstop_config.ini...
copy /Y "%EXTRACTED_ROOT_DIR%\init\doorstop_config.ini" ".\" >nul 2>&1
if errorlevel 1 goto :copy_doorstop_error
echo doorstop_config.ini copied.
echo log: doorstop_config.ini copied. >> "%LOG_FILE%"
echo.
goto :continue_copy_doorstop_version

:copy_doorstop_error
echo ERROR: Failed to copy doorstop_config.ini.
echo log: Failed to copy doorstop_config.ini (copy error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:doorstop_source_not_found_warn
echo WARNING: "init\doorstop_config.ini" not found in downloaded ZIP. Skipping.
echo log: WARNING: "init\doorstop_config.ini" not found in ZIP. >> "%LOG_FILE%"
echo.
goto :continue_copy_doorstop_version

:continue_copy_doorstop_version
:: Copy .doorstop_version
if not exist "%EXTRACTED_ROOT_DIR%\init\.doorstop_version" goto :doorstop_version_source_not_found_warn
echo Copying .doorstop_version...
copy /Y "%EXTRACTED_ROOT_DIR%\init\.doorstop_version" ".\" >nul 2>&1
if errorlevel 1 goto :copy_doorstop_version_error
echo .doorstop_version copied.
echo log: .doorstop_version copied. >> "%LOG_FILE%"
echo.
goto :continue_copy_winhttp

:copy_doorstop_version_error
echo ERROR: Failed to copy .doorstop_version.
echo log: Failed to copy .doorstop_version (copy error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:doorstop_version_source_not_found_warn
echo WARNING: "init\.doorstop_version" not found in downloaded ZIP. Skipping.
echo log: WARNING: "init\.doorstop_version" not found in ZIP. >> "%LOG_FILE%"
echo.
goto :continue_copy_winhttp

:continue_copy_winhttp
:: Copy winhttp.dll
if not exist "%EXTRACTED_ROOT_DIR%\init\winhttp.dll" goto :winhttp_source_not_found_warn
echo Copying winhttp.dll...
copy /Y "%EXTRACTED_ROOT_DIR%\init\winhttp.dll" ".\" >nul 2>&1
if errorlevel 1 goto :copy_winhttp_error
echo winhttp.dll copied.
echo log: winhttp.dll copied. >> "%LOG_FILE%"
echo.
goto :continue_phase3

:copy_winhttp_error
echo ERROR: Failed to copy winhttp.dll.
echo log: Failed to copy winhttp.dll (copy error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:winhttp_source_not_found_warn
echo WARNING: "init\winhttp.dll" not found in downloaded ZIP. Skipping.
echo log: WARNING: "init\winhttp.dll" not found in ZIP. >> "%LOG_FILE%"
echo.
goto :continue_phase3

:: --- 3. ModApplyToggle.dll をダウンロードして配置 ---
:continue_phase3
echo === 3. Downloading ModApplyToggle.dll ===
echo.
set "DLL_DEST_DIR=.\BepInEx\plugins"
set "DLL_FULL_PATH=%DLL_DEST_DIR%\ModApplyToggle.dll"

echo Checking/creating destination folder: "%DLL_DEST_DIR%"
if not exist "%DLL_DEST_DIR%" (
    mkdir "%DLL_DEST_DIR%" >nul 2>&1
    if errorlevel 1 goto :dll_dir_creation_error
    echo Created folder "%DLL_DEST_DIR%".
)
echo log: Folder "%DLL_DEST_DIR%" check/creation complete. >> "%LOG_FILE%"
goto :continue_download_dll

:dll_dir_creation_error
echo ERROR: Failed to create folder "%DLL_DEST_DIR%".
echo log: Failed to create folder "%DLL_DEST_DIR%" (mkdir error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:continue_download_dll
echo Downloading ModApplyToggle.dll...
echo log: Starting ModApplyToggle.dll download from %DLL_URL% >> "%LOG_FILE%"
curl -L -s -o "%DLL_FULL_PATH%" "%DLL_URL%" >nul 2>&1
if errorlevel 1 goto :dll_download_error
echo ModApplyToggle.dll downloaded and placed.
echo log: ModApplyToggle.dll downloaded and placed. >> "%LOG_FILE%"
echo.
goto :continue_phase4

:dll_download_error
echo ERROR: Failed to download ModApplyToggle.dll.
echo log: Failed to download ModApplyToggle.dll (curl error). >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:: --- 4. ダウンロードしたファイル・フォルダが想定通り存在しているか確認 ---
:continue_phase4
echo === 4. File Verification ===
echo.
set "MISSING_FILES_LIST="
set "ALL_FILES_OK=true"

echo Verifying presence of key files:
set "EXPECTED_FILES[0]=AIArtImpostor.exe"
:: Expected: 'dotnet' folder at game root. Cannot check individual files.
set EXPECTED_PATHS[0]="AIArtImpostor.exe"
set EXPECTED_PATHS[1]="doorstop_config.ini"
set EXPECTED_PATHS[2]=".doorstop_version"
set EXPECTED_PATHS[3]="winhttp.dll"
set EXPECTED_PATHS[4]="BepInEx\config\BepInEx.cfg"

set EXPECTED_PATHS[5]="BepInEx\core\0Harmony.dll"
set EXPECTED_PATHS[6]="BepInEx\core\AsmResolver.dll"
set EXPECTED_PATHS[7]="BepInEx\core\AsmResolver.DotNet.dll"
set EXPECTED_PATHS[8]="BepInEx\core\AsmResolver.PE.dll"
set EXPECTED_PATHS[9]="BepInEx\core\AsmResolver.PE.File.dll"
set EXPECTED_PATHS[10]="BepInEx\core\AssetRipper.CIL.dll"
set EXPECTED_PATHS[11]="BepInEx\core\AssetRipper.Primitives.dll"
set EXPECTED_PATHS[12]="BepInEx\core\BepInEx.Core.dll"
set EXPECTED_PATHS[13]="BepInEx\core\BepInEx.Core.xml"
set EXPECTED_PATHS[14]="BepInEx\core\BepInEx.Preloader.Core.dll"
set EXPECTED_PATHS[15]="BepInEx\core\BepInEx.Preloader.Core.xml"
set EXPECTED_PATHS[16]="BepInEx\core\BepInEx.Unity.Common.dll"
set EXPECTED_PATHS[17]="BepInEx\core\BepInEx.Unity.Common.xml"
set EXPECTED_PATHS[18]="BepInEx\core\BepInEx.Unity.IL2CPP.dll"
set EXPECTED_PATHS[19]="BepInEx\core\BepInEx.Unity.IL2CPP.dll.config"
set EXPECTED_PATHS[20]="BepInEx\core\BepInEx.Unity.IL2CPP.xml"
set EXPECTED_PATHS[21]="BepInEx\core\Cpp2IL.Core.dll"
set EXPECTED_PATHS[22]="BepInEx\core\Disarm.dll"
set EXPECTED_PATHS[23]="BepInEx\core\dobby.dll"
set EXPECTED_PATHS[24]="BepInEx\core\Gee.External.Capstone.dll"
set EXPECTED_PATHS[25]="BepInEx\core\Iced.dll"
set EXPECTED_PATHS[26]="BepInEx\core\Il2CppInterop.Common.dll"
set EXPECTED_PATHS[27]="BepInEx\core\Il2CppInterop.Generator.dll"
set EXPECTED_PATHS[28]="BepInEx\core\Il2CppInterop.HarmonySupport.dll"
set EXPECTED_PATHS[29]="BepInEx\core\Il2CppInterop.Runtime.dll"
set EXPECTED_PATHS[30]="BepInEx\core\LibCpp2IL.dll"
set EXPECTED_PATHS[31]="BepInEx\core\Mono.Cecil.dll"
set EXPECTED_PATHS[32]="BepInEx\core\Mono.Cecil.Mdb.dll"
set EXPECTED_PATHS[33]="BepInEx\core\Mono.Cecil.Pdb.dll"
set EXPECTED_PATHS[34]="BepInEx\core\Mono.Cecil.Rocks.dll"
set EXPECTED_PATHS[35]="BepInEx\core\MonoMod.RuntimeDetour.dll"
set EXPECTED_PATHS[36]="BepInEx\core\MonoMod.Utils.dll"
set EXPECTED_PATHS[37]="BepInEx\core\SemanticVersioning.dll"
set EXPECTED_PATHS[38]="BepInEx\core\StableNameDotNet.dll"
set EXPECTED_PATHS[39]="BepInEx\core\WasmDisassembler.dll"

set EXPECTED_PATHS[40]="BepInEx\plugins\ModApplyToggle.dll"

set EXPECTED_PATHS[41]="dotnet\.version"
set EXPECTED_PATHS[42]="dotnet\clretwrc.dll"
set EXPECTED_PATHS[43]="dotnet\clrjit.dll"
set EXPECTED_PATHS[44]="dotnet\coreclr.dll"
set EXPECTED_PATHS[45]="dotnet\dbgshim.dll"
set EXPECTED_PATHS[46]="dotnet\hostpolicy.dll"
set EXPECTED_PATHS[47]="dotnet\Microsoft.Bcl.AsyncInterfaces.dll"
set EXPECTED_PATHS[48]="dotnet\Microsoft.CSharp.dll"
set EXPECTED_PATHS[49]="dotnet\Microsoft.DiaSymReader.Native.amd64.dll"
set EXPECTED_PATHS[50]="dotnet\Microsoft.Extensions.DependencyInjection.Abstractions.dll"
set EXPECTED_PATHS[51]="dotnet\Microsoft.Extensions.DependencyInjection.dll"
set EXPECTED_PATHS[52]="dotnet\Microsoft.Extensions.Logging.Abstractions.dll"
set EXPECTED_PATHS[53]="dotnet\Microsoft.Extensions.Logging.dll"
set EXPECTED_PATHS[54]="dotnet\Microsoft.Extensions.Options.dll"
set EXPECTED_PATHS[55]="dotnet\Microsoft.Extensions.Primitives.dll"
set EXPECTED_PATHS[56]="dotnet\Microsoft.NETCore.App.deps.json"
set EXPECTED_PATHS[57]="dotnet\Microsoft.NETCore.App.runtimeconfig.json"
set EXPECTED_PATHS[58]="dotnet\Microsoft.VisualBasic.Core.dll"
set EXPECTED_PATHS[59]="dotnet\Microsoft.VisualBasic.dll"
set EXPECTED_PATHS[60]="dotnet\Microsoft.Win32.Primitives.dll"
set EXPECTED_PATHS[61]="dotnet\Microsoft.Win32.Registry.dll"
set EXPECTED_PATHS[62]="dotnet\mscordaccore.dll"
set EXPECTED_PATHS[63]="dotnet\mscordaccore_amd64_amd64_6.0.722.32202.dll"
set EXPECTED_PATHS[64]="dotnet\mscordbi.dll"
set EXPECTED_PATHS[65]="dotnet\mscorlib.dll"
set EXPECTED_PATHS[66]="dotnet\mscorrc.dll"
set EXPECTED_PATHS[67]="dotnet\msquic.dll"
set EXPECTED_PATHS[68]="dotnet\netstandard.dll"
set EXPECTED_PATHS[69]="dotnet\System.AppContext.dll"
set EXPECTED_PATHS[70]="dotnet\System.Buffers.dll"
set EXPECTED_PATHS[71]="dotnet\System.Collections.Concurrent.dll"
set EXPECTED_PATHS[72]="dotnet\System.Collections.dll"
set EXPECTED_PATHS[73]="dotnet\System.Collections.Immutable.dll"
set EXPECTED_PATHS[74]="dotnet\System.Collections.NonGeneric.dll"
set EXPECTED_PATHS[75]="dotnet\System.Collections.Specialized.dll"
set EXPECTED_PATHS[76]="dotnet\System.ComponentModel.Annotations.dll"
set EXPECTED_PATHS[77]="dotnet\System.ComponentModel.DataAnnotations.dll"
set EXPECTED_PATHS[78]="dotnet\System.ComponentModel.dll"
set EXPECTED_PATHS[79]="dotnet\System.ComponentModel.EventBasedAsync.dll"
set EXPECTED_PATHS[80]="dotnet\System.ComponentModel.Primitives.dll"
set EXPECTED_PATHS[81]="dotnet\System.ComponentModel.TypeConverter.dll"
set EXPECTED_PATHS[82]="dotnet\System.Configuration.dll"
set EXPECTED_PATHS[83]="dotnet\System.Console.dll"
set EXPECTED_PATHS[84]="dotnet\System.Core.dll"
set EXPECTED_PATHS[85]="dotnet\System.Data.Common.dll"
set EXPECTED_PATHS[86]="dotnet\System.Data.DataSetExtensions.dll"
set EXPECTED_PATHS[87]="dotnet\System.Data.dll"
set EXPECTED_PATHS[88]="dotnet\System.Diagnostics.Contracts.dll"
set EXPECTED_PATHS[89]="dotnet\System.Diagnostics.Debug.dll"
set EXPECTED_PATHS[90]="dotnet\System.Diagnostics.DiagnosticSource.dll"
set EXPECTED_PATHS[91]="dotnet\System.Diagnostics.FileVersionInfo.dll"
set EXPECTED_PATHS[92]="dotnet\System.Diagnostics.Process.dll"
set EXPECTED_PATHS[93]="dotnet\System.Diagnostics.StackTrace.dll"
set EXPECTED_PATHS[94]="dotnet\System.Diagnostics.TextWriterTraceListener.dll"
set EXPECTED_PATHS[95]="dotnet\System.Diagnostics.Tools.dll"
set EXPECTED_PATHS[96]="dotnet\System.Diagnostics.TraceSource.dll"
set EXPECTED_PATHS[97]="dotnet\System.Diagnostics.Tracing.dll"
set EXPECTED_PATHS[98]="dotnet\System.dll"
set EXPECTED_PATHS[99]="dotnet\System.Drawing.dll"
set EXPECTED_PATHS[100]="dotnet\System.Drawing.Primitives.dll"
set EXPECTED_PATHS[101]="dotnet\System.Dynamic.Runtime.dll"
set EXPECTED_PATHS[102]="dotnet\System.Formats.Asn1.dll"
set EXPECTED_PATHS[103]="dotnet\System.Globalization.Calendars.dll"
set EXPECTED_PATHS[104]="dotnet\System.Globalization.dll"
set EXPECTED_PATHS[105]="dotnet\System.Globalization.Extensions.dll"
set EXPECTED_PATHS[106]="dotnet\System.IO.Compression.Brotli.dll"
set EXPECTED_PATHS[107]="dotnet\System.IO.Compression.dll"
set EXPECTED_PATHS[108]="dotnet\System.IO.Compression.FileSystem.dll"
set EXPECTED_PATHS[109]="dotnet\System.IO.Compression.Native.dll"
set EXPECTED_PATHS[110]="dotnet\System.IO.Compression.ZipFile.dll"
set EXPECTED_PATHS[111]="dotnet\System.IO.dll"
set EXPECTED_PATHS[112]="dotnet\System.IO.FileSystem.AccessControl.dll"
set EXPECTED_PATHS[113]="dotnet\System.IO.FileSystem.dll"
set EXPECTED_PATHS[114]="dotnet\System.IO.FileSystem.DriveInfo.dll"
set EXPECTED_PATHS[115]="dotnet\System.IO.FileSystem.Primitives.dll"
set EXPECTED_PATHS[116]="dotnet\System.IO.FileSystem.Watcher.dll"
set EXPECTED_PATHS[117]="dotnet\System.IO.IsolatedStorage.dll"
set EXPECTED_PATHS[118]="dotnet\System.IO.MemoryMappedFiles.dll"
set EXPECTED_PATHS[119]="dotnet\System.IO.Pipes.AccessControl.dll"
set EXPECTED_PATHS[120]="dotnet\System.IO.Pipes.dll"
set EXPECTED_PATHS[121]="dotnet\System.IO.UnmanagedMemoryStream.dll"
set EXPECTED_PATHS[122]="dotnet\System.Linq.dll"
set EXPECTED_PATHS[123]="dotnet\System.Linq.Expressions.dll"
set EXPECTED_PATHS[124]="dotnet\System.Linq.Parallel.dll"
set EXPECTED_PATHS[125]="dotnet\System.Linq.Queryable.dll"
set EXPECTED_PATHS[126]="dotnet\System.Memory.dll"
set EXPECTED_PATHS[127]="dotnet\System.Net.dll"
set EXPECTED_PATHS[128]="dotnet\System.Net.Http.dll"
set EXPECTED_PATHS[129]="dotnet\System.Net.Http.Json.dll"
set EXPECTED_PATHS[130]="dotnet\System.Net.HttpListener.dll"
set EXPECTED_PATHS[131]="dotnet\System.Net.Mail.dll"
set EXPECTED_PATHS[132]="dotnet\System.Net.NameResolution.dll"
set EXPECTED_PATHS[133]="dotnet\System.Net.NetworkInformation.dll"
set EXPECTED_PATHS[134]="dotnet\System.Net.Ping.dll"
set EXPECTED_PATHS[135]="dotnet\System.Net.Primitives.dll"
set EXPECTED_PATHS[136]="dotnet\System.Net.Quic.dll"
set EXPECTED_PATHS[137]="dotnet\System.Net.Requests.dll"
set EXPECTED_PATHS[138]="dotnet\System.Net.Security.dll"
set EXPECTED_PATHS[139]="dotnet\System.Net.ServicePoint.dll"
set EXPECTED_PATHS[140]="dotnet\System.Net.Sockets.dll"
set EXPECTED_PATHS[141]="dotnet\System.Net.WebClient.dll"
set EXPECTED_PATHS[142]="dotnet\System.Net.WebHeaderCollection.dll"
set EXPECTED_PATHS[143]="dotnet\System.Net.WebProxy.dll"
set EXPECTED_PATHS[144]="dotnet\System.Net.WebSockets.Client.dll"
set EXPECTED_PATHS[145]="dotnet\System.Net.WebSockets.dll"
set EXPECTED_PATHS[146]="dotnet\System.Numerics.dll"
set EXPECTED_PATHS[147]="dotnet\System.Numerics.Vectors.dll"
set EXPECTED_PATHS[148]="dotnet\System.ObjectModel.dll"
set EXPECTED_PATHS[149]="dotnet\System.Private.CoreLib.dll"
set EXPECTED_PATHS[150]="dotnet\System.Private.DataContractSerialization.dll"
set EXPECTED_PATHS[151]="dotnet\System.Private.Uri.dll"
set EXPECTED_PATHS[152]="dotnet\System.Private.Xml.dll"
set EXPECTED_PATHS[153]="dotnet\System.Private.Xml.Linq.dll"
set EXPECTED_PATHS[154]="dotnet\System.Reflection.DispatchProxy.dll"
set EXPECTED_PATHS[155]="dotnet\System.Reflection.dll"
set EXPECTED_PATHS[156]="dotnet\System.Reflection.Emit.dll"
set EXPECTED_PATHS[157]="dotnet\System.Reflection.Emit.ILGeneration.dll"
set EXPECTED_PATHS[158]="dotnet\System.Reflection.Emit.Lightweight.dll"
set EXPECTED_PATHS[159]="dotnet\System.Reflection.Extensions.dll"
set EXPECTED_PATHS[160]="dotnet\System.Reflection.Metadata.dll"
set EXPECTED_PATHS[161]="dotnet\System.Reflection.Primitives.dll"
set EXPECTED_PATHS[162]="dotnet\System.Reflection.TypeExtensions.dll"
set EXPECTED_PATHS[163]="dotnet\System.Resources.Reader.dll"
set EXPECTED_PATHS[164]="dotnet\System.Resources.ResourceManager.dll"
set EXPECTED_PATHS[165]="dotnet\System.Resources.Writer.dll"
set EXPECTED_PATHS[166]="dotnet\System.Runtime.CompilerServices.Unsafe.dll"
set EXPECTED_PATHS[167]="dotnet\System.Runtime.CompilerServices.VisualC.dll"
set EXPECTED_PATHS[168]="dotnet\System.Runtime.dll"
set EXPECTED_PATHS[169]="dotnet\System.Runtime.Extensions.dll"
set EXPECTED_PATHS[170]="dotnet\System.Runtime.Handles.dll"
set EXPECTED_PATHS[171]="dotnet\System.Runtime.InteropServices.dll"
set EXPECTED_PATHS[172]="dotnet\System.Runtime.InteropServices.RuntimeInformation.dll"
set EXPECTED_PATHS[173]="dotnet\System.Runtime.Intrinsics.dll"
set EXPECTED_PATHS[174]="dotnet\System.Runtime.Loader.dll"
set EXPECTED_PATHS[175]="dotnet\System.Runtime.Numerics.dll"
set EXPECTED_PATHS[176]="dotnet\System.Runtime.Serialization.dll"
set EXPECTED_PATHS[177]="dotnet\System.Runtime.Serialization.Formatters.dll"
set EXPECTED_PATHS[178]="dotnet\System.Runtime.Serialization.Json.dll"
set EXPECTED_PATHS[179]="dotnet\System.Runtime.Serialization.Primitives.dll"
set EXPECTED_PATHS[180]="dotnet\System.Runtime.Serialization.Xml.dll"
set EXPECTED_PATHS[181]="dotnet\System.Security.AccessControl.dll"
set EXPECTED_PATHS[182]="dotnet\System.Security.Claims.dll"
set EXPECTED_PATHS[183]="dotnet\System.Security.Cryptography.Algorithms.dll"
set EXPECTED_PATHS[184]="dotnet\System.Security.Cryptography.Cng.dll"
set EXPECTED_PATHS[185]="dotnet\System.Security.Cryptography.Csp.dll"
set EXPECTED_PATHS[186]="dotnet\System.Security.Cryptography.Encoding.dll"
set EXPECTED_PATHS[187]="dotnet\System.Security.Cryptography.OpenSsl.dll"
set EXPECTED_PATHS[188]="dotnet\System.Security.Cryptography.Primitives.dll"
set EXPECTED_PATHS[189]="dotnet\System.Security.Cryptography.X509Certificates.dll"
set EXPECTED_PATHS[190]="dotnet\System.Security.dll"
set EXPECTED_PATHS[191]="dotnet\System.Security.Principal.dll"
set EXPECTED_PATHS[192]="dotnet\System.Security.Principal.Windows.dll"
set EXPECTED_PATHS[193]="dotnet\System.Security.SecureString.dll"
set EXPECTED_PATHS[194]="dotnet\System.ServiceModel.Web.dll"
set EXPECTED_PATHS[195]="dotnet\System.ServiceProcess.dll"
set EXPECTED_PATHS[196]="dotnet\System.Text.Encoding.CodePages.dll"
set EXPECTED_PATHS[197]="dotnet\System.Text.Encoding.dll"
set EXPECTED_PATHS[198]="dotnet\System.Text.Encoding.Extensions.dll"
set EXPECTED_PATHS[199]="dotnet\System.Text.Encodings.Web.dll"
set EXPECTED_PATHS[200]="dotnet\System.Text.Json.dll"
set EXPECTED_PATHS[201]="dotnet\System.Text.RegularExpressions.dll"
set EXPECTED_PATHS[202]="dotnet\System.Threading.Channels.dll"
set EXPECTED_PATHS[203]="dotnet\System.Threading.dll"
set EXPECTED_PATHS[204]="dotnet\System.Threading.Overlapped.dll"
set EXPECTED_PATHS[205]="dotnet\System.Threading.Tasks.Dataflow.dll"
set EXPECTED_PATHS[206]="dotnet\System.Threading.Tasks.dll"
set EXPECTED_PATHS[207]="dotnet\System.Threading.Tasks.Extensions.dll"
set EXPECTED_PATHS[208]="dotnet\System.Threading.Tasks.Parallel.dll"
set EXPECTED_PATHS[209]="dotnet\System.Threading.Thread.dll"
set EXPECTED_PATHS[210]="dotnet\System.Threading.ThreadPool.dll"
set EXPECTED_PATHS[211]="dotnet\System.Threading.Timer.dll"
set EXPECTED_PATHS[212]="dotnet\System.Transactions.dll"
set EXPECTED_PATHS[213]="dotnet\System.Transactions.Local.dll"
set EXPECTED_PATHS[214]="dotnet\System.ValueTuple.dll"
set EXPECTED_PATHS[215]="dotnet\System.Web.dll"
set EXPECTED_PATHS[216]="dotnet\System.Web.HttpUtility.dll"
set EXPECTED_PATHS[217]="dotnet\System.Windows.dll"
set EXPECTED_PATHS[218]="dotnet\System.Xml.dll"
set EXPECTED_PATHS[219]="dotnet\System.Xml.Linq.dll"
set EXPECTED_PATHS[220]="dotnet\System.Xml.ReaderWriter.dll"
set EXPECTED_PATHS[221]="dotnet\System.Xml.Serialization.dll"
set EXPECTED_PATHS[222]="dotnet\System.Xml.XDocument.dll"
set EXPECTED_PATHS[223]="dotnet\System.Xml.XmlDocument.dll"
set EXPECTED_PATHS[224]="dotnet\System.Xml.XmlSerializer.dll"
set EXPECTED_PATHS[225]="dotnet\System.Xml.XPath.dll"
set EXPECTED_PATHS[226]="dotnet\System.Xml.XPath.XDocument.dll"
set EXPECTED_PATHS[227]="dotnet\WindowsBase.dll"
set "NUM_EXPECTED=228" :: Adjusted count for dotnet folder

for /L %%i in (0,1,!NUM_EXPECTED! - 1) do (
    set "FILE_TO_CHECK=!EXPECTED_PATHS[%%i]!"
    if not exist "!FILE_TO_CHECK!" (
        if "!FILE_TO_CHECK!" neq "" (
            echo WARNING: !FILE_TO_CHECK! is missing.
            set "MISSING_FILES_LIST=!MISSING_FILES_LIST! !FILE_TO_CHECK!"
            set "ALL_FILES_OK=false"
            echo log: WARNING: !FILE_TO_CHECK! is missing. >> "%LOG_FILE%"
        )
    ) else (
        echo OK: !FILE_TO_CHECK! exists.
        echo log: OK: !FILE_TO_CHECK! exists. >> "%LOG_FILE%"
    )
)

if "!ALL_FILES_OK!" == "false" goto :missing_files_error
echo.
echo All required files verified.
echo log: All required files verified. >> "%LOG_FILE%"
echo.
goto :continue_phase5

:missing_files_error
echo.
echo ERROR: Some required files are missing.
echo Missing files: %MISSING_FILES_LIST%
echo Setup might not be complete. Check "%LOG_FILE%" for details.
echo log: Some required files are missing. >> "%LOG_FILE%"
set "EXIT_CODE=1"
goto :final_cleanup_and_exit

:: --- 5. 設定OKメッセージと終了処理 ---
:continue_phase5
echo === 5. Setup Complete ===
echo.
echo **************************************
echo *                                    *
echo *           Setup Complete!          *
echo *                                    *
echo **************************************
echo.
echo All steps completed successfully.
echo You can now launch the game! BepInEx should be active.
echo.
echo log: BepInEx setup completed successfully. >> "%LOG_FILE%"
set "EXIT_CODE=0"
goto :final_cleanup_and_exit

:: --- Final Cleanup and Exit ---
:final_cleanup_and_exit
echo.
echo Cleaning up temporary files...
if exist "%TEMP_FULL_PATH%" (
    rmdir /s /q "%TEMP_FULL_PATH%" >nul 2>&1
    if !errorlevel! neq 0 (
        echo WARNING: Failed to remove temporary directory: "%TEMP_FULL_PATH%"
        echo Please delete it manually.
        echo log: WARNING: Failed to remove temporary directory. >> "%LOG_FILE%"
    ) else (
        echo Temporary directory removed.
        echo log: Temporary directory removed. >> "%LOG_FILE%"
    )
)
echo.
echo log: Script finished at %date% %time%. >> "%LOG_FILE%"
echo Press any key to close this window...
pause > nul
exit /b %EXIT_CODE%