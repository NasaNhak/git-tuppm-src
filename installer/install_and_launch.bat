@echo off
REM echo "%~dp0"

if exist 00.dat.tuppmbackup (
	@echo 01. Restoring backup for new installation
	rmdir 00 /s /q 2>NUL
	del 00.inf 2>NUL
    del 00.dat 2>NUL
	copy 00.dat.tuppmbackup 00.dat >NUL
) else (
	@echo 01. Creating backup
	copy 00.dat 00.dat.tuppmbackup >NUL
)

if exist MGSV_QAR_Tool.exe (
@echo 02. Extracting 00.dat
MGSV_QAR_Tool.exe 00.dat -r >NUL
) else (
	@echo QAR Tool not found
	pause
	exit /b
)

if exist "%~dp0Assets\" (
@echo 03. Copying mod files
xcopy "%~dp0Assets\*.*" "%~dp000\Assets\*.*" /s /e /y /q >NUL
xcopy "%~dp0init.lua" "%~dp000\" /y /q >NUL
) else (
	@echo Mod Assets folder not found
	pause
	exit /b
)

if exist inf_append_list.txt (
@echo 04. Appending to 00.inf
type inf_append_list.txt >> 00.inf
) else (
	@echo Mod file inf_append_list.txt not found
	pause
	exit /b
)

@echo 05. Creating modded 00.dat
MGSV_QAR_Tool.exe 00.inf -r >NUL

@echo 06. The Ultimate Phantom Pain Mod installed. Launching game

@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=Date: %ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% Time: %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo %ldt%

@echo OFF
set performCleanup=false
set /p input=Perform cleanup of install files?(y/n): 
if %input%==Y set performCleanup=true
if %input%==y set performCleanup=true
if %performCleanup%==true (
	echo Cleaning up mod install files
	rmdir Assets /s /q 2>NUL
	rmdir 00 /s /q 2>NUL
	del init.lua /f 2>NUL
	del 00.inf /f 2>NUL
	del MGSV_QAR_Tool.exe /f 2>NUL
	del zlib1.dll /f 2>NUL
	del pathid_list_ps3.bin /f 2>NUL
	del changeTracker.txt /f 2>NUL
	del dictionary.txt /f 2>NUL
	del inf_append_list.txt /f 2>NUL
	del ReadMe.txt /f 2>NUL
)


pause

set startGame=false
set /p input=Launch the game without editing TUPPMSettings file?(y/n): 
if %input%==Y set startGame=true
if %input%==y set startGame=true
if %performCleanup%==true (
	echo Launching game
	start steam://rungameid/287700
)

(goto) 2>nul & del "%~f0"