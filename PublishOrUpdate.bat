@echo off
echo ============= Welcome to Cities: Skylines Paradox Mod Publisher =============
echo .............................. Script by StarQ ..............................
echo ............................... March 16, 2025 ..............................
echo 

setlocal enabledelayedexpansion

set "ProjectFolder=%CD%"

set "RESET=[0m"
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW_BLACK=[30;103m"

if not exist "%ProjectFolder%\Properties" (
    echo 
    echo %RED%[ERROR] 'Properties' folder is missing.%RESET%
	echo Make sure the 'Properties' folder with PublishConfiguration.xml is in the same folder as this script.
	echo Would you like to create the 'Properties' folder now? ^(Y/N^)
	set /p "confirmprop=> "
    set "confirmprop=!confirmprop: =!"
    if /i "!confirmprop!"=="Y" (
        mkdir "%ProjectFolder%\Properties"
        echo %GREEN%[INFO] 'Properties' folder created.%RESET%
    ) else (
        echo %RED%[INFO] Operation cancelled. Exiting...%RESET%
        pause
        exit /b
    )
)

if not exist "%ProjectFolder%\content" (
    echo 
    echo %RED%[ERROR] 'content' folder is missing.%RESET%
    echo Make sure the 'content' folder with everything you want to upload is in the same folder as this script.
	echo Would you like to create the 'content' folder now? ^(Y/N^)
    set /p "confirmCont=> "
    set "confirmCont=!confirmCont: =!"
    if /i "!confirmCont!"=="Y" (
        mkdir "%ProjectFolder%\content"
        echo %GREEN%[INFO] 'content' folder created.%RESET%
    ) else (
        echo %RED%[INFO] Operation cancelled. Exiting...%RESET%
        pause
        exit /b
    )
)

if not exist "%ProjectFolder%\Properties\PublishConfiguration.xml" (
    echo 
    echo %RED%[ERROR] 'PublishConfiguration.xml' is missing in 'Properties' folder.%RESET%
    pause
    exit /b
)

echo 
echo %GREEN%[OK] All required files exist in 'Properties'.%RESET%
echo 
echo %GREEN%[INFO] Listing files in 'content' folder by extension:%RESET%

set "extensions="
set "hasFiles=false"
set "hasUnsupportedFiles=false"

for /r "%ProjectFolder%\content" %%F in (*.*) do (
    set "hasFiles=true"
    set "ext=%%~xF"
    if /i "!ext:~1,2!"=="VT" (
        set "hasUnsupportedFiles=true"
    )

    set "found=false"
    for %%E in (!extensions!) do (
        if /i "%%E"=="!ext!" (
            set "found=true"
        )
    )
	
	if not !found! == true (
        set "extensions=!extensions! !ext!"
    )
)

if "%hasFiles%"=="false" (
    echo 
    echo %RED%[INFO] No files found in 'content' folder.%RESET%
    pause
    exit /b
)

if "!hasUnsupportedFiles!"=="true" (
    echo 
    echo %RED%[ERROR] Unsupported files detected.%RESET%
)

for /r "%ProjectFolder%\content" %%F in (*.cok *.Prefab *.Texture *.Geometry *.Surface) do (
    set "fullpath=%%F"
    set "filename=%%~nF"
    set "ext=%%~xF"
    set "parent=%%~dpF"

    if not exist "!parent!!filename!!ext!.cid" (
        echo 
        echo %RED%[ERROR] Missing CID file for: !fullpath:%ProjectFolder%\content\=content\!%RESET%
    )
)

set "rootHasFiles=false"
for %%F in ("%ProjectFolder%\content\*.*") do (
    set "rootHasFiles=true"
    goto :breakRootCheck
)
:breakRootCheck

if "!rootHasFiles!"=="false" (
    echo 
    echo No files found in the root of 'content'. Creating .dummy.txt...
    echo This is a dummy file to keep the folder from being empty. Do not delete before publishing/updating. > "%ProjectFolder%\content\.dummy.txt"
)

for %%E in (!extensions!) do (
    set /a fileCount=0
	for /r "%ProjectFolder%\content" %%F in (*%%E) do (
        set /a fileCount+=1
    )
    
	echo Files with extension: %%E ^(!fileCount!^)
    for /r "%ProjectFolder%\content" %%F in (*%%E) do (
        echo  - %%~nxF
	)
)

for /f "tokens=2 delims==/" %%A in ('findstr /i "<ModId" "%ProjectFolder%\Properties\PublishConfiguration.xml"') do (
    set "ModId=%%A"
)

:: Extract the DisplayName value
for /f "tokens=2 delims==/" %%A in ('findstr /i "<DisplayName" "%ProjectFolder%\Properties\PublishConfiguration.xml"') do (
    set "ModName=%%A"
)
:: Confirm action
set "ModId=!ModId:"=!"
set "ModId=!ModId: =!"
if "!ModId!"=="0" (
    set "action=publish"
    set "toolkit=Publish"
) else (
    set "action=update"
    set "toolkit=NewVersion"
)

echo %YELLOW_BLACK%[INFO] Are you sure you want to !action! the mod "%ModName%"? ^(Y/N^)%RESET%
set /p "confirm=> "
if /i "!confirm!"=="Y" (
    echo %GREEN%[INFO] Proceeding to %action% the mod "%ModName%"...%RESET%
) else (
    echo %RED%[INFO] Operation cancelled.%RESET%
	pause
    exit /b
)
echo 
echo %YELLOW_BLACK%Starting Mod %action%%RESET%
timeout /t 3 /nobreak
echo 
"%CSII_MODPUBLISHERPATH%" "%toolkit%" "Properties/PublishConfiguration.xml" -c "content" -v
echo Done
endlocal
pause