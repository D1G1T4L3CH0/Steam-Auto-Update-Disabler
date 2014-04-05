@echo off
:: Steam should NOT be running while the changes are applied. If so, the changes are just reverted upon restarting steam.

setlocal ENABLEDELAYEDEXPANSION

:: check if steam is running. inform user to close first. then exit.
call :checkSteam

call :checkParameters %1
set steamapps=%~1\steamapps
call :checkPreviousRun
call :createTempDir

pushd "%steamapps%"

:: Get list of acf files.
for %%a in (*.acf) do (
	:: Look for acf files with "AutoUpdateBehavior" "0".
	for /f "tokens=1,2 delims=	" %%x in (%%a) do (
		if %%x == "AutoUpdateBehavior" if %%y == "0" (
			:: Create a backup of the file first, then write the file changing the one value.
			call :backupFile %%a
			call :writeChange %%a
		)
	)
)

popd

:: Clean up temp files.
del /q "%tempdir%">nul
rmdir "%tempdir%">nul

pause
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
		echo Please drop a steam library folder onto this script. Press any key to close this window...
		pause>nul
		goto :EOF
	) else (
		if not exist "%~1\steamapps\*.acf" (
			echo The path specified:
			echo."%~1"
			echo Does not contain ACF files. Please make sure to drop the steam library folder. Example: C:\Program Files\Steam\ OR D:\Steam
			echo The "steamapps" folder will exist within that folder. Press any key to close this window...
			pause>nul
			exit
		)
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
