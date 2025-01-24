@echo off
setlocal EnableDelayedExpansion

:: Membersihkan layar
cls

:: Header
echo ========================================
echo        ELANG DASHBOARD UPLOADER
echo ========================================
echo.

:: Input pilihan operasi
echo Choose operation:
echo 1. Push code only
echo 2. Upload version APK only
echo 3. Both operations
set /p OPERATION="Enter your choice (1/2/3): "

if "!OPERATION!"=="" (
    echo Operation choice cannot be empty
    goto :EOF
)

if not "!OPERATION!"=="1" if not "!OPERATION!"=="2" if not "!OPERATION!"=="3" (
    echo Invalid operation choice
    goto :EOF
)

:: Input untuk push code (jika operasi 1 atau 3)
if "!OPERATION!"=="1" (
    goto CODE_CHANGELOG_INPUT
) else if "!OPERATION!"=="3" (
    goto CODE_CHANGELOG_INPUT
) else (
    goto VERSION_INPUT
)

:CODE_CHANGELOG_INPUT
echo Enter changelog for code push (e.g. feat:..., fix:...) (type 'END' on a new line when finished):
echo -------------------

set "CODE_CHANGELOG="
:CODE_CHANGELOG_LOOP
set /p "line="
if /i "%line%"=="END" goto CODE_CHANGELOG_DONE
set "CODE_CHANGELOG=!line!"
goto CODE_CHANGELOG_LOOP
:CODE_CHANGELOG_DONE

if "!OPERATION!"=="1" (
    goto PUSH_CODE
)

:VERSION_INPUT
:: Input version
set /p VERSION="Enter version (e.g. 1.0.1): "
if "!VERSION!"=="" (
    echo Version cannot be empty
    goto :EOF
)

:: Input build number
set /p BUILD="Enter build number (e.g. 2): "
if "!BUILD!"=="" (
    echo Build number cannot be empty
    goto :EOF
)

:: Input force update
set /p FORCE="Force update? (true/false): "
if "!FORCE!"=="" (
    echo Force update cannot be empty
    goto :EOF
)

:: Input changelog untuk version
echo.
echo Enter changelog for version (type 'END' on a new line when finished):
echo -------------------

set "VERSION_CHANGELOG="
:VERSION_CHANGELOG_LOOP
set /p "line="
if /i "%line%"=="END" goto VERSION_CHANGELOG_DONE
set "VERSION_CHANGELOG=!VERSION_CHANGELOG!    "%line%",!NL!"
goto VERSION_CHANGELOG_LOOP
:VERSION_CHANGELOG_DONE

:: Remove last comma and newline for version changelog
set "VERSION_CHANGELOG=!VERSION_CHANGELOG:~0,-1!"

if "!OPERATION!"=="3" (
    goto PUSH_CODE
) else (
    goto VERSION_RELEASE
)

:PUSH_CODE
:: Push code ke repository code
echo.
echo Pushing code to repository...
git init
git remote add code-repo https://github.com/JohanesSetiawan/testUploads.git
git add .
git commit -m "!CODE_CHANGELOG!"
git push -f code-repo master:main

if "!OPERATION!"=="1" (
    goto FINISH
)

:VERSION_RELEASE
:: Create temp directory for version release
echo.
echo Creating temporary directory for version release...
if exist temp_release rmdir /s /q temp_release
mkdir temp_release
cd temp_release

:: Initialize new git repo in temp directory for version
git init
git remote add version-repo https://github.com/AI-Elang/ElangDashboardUpdateApp.git

:: Create version.json content in temp directory
echo.
echo Creating version.json...
(
echo {
echo   "version": "%VERSION%",
echo   "build_number": %BUILD%,
echo   "force_update": %FORCE%,
echo   "url": "https://github.com/AI-Elang/ElangDashboardUpdateApp/releases/download/v%VERSION%/app-release.apk",
echo   "changelog": [
echo %VERSION_CHANGELOG%
echo   ]
echo }
) > version.json

:: Stage and commit version.json
git add version.json
git commit -m "chore: update to version %VERSION% (build %BUILD%)"

:: Force push to main branch
git push -f version-repo master:main

:: Return to parent directory
cd ..

:: Build APK
echo.
echo Building APK...
echo.
call flutter clean
call flutter pub get
call flutter build apk --release

:: Check if build successful
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Error: APK build failed
    goto :EOF
)

:: Create and upload release using GitHub CLI
echo.
echo Creating GitHub release...
gh release create v%VERSION% ^
    --title "Version %VERSION%" ^
    --notes "Version %VERSION% (Build %BUILD%)" ^
    --repo AI-Elang/ElangDashboardUpdateApp ^
    "build/app/outputs/flutter-apk/app-release.apk#Elang Dashboard v%VERSION%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Error: Failed to create GitHub release
    goto :EOF
)

:: Clean up temp directory
rmdir /s /q temp_release

:FINISH
echo.
echo ========================================
echo             Upload Complete
echo ========================================
if "!OPERATION!"=="1" (
    echo Operation: Push code only
    echo Code Changelog: %CODE_CHANGELOG%
) else if "!OPERATION!"=="2" (
    echo Operation: Upload version APK only
    echo Version: %VERSION%
    echo Build: %BUILD%
    echo Force Update: %FORCE%
) else (
    echo Operation: Both operations
    echo Code Changelog: %CODE_CHANGELOG%
    echo Version: %VERSION%
    echo Build: %BUILD%
    echo Force Update: %FORCE%
)
echo.
echo Don't forget to:
if "!OPERATION!"=="1" (
    echo 1. Verify the code push to testUploads repository
) else if "!OPERATION!"=="2" (
    echo 1. Verify the version release on ElangDashboardUpdateApp
    echo 2. Test the update on a device
) else (
    echo 1. Verify the code push to testUploads repository
    echo 2. Verify the version release on ElangDashboardUpdateApp
    echo 3. Test the update on a device
)
echo ========================================

pause