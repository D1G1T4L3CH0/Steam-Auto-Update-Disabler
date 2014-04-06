@echo off
:: Steam should NOT be running while the changes are applied. If so, the changes are just reverted upon restarting steam.

setlocal ENABLEDELAYEDEXPANSION

:: check if steam is running. inform user to close first. then exit.
call :checkSteam
:: make sure parameters were entered. if not, get input.
call :checkParameters %1
:: make sure the steamapps directory looks real. (check for acf files)
call :checkSteamappsExist
:: see if the script was run before, if so, warn user
call :checkPreviousRun
:: make a temporary directory for the script
call :createTempDir

cls
echo Updating Auto update behavior for...
echo -- -- -- -- Log Started %DATE% @ %TIME% -- -- -- -->>%~dp0\log.txt
pushd "%steamapps%"

:: Get list of acf files.
for %%a in (*.acf) do (
	:: Look for acf files with "AutoUpdateBehavior" "0".
	for /f "tokens=1,2 delims=	" %%x in (%%a) do (
		if %%x == "AutoUpdateBehavior" if %%y == "0" (
			:: Create a backup of the file first, then write the file changing the one value.
			echo %%a
			echo %%a>>%~dp0\log.txt
			call :backupFile %%a
			call :writeChange %%a
		)
	)
)

popd
echo.>>%~dp0\log.txt

echo.
echo Cleaning up...

:: Clean up temp files.
del /q "%tempdir%">nul
rmdir "%tempdir%">nul

echo Done. Press any key to close this window.
pause>nul
goto :EOF




:writeChange
	for /f "tokens=* delims=" %%n in (%1) do (
		set line=%%n
		for /f "tokens=1,2 delims=	" %%r in ("!line!") do (
			if %%r == "AutoUpdateBehavior" (
				set line=!line:"0"="1"!
			)
		)
		echo.!line!>>"%tempdir%\%1"
	)
	copy /y "%tempdir%\%1" "%1">nul
goto :EOF

:backupFile
	if not exist acf-backups\ mkdir acf-backups
	copy /y "%1" "acf-backups\%1">nul
goto :EOF

:createTempDir
	set tempdir=%TEMP%\steam-autoupdate-script-temp-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%
	mkdir "%tempdir%"
goto :EOF

:checkParameters
	if "%~1" == "" (
		echo No parameters were passed to the script. You can drop a steam library folder onto this script or enter parameters at the command line.
		echo.
		echo You may also just drop the Steam library folder on this window right now. Or you can type it in and press enter.
		echo.
		echo Click the X to close this window or don't type anything and press enter to cancel and close this.
		echo.
		set /p userInput=Steam Library Path: 
		echo.
		if "!userInput!" == "" exit
		call :setSteamapps !userInput!
	) else (
		call :setSteamapps %1
	)
goto :EOF

:checkPreviousRun
	if exist "%steamapps%\acf-backups" (
		echo It appears that you have already ran this script on this library.
		echo A backup was made: 
		for %%x in (%steamapps%\acf-backups) do echo %%~tx
		echo.
		echo Press any key to continue, or click the X ^(close button^) on this window to cancel.
		pause>nul
	)
goto :EOF

:checkSteam
	for /f "usebackq tokens=1" %%x in (`tasklist /fi "imagename eq steam.exe" /nh`) do (
		if /i "%%x" == "Steam.exe" (
			echo Steam appears to be running. Please close steam first. Press any key to close this window...
			pause>nul
			exit
		)
	)
goto :EOF

:checkSteamappsExist
	if not exist "%steamapps%\*.acf" (
		echo "%steamapps%"
		echo Does not contain ACF files. Please make sure to drop the steam library folder. Example: C:\Program Files\Steam\ OR D:\Steam
		echo The "steamapps" folder will exist within that folder. Press any key to close this window...
		pause>nul
		exit
	)
goto :EOF

:setSteamapps
	set steamapps=%~1\steamapps
goto :EOF
