@echo off

if exist 00.dat.tuppmbackup (
	@echo 01. Restoring original 00.dat file
	rmdir 00 /s /q 2>NUL
	del 00.inf 2>NUL
    del 00.dat 2>NUL
	copy 00.dat.tuppmbackup 00.dat >nul
	del 00.dat.tuppmbackup 2>NUL
	@echo Mod uninstalled. Launching game
	
) else (
	@echo The backup file was not found. Seems the mod was never installed... Or *SOMEBODY* messed with the backup file
	pause
	exit /b
)


@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=Date: %ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% Time: %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo %ldt%


pause

set startGame=false
set /p input=Launch the game?(y/n): 
if %input%==Y set startGame=true
if %input%==y set startGame=true
if %performCleanup%==true (
	echo Launching game
	start steam://rungameid/287700
)

(goto) 2>nul & del "%~f0"