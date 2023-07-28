
@echo off
color 0C
@C:\Windows\System32\chcp 28591 > nul
@C:\Windows\System32\mode con cols=105 lines=35
@Title Start as Admin 
:: Checking for admin rights
::------------------------------------------
REM --> Checking Permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> Error: No admistrative privlages
if '%errorlevel%' NEQ '0' (
REM --> Checking administrative privileges
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
@echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params = %*:"="
echo UAC.ShellExecute "%~s0", "%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
@cls
GOTO Python-check

:Python-check
:: Check for Python Installation
echo Checking Python
python --version 3>NUL
if errorlevel 1 GOTO errorNoPython
GOTO InstallGDown1

:errorNoPython
echo.
echo Error^: Python not installed
GOTO req-Install
:req-Install
cls
echo Required software for this installer is not detected.
echo Do you want to install the Required software?
echo This will install:
echo - Python 3.11.4
echo - GDown (Google Drive Downloader)
echo - WinRAR
echo.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO InstallGDown1
IF ERRORLEVEL 1  GOTO errorNoPython2
echo.

:errorNoPython2
cls
echo Installing Python 3.11.4 to PATH
echo This is a silent install, this means you won't see anything popup on your screen.
echo Please wait patiently until the script continues.
".\Installer-files\Installer-Scripts\python-3.11.4-amd64.exe" /q InstallAllUsers=1 PrependPath=1
timeout /T 3 /nobreak >nul
echo Python 3.11.4 has installed successfully
GOTO Python-check


:InstallGDown1
color 0C
echo.
echo Checking GDown
:: Check for GDown Installation
gdown --version 4>NUL
if errorlevel 1 goto errorNoGDown1
echo GDown is installed
GOTO InstallWRAR1


:errorNoGDown1
color 0C
echo GDown is not installed
echo Installing GDown
timeout /T 3 /nobreak >nul
pip install gdown
timeout /T 7 /nobreak >nul
GOTO InstallWRAR1


:InstallWRAR1
color 0C
echo.
echo Checking WinRAR
IF EXIST "C:\Program Files\WinRAR\WinRAR.exe" GOTO WRAR-Installed1
IF NOT EXIST "C:\Program Files\WinRAR\WinRAR.exe" GOTO WRAR-Install1
:WRAR-Installed1
color 0C
echo WinRAR is Installed.
:: Wait 3 seconds, arbitrary... but just enough time for user to read the instructions
timeout /T 3 /nobreak >nul
GOTO check-auto-up
:WRAR-Install1
color 0C
echo WinRAR is not installed
echo Launching the installer for WinRAR 64bit v622
echo This is a silent install, this means you won't see anything popup on your screen.
echo Please wait patiently until the script continues.
".\Installer-files\Installer-Scripts\winrar-installer.exe" /S
:: Wait 10 seconds, arbitrary... but just enough time for user to read the instructions
timeout /T 10 /nobreak >nul
GOTO check-auto-up


:: 1=yes, 0=default, 2=no
:check-auto-up
echo.
echo Checking for auto updates.
if not exist ".\Installer-files\Installer-Scripts\auto-update*.txt" break>".\Installer-files\Installer-Scripts\auto-update-0.txt"
if exist ".\Installer-files\Installer-Scripts\auto-update-1.txt" GOTO check-auto-1
if exist ".\Installer-files\Installer-Scripts\auto-update-0.txt" GOTO check-auto-0
if exist ".\Installer-files\Installer-Scripts\auto-update-2.txt" GOTO Main
:check-auto-1
color 0C
echo Auto Updates are enabled.
GOTO auto-update-fin
:check-auto-0
color 0C
echo Auto Updates are not enabled.
GOTO prompt-auto-up1

:prompt-auto-up1
echo.
echo Do you want to enable Auto Updates for this Installer Script?
echo This will install Git, if you do not have it already.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO auto-update-no
IF ERRORLEVEL 1  GOTO git-install
echo.

:git-install
cls
color 0C
echo.
echo Checking for Git
git --version 2>NUL
if errorlevel 1 GOTO errorNoGit
GOTO git-installed1

:errorNoGit
color 0C
echo Git is not installed
echo Downloading the installer for Git 2.41
:: download git with gdown
gdown --folder 1N0qd0b77UqqrYFzEyXOf1uKQufHOla0e -O ".\Installer-files\Installer-Scripts"
cls
color 0C
echo Download is finished
timeout /T 3 /nobreak >nul
echo Launching the installer for Git
start "" /wait ".\Installer-files\Installer-Scripts\Install-Git.cmd"
echo Cleaning up extra files...
del ".\Installer-files\Installer-Scripts\Git*.exe" 2>nul
GOTO git-installed1

:git-installed1
color 0C
echo Git is installed
echo.
REN ".\Installer-files\Installer-Scripts\auto-update-0.txt" "auto-update-1.txt" 2>nul
:: Creates local git repo
git init
git config --global --add safe.directory "*"
git pull https://github.com/ItsNifer/VP-20-Nifer.git
echo Auto updates are now enabled.
timeout /T 3 /nobreak >nul
GOTO auto-update-fin
:auto-update-fin
echo Checking for updates
:: stashes local changes, pulls updates from github, pushes local changes after it pulls.
:: waits in between each git command. If error, it will continue to Main Menu, and ignore the update. This way, the script will still be functional.
:::::::::::::::::::::::::::::::::::::::::::::
git stash >nul
if %ERRORLEVEL% == 0 GOTO git-stash-cont
if %ERRORLEVEL% == 1 GOTO git-stash-error
:git-stash-cont
    GOTO git-pull-1
:git-stash-error
    echo Scanning for local changes.
	timeout /T 3 /nobreak >nul
	GOTO Main
:git-pull-1
:::::::::::::::::::::::::::::::::::::::::::::
git pull https://github.com/ItsNifer/VP-20-Nifer.git >nul
if %ERRORLEVEL% == 0 GOTO git-pull-cont
if %ERRORLEVEL% == 1 GOTO git-pull-error
:git-pull-cont
    GOTO git-stash-2
:git-pull-error
    echo Auto update failed...
	timeout /T 3 /nobreak >nul
	GOTO Main
:git-stash-2
:::::::::::::::::::::::::::::::::::::::::::::
git stash pop >nul
if %ERRORLEVEL% == 0 GOTO git-stash2-cont
if %ERRORLEVEL% == 1 GOTO git-stash2-error
:git-stash2-cont
    GOTO Main
:git-stash2-error
    echo Pushed any known local changes to directory.
	echo.
	echo.
	echo Finished checking for updates.
	timeout /T 3 /nobreak >nul
	GOTO Main
:::::::::::::::::::::::::::::::::::::::::::::
:auto-update-no
echo.
echo Disabling auto Updates
REN ".\Installer-files\Installer-Scripts\auto-update-0.txt" "auto-update-2.txt" 2>nul
echo The Installer will no longer ask you for auto updates.
timeout /T 3 /nobreak >nul
GOTO Main
:::::::::::::::::::::::::::::::::::::::::::::



::------------------------------------------
:Main
@Title Vegas Pro Installer by Nifer
cls
color 0C
Echo.                                                        
echo		 MAGIX Vegas Pro 20 Installer
echo		  Patch and Script by Nifer
echo               Version - 1.15
echo		    Twitter - @NiferEdits
echo.
echo            1) Vegas Pro
echo.
echo            2) 3rd Party Plugins
echo.
echo            3) Clean up all installer files
echo.
echo            4) Quit
echo.
C:\Windows\System32\CHOICE /C 1234 /M "Type the number (1-4) of what option you want." /N
cls
echo.
IF ERRORLEVEL 4  GOTO Quit
IF ERRORLEVEL 3  GOTO 3
IF ERRORLEVEL 2  GOTO 2
IF ERRORLEVEL 1  GOTO 1
echo.

:1
GOTO SelectVegas
Echo ****************************************************************
Echo ***    (Option #1) Downloading and Installing Vegas Pro      ***
Echo ***		Current Build: Vegas Pro 20 Build 411			  ***
Echo ****************************************************************
echo.
:SelectVegas
color 0C
::Variable for WinRAR
set winrar="C:\Program Files\WinRAR\WinRAR.exe"
cls
@ECHO OFF
color 0C
Echo ****************************************************************
Echo ***    (Option #1) Downloading and Installing Vegas Pro      ***
Echo ***		Current Build: Vegas Pro 20 Build 411			  ***
Echo ****************************************************************
Echo.
echo		 Select what to Download and Install
echo.
echo            1) Vegas Pro + Deep Learning Modules + Patch (1.6 GB)
echo.
echo            2) Vegas Pro + Patch Only (630 MB)
echo.
echo            3) Deep Learning Modules Only (1 GB)
echo.
echo            4) Patch Only (18 MB)
echo.
echo            5) Main Menu
echo.
C:\Windows\System32\CHOICE /C 12345 /M "Type the number (1-5) of what you want to Select." /N
cls
echo.
IF ERRORLEVEL 5  GOTO Main
IF ERRORLEVEL 4  GOTO 14
IF ERRORLEVEL 3  GOTO 13
IF ERRORLEVEL 2  GOTO 12
IF ERRORLEVEL 1  GOTO 11
echo.


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 1
:11
cls
Echo.
:: Check if vegas is already installed
echo Checking if Vegas Pro is already installed
if exist "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall\" GOTO alrDown-11
echo Vegas Pro isn't installed, continuing to download
GOTO down-11
:alrDown-11
cls
echo Vegas Pro is already installed
echo Do you want to install it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectVegas
IF ERRORLEVEL 1  GOTO down-11
echo.
:down-11
cls
if exist "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall\" GOTO alrUninstall-11
GOTO install-11

:install-11
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
:: gdown command
gdown --folder 1CfHOmkla8pim4jH2xBFLeBdUFCLHWVh4 -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
echo Installing Vegas Pro
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Pro*.exe) do "%%~fa" /wait
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Deep*.exe) do "%%~fa" /wait
echo Installation is finished
timeout /T 3 /nobreak >nul
echo Creating a backup of Vegas Pro
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe.BAK*" /I /Q /Y /F
echo Created "vegas200.exe.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll.BAK*" /I /Q /Y /F
echo Created "ScriptPortal.Vegas.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll.BAK*" /I /Q /Y /F
echo Created "TransitionWPFLibrary.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
timeout /T 5 /nobreak >nul
echo Patching Vegas Pro
for /r ".\Installer-files\Vegas Pro" %%a in (vegas200*.exe) do "%%~fa" /wait /s /v/qb
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\vegas200.sfx.exe" 2>nul
GOTO Main

:: If user chooses to install when VP20 is already installed, Script will uninstall VP20 + Deep Learning Modules and install again.
:alrUninstall-11
cls
color 0C
echo Uninstalling any known installation of Vegas Pro 20
echo Please follow through with the un-install
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (*.exe) do start "" /wait "%%~fa"
if exist ".\Installer-files\Vegas Pro\" GOTO removeVeg-11
GOTO  install-11
:removeVeg-11
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
GOTO install-11



:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 2
:12
cls
Echo.
:: Check if vegas is already installed
echo Checking if Vegas Pro is already installed
if exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\" GOTO alrDown-12
echo Vegas Pro isn't installed, continuing to download
GOTO down-12
:alrDown-12
cls
echo Vegas Pro is already installed
echo Do you want to install it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectVegas
IF ERRORLEVEL 1  GOTO down-12
echo.
:down-12
cls
if exist "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall\" GOTO alrUninstall-12
GOTO install-12

:install-12
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
:: gdown command
gdown --folder 12DW0zJtyAb_YR7W9Y43CGwAqAH60YblD -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
echo Installing Vegas Pro
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Pro*.exe) do "%%~fa" /wait /s /v/qb
echo Installation is finished
timeout /T 3 /nobreak >nul
echo Creating a backup of Vegas Pro
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe.BAK*" /I /Q /Y /F
echo Created "vegas200.exe.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll.BAK*" /I /Q /Y /F
echo Created "ScriptPortal.Vegas.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll.BAK*" /I /Q /Y /F
echo Created "TransitionWPFLibrary.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
timeout /T 5 /nobreak >nul
echo Patching Vegas Pro
for /r ".\Installer-files\Vegas Pro" %%a in (vegas200*.exe) do "%%~fa" /wait /s /v/qb
echo Vegas Pro is now installed and patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\vegas200.sfx.exe"
GOTO Main

:: If user chooses to install when VP20 is already installed, Script will uninstall VP20 + Deep Learning Modules and install again.
:alrUninstall-12
cls
color 0C
echo Uninstalling any known installation of Vegas Pro 20
echo Please follow through with the un-install
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (*.exe) do start "" /wait "%%~fa"
if exist ".\Installer-files\Vegas Pro\" GOTO removeVeg-12
GOTO  install-12
:removeVeg-12
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
GOTO install-12


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 3
:13
cls
Echo.
:: Check if vegas deep learning modules is already installed
echo Checking if Vegas Pro Deep Learning Modules is already installed
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (VEGAS_Deep*.exe) do if exist "%%~fa" GOTO alrDown-13
echo Deep Learning Modules isn't installed, continuing to download
GOTO down-13
:alrDown-13
cls
echo Deep Learning Modules are already installed
echo Do you want to install it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectVegas
IF ERRORLEVEL 1  GOTO down-13
echo.
:down-13
cls
if exist "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall\" GOTO alrUninstall-13
GOTO install-13

:install-13
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
:: gdown command
gdown --folder 1g3jkCxUS87uylAvzxl0EL8dwUAlN7PCO -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
echo Installing Deep Learning Modules
echo Please follow through the installation
timeout /T 2 /nobreak >nul
for /r ".\Installer-files\Vegas Pro" %%a in (VEGAS_Deep*.exe) do "%%~fa" /wait /s /v/qb
echo Installation is finished
timeout /T 3 /nobreak >nul
GOTO Main

:: If user chooses to install when VP20 is already installed, Script will uninstall VP20 + Deep Learning Modules and install again.
:alrUninstall-13
cls
color 0C
echo Uninstalling any known installation of Vegas Pro Deep Learning Modules
echo Please follow through with the un-install
for /r "C:\Program Files (x86)\Common Files\VEGAS Services\Uninstall" %%a in (VEGAS_Deep*.exe) do start "" /wait "%%~fa"
if exist ".\Installer-files\Vegas Pro\" GOTO removeVeg-13
GOTO  install-13
:removeVeg-13
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
GOTO install-13


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 4
:14
cls
Echo.
:: Check if vegas is already installed
echo Checking if Vegas Pro is already installed
if exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\" GOTO install-14
echo Vegas Pro isn't installed, please select the menu option to download Vegas Pro
timeout /T 5 /nobreak >nul
GOTO Main

:install-14
cls
color 0c
echo Initializing Download...
if not exist ".\Installer-files\Vegas Pro" mkdir ".\Installer-files\Vegas Pro" 
:: gdown command
gdown --folder 1rv-kYFMmExwf_7h8dU9uaV3Oq6RXpPsG -O ".\Installer-files\Vegas Pro"
cls
color 0c
echo Download is finished
echo Creating a backup of Vegas Pro
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\vegas200.exe.BAK*" /I /Q /Y /F
echo Created "vegas200.exe.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\ScriptPortal.Vegas.dll.BAK*" /I /Q /Y /F
echo Created "ScriptPortal.Vegas.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
if not exist "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll.BAK" xcopy "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll*" "C:\Program Files\VEGAS\VEGAS Pro 20.0\TransitionWPFLibrary.dll.BAK*" /I /Q /Y /F
echo Created "TransitionWPFLibrary.dll.BAK" in "C:\Program Files\VEGAS\VEGAS Pro 20.0"
timeout /T 5 /nobreak >nul
echo Patching Vegas Pro
for /r ".\Installer-files\Vegas Pro" %%a in (vegas200*.exe) do "%%~fa" /wait /s /v/qb
echo Vegas Pro is now patched
timeout /T 3 /nobreak >nul
del ".\Installer-files\Vegas Pro\vegas200.sfx.exe"
GOTO Main




:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:2
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
echo.
GOTO SelectPlugins

:SelectPlugins
color 0C
::Variable for WinRAR
set winrar="C:\Program Files\WinRAR\WinRAR.exe"
:: Variables for each plugin, to call later on
set BFX-Sapphire=Boris FX Sapphire OFX by Nifer.rar
set BFX-Continuum=Boris FX Continuum Complete OFX by Nifer.rar
set BFX-Mocha=Boris FX Mocha Pro OFX by Nifer.rar
set BFX-Silhouette=Boris FX Silhouette by Nifer.rar
set FXH-Ignite=FXHOME Ignite Pro OFX by Nifer.rar
set MXN-MBL=MAXON Red Giant Magic Bullet Suite by Team V.R.rar
set MXN-Universe=MAXON Red Giant Universe by Team V.R.rar
set NFX-Titler=NewBlueFX Titler Pro 7 Ultimate by Nifer.rar
set NFX-TotalFX=NewBlueFX TotalFX 7 OFX by Nifer.rar
set RFX-Effections=REVisionFX Effections OFX by Team V.R.rar
set All-Plugins=All Plugins.rar

cls
@ECHO OFF
color 0C
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
Echo.
echo		 Select which plugins to Download
echo.
echo            1) All Plugins (6.8 GB)
echo.
echo            2) BORIS FX - Sapphire (670 MB)
echo.
echo            3) BORIS FX - Continuum (510 MB)
echo.
echo            4) BORIS FX - Mocha Pro (270 MB)
echo.
echo            5) BORIS FX - Silhouette (1.4 GB)
echo.
echo            6) FXHOME - Ignite Pro (430 MB)
echo.
echo            7) MAXON - Red Giant Magic Bullet Suite (260 MB)
echo.
echo            8) Next Page
echo.
echo            9) Main Menu
echo.
C:\Windows\System32\CHOICE /C 123456789 /M "Type the number (1-9) of what you want to Download." /N
cls
echo.
IF ERRORLEVEL 9  GOTO Main
IF ERRORLEVEL 8  GOTO SelectPlugins2
IF ERRORLEVEL 7  GOTO 27
IF ERRORLEVEL 6  GOTO 26
IF ERRORLEVEL 5  GOTO 25
IF ERRORLEVEL 4  GOTO 24
IF ERRORLEVEL 3  GOTO 23
IF ERRORLEVEL 2  GOTO 22
IF ERRORLEVEL 1  GOTO 21
echo.

:SelectPlugins2
cls
@ECHO OFF
color 0C
Echo *****************************************************************
Echo ***    (Option #2) Downloading 3rd Party Plugins for OFX      ***
Echo *****************************************************************
Echo.
echo		 Select which plugins to Download
echo.
echo            1) MAXON - Red Giant Universe (1.8 GB)
echo.
echo            2) NEWBLUEFX - Titler Pro 7 (630 MB)
echo.
echo            3) NEWBLUEFX - TotalFX 7 (790 MB)
echo.
echo            4) REVISIONFX - Effections (50 MB)
echo.
echo            5) Previous Page
echo.
echo            6) Main Menu
echo.
C:\Windows\System32\CHOICE /C 123456 /M "Type the number (1-6) of what you want to Download." /N
cls
echo.
IF ERRORLEVEL 6  GOTO Main
IF ERRORLEVEL 5  GOTO SelectPlugins
IF ERRORLEVEL 4  GOTO 224
IF ERRORLEVEL 3  GOTO 223
IF ERRORLEVEL 2  GOTO 222
IF ERRORLEVEL 1  GOTO 221
echo.


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 1
:21
cls
Echo.
:: Ask if user is sure they want to download all plugins
echo Are you sure you want to install all plugins?
echo Approx. 7 GB
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO checkdown-21
echo.
:: Check if all plugins are already downloaded
:checkdown-21
echo Checking if all plugins are already downloaded
if exist ".\Installer-files\Plugins\Boris FX Sapph*" GOTO alrDown21-22
GOTO down-21
:alrDown21-22
if exist ".\Installer-files\Plugins\Boris FX Cont*" GOTO alrDown21-23
GOTO down-21
:alrDown21-23
if exist ".\Installer-files\Plugins\Boris FX Mocha*" GOTO alrDown21-24
GOTO down-21
:alrDown21-24
if exist ".\Installer-files\Plugins\Boris FX Silho*" GOTO alrDown21-25
GOTO down-21
:alrDown21-25
if exist ".\Installer-files\Plugins\FXHOME Ign*" GOTO alrDown21-26
GOTO down-21
:alrDown21-26
if exist ".\Installer-files\Plugins\MAXON Red Giant Magic Bull*" GOTO alrDown21-27
GOTO down-21
:alrDown21-27
if exist ".\Installer-files\Plugins\MAXON Red Giant Uni*" GOTO alrDown21-221
GOTO down-21
:alrDown21-221
if exist ".\Installer-files\Plugins\NewBlueFX Titler*" GOTO alrDown21-222
GOTO down-21
:alrDown21-222
if exist ".\Installer-files\Plugins\NewBlueFX Total*" GOTO alrDown21-223
GOTO down-21
:alrDown21-223
if exist ".\Installer-files\Plugins\REVisionFX Eff*" GOTO prompt-allplug-down
GOTO down-21
:prompt-allplug-down
echo.
echo You already have all plugins downloaded
echo What do you want to do?
echo 1 = Re-download them all
echo 2 = Continue to installing
echo 3 = Back to Main Menu
echo.
C:\Windows\System32\CHOICE /C 123 /M "Type the number (1-3) of what you want." /N
cls
echo.
IF ERRORLEVEL 3  GOTO SelectPlugins
IF ERRORLEVEL 2  GOTO auto-21
IF ERRORLEVEL 1  GOTO checkdown-21
echo.
:down-21
cls
echo Initializing Download...
:: gdown command
gdown --folder 1BW9hUpvQ-DBZnweh2b_ZkHBvfl73dKgF -O ".\Installer-files"
cls
color 0C
echo Download Finished!
echo Renaming rar files
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%"
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%"
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%"
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%"
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%"
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%"
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%"
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%"
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%"
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%"
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
color 0C
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
color 0C
echo Extracting files
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o- ".\Installer-files\%BFX-Sapphire%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Continuum%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Mocha%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%BFX-Silhouette%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%FXH-Ignite%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%MXN-MBL%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%MXN-Universe%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%NFX-Titler%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%NFX-TotalFX%" ".\Installer-files\Plugins"
%winrar% x -o- ".\Installer-files\%RFX-Effections%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP21
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP21
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE21
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP21
)
:CONTINUE21
del ".\Installer-files\%BFX-Sapphire%"
del ".\Installer-files\%BFX-Continuum%"
del ".\Installer-files\%BFX-Mocha%"
del ".\Installer-files\%BFX-Silhouette%"
del ".\Installer-files\%FXH-Ignite%"
del ".\Installer-files\%MXN-MBL%"
del ".\Installer-files\%MXN-Universe%"
del ".\Installer-files\%NFX-Titler%"
del ".\Installer-files\%NFX-TotalFX%"
del ".\Installer-files\%RFX-Effections%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
GOTO auto-21

:auto-21
cls
echo How do you want to install the plugins?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-21
IF ERRORLEVEL 1  GOTO autoinst-21
echo.
:manual-21
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-21
cls
:: 1st auto install
echo Launching auto install script for Boris FX Continuum Complete
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-1
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-1
echo.
:no-auto-1
echo There is no auto install script for Boris FX Continuum Complete.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-1
cls
color 0C
:: 2nd auto install
echo Launching auto install script for Boris FX Mocha Pro
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-2
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-2
echo.
:no-auto-2
echo There is no auto install script for Boris FX Mocha Pro.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-2
cls
color 0C
:: 3rd auto install
echo Launching auto install script for Boris FX Sapphire
for /D %%I in (".\Installer-files\Plugins\Boris FX Sapph*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-3
for /D %%I in (".\Installer-files\Plugins\Boris FX Sapph*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-3
echo.
:no-auto-3
echo There is no auto install script for Boris FX Sapphire.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-3
cls
color 0C
:: 4th auto install
echo Launching auto install script for Boris FX Silhouette
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-4
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-4
echo.
:no-auto-4
echo There is no auto install script for Boris FX Silhouette.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-4
cls
color 0C
:: 5th auto install
echo Launching auto install script for FXHOME Ignite Pro
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-5
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-5
echo.
:no-auto-5
echo There is no auto install script for FXHOME Ignite Pro.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-5
cls
color 0C
:: 6th auto install
echo Launching auto install script for MAXON Red Giant Magic Bullet Suite
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-6
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-6
echo.
:no-auto-6
echo There is no auto install script for MAXON Red Giant Magic Bullet Suite.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-6
cls
color 0C
:: 7th auto install
echo Launching auto install script for MAXON Red Giant Universe
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-7
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-7
echo.
:no-auto-7
echo There is no auto install script for MAXON Red Giant Universe.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-7
cls
color 0C
:: 8th auto install
echo Launching auto install script for NewBlueFX Titler Pro 7 Ultimate
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-8
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-8
echo.
:no-auto-8
echo There is no auto install script for NewBlueFX Titler Pro 7 Ultimate.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-8
cls
color 0C
:: 9th auto install
echo Launching auto install script for NewBlueFX TotalFX 7
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-9
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
echo.
echo When the auto install script is finished, please press the Number #1
echo If you want to cancel the auto install process and return to the main menu, please press the Number #2
echo 1 = Continue Auto Install
echo 2 = Cancel Auto Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO autoscript-9
echo.
:no-auto-9
echo There is no auto install script for NewBlueFX TotalFX 7.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins
:autoscript-9
cls
color 0C
:: 10th auto install
echo Launching auto install script for REVisionFX Effections
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do if not exist "%%~I\INSTALL.cmd" GOTO no-auto-10
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do call "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:no-auto-10
echo There is no auto install script for REVisionFX Effections.
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 10 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 2
:22
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Sapph*" GOTO alrDown-22
echo Plugin isn't downloaded, continuing to download
GOTO down-22
:alrDown-22
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-22
echo.
:down-22
cls
echo Initializing Download...
:: gdown command
gdown --folder 1FowQpPfNNwHeykCfHCEfeeS1WkZdVh_U -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%BFX-Sapphire%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP22
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP22
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE22
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP22
)
:CONTINUE22
del ".\Installer-files\%BFX-Sapphire%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if exist "%%~I\INSTALL.cmd" GOTO auto-22
GOTO SelectPlugins

:auto-22
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-22
IF ERRORLEVEL 1  GOTO autoinst-22
echo.
:manual-22
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-22
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 3
:23
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Cont*" GOTO alrDown-23
echo Plugin isn't downloaded, continuing to download
GOTO down-23
:alrDown-23
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-23
echo.
:down-23
cls
echo Initializing Download...
:: gdown command
gdown --folder 1CN3oJ4D2FPO3S9joBEjFtdlOuQD9H6QJ -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%BFX-Continuum%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP23
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP23
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE23
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP23
)
:CONTINUE23
del ".\Installer-files\%BFX-Continuum%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do if exist "%%~I\INSTALL.cmd" GOTO auto-23
GOTO SelectPlugins

:auto-23
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-23
IF ERRORLEVEL 1  GOTO autoinst-23
echo.
:manual-23
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-23
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\Boris FX Cont*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 4
:24
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Mocha*" GOTO alrDown-24
echo Plugin isn't downloaded, continuing to download
GOTO down-24
:alrDown-24
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-24
echo.
:down-24
cls
echo Initializing Download...
:: gdown command
gdown --folder 1MD9cFQVUPIAhOuO5BC99MTlCJRuPyBLQ -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%BFX-Mocha%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP24
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP24
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE24
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP24
)
:CONTINUE24
del ".\Installer-files\%BFX-Mocha%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha*") do if exist "%%~I\INSTALL.cmd" GOTO auto-24
GOTO SelectPlugins

:auto-24
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-24
IF ERRORLEVEL 1  GOTO autoinst-24
echo.
:manual-24
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-24
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\Boris FX Mocha*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 5
:25
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\Boris FX Silho*" GOTO alrDown-25
echo Plugin isn't downloaded, continuing to download
GOTO down-25
:alrDown-25
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-25
echo.
:down-25
cls
echo Initializing Download...
:: gdown command
gdown --folder 18GUz5M02QdInmQlQj8o-ky-HB7A0Dba4 -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%BFX-Silhouette%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP25
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP25
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE25
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP25
)
:CONTINUE25
del ".\Installer-files\%BFX-Silhouette%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do if exist "%%~I\INSTALL.cmd" GOTO auto-25
GOTO SelectPlugins

:auto-25
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-25
IF ERRORLEVEL 1  GOTO autoinst-25
echo.
:manual-25
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-25
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\Boris FX Silho*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 6
:26
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\FXHOME Ign*" GOTO alrDown-26
echo Plugin isn't downloaded, continuing to download
GOTO down-26
:alrDown-26
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-26
echo.
:down-26
cls
echo Initializing Download...
:: gdown command
gdown --folder 1RTzgwdYPiaTCjGosGJzY1w7LUPsvI_Gt -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%FXH-Ignite%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP26
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP26
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE26
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP26
)
:CONTINUE26
del ".\Installer-files\%FXH-Ignite%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do if exist "%%~I\INSTALL.cmd" GOTO auto-26
GOTO SelectPlugins

:auto-26
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-26
IF ERRORLEVEL 1  GOTO autoinst-26
echo.
:manual-26
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-26
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\FXHOME Ign*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Option 7
:27
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\MAXON Red Giant Magic Bull*" GOTO alrDown-27
echo Plugin isn't downloaded, continuing to download
GOTO down-27
:alrDown-27
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins
IF ERRORLEVEL 1  GOTO down-27
echo.
:down-27
cls
echo Initializing Download...
:: gdown command
gdown --folder 1Khgki2-aJkTfMZx-9Sqn-ejbxhHDQZ4x -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%MXN-MBL%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP27
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP27
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE27
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP27
)
:CONTINUE27
del ".\Installer-files\%MXN-MBL%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do if exist "%%~I\INSTALL.cmd" GOTO auto-27
GOTO SelectPlugins

:auto-27
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-27
IF ERRORLEVEL 1  GOTO autoinst-27
echo.
:manual-27
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins
:autoinst-27
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Magic Bull*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 1
:221
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\MAXON Red Giant Uni*" GOTO alrDown-221
echo Plugin isn't downloaded, continuing to download
GOTO down-221
:alrDown-221
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-221
echo.
:down-221
cls
echo Initializing Download...
:: gdown command
gdown --folder 1yhBAYDwoQ4XB9mbjno4hWLsC49hqmx9c -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%MXN-Universe%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP221
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP221
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE221
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP221
)
:CONTINUE221
del ".\Installer-files\%MXN-Universe%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do if exist "%%~I\INSTALL.cmd" GOTO auto-221
GOTO SelectPlugins2

:auto-221
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-221
IF ERRORLEVEL 1  GOTO autoinst-221
echo.
:manual-221
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-221
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\MAXON Red Giant Uni*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 2
:222
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\NewBlueFX Titler*" GOTO alrDown-222
echo Plugin isn't downloaded, continuing to download
GOTO down-222
:alrDown-222
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-222
echo.
:down-222
cls
echo Initializing Download...
:: gdown command
gdown --folder 1rFWk-RHqOLEel5rb_MUL4Xe9QUiy9HEb -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%NFX-Titler%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP222
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP222
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE222
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP222
)
:CONTINUE222
del ".\Installer-files\%NFX-Titler%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do if exist "%%~I\INSTALL.cmd" GOTO auto-222
GOTO SelectPlugins2

:auto-222
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-222
IF ERRORLEVEL 1  GOTO autoinst-222
echo.
:manual-222
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-222
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Titler*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2


:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 3
:223
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\NewBlueFX Total*" GOTO alrDown-223
echo Plugin isn't downloaded, continuing to download
GOTO down-223
:alrDown-223
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-223
echo.
:down-223
cls
echo Initializing Download...
:: gdown command
gdown --folder 1W-T_Yqra8kwOO_ZDmKJxCTKukmGwrQ1i -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
%winrar% x -o+ ".\Installer-files\%NFX-TotalFX%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP223
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP223
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE223
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP223
)
:CONTINUE223
del ".\Installer-files\%NFX-TotalFX%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do if exist "%%~I\INSTALL.cmd" GOTO auto-223
GOTO SelectPlugins2

:auto-223
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-223
IF ERRORLEVEL 1  GOTO autoinst-223
echo.
:manual-223
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-223
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\NewBlueFX Total*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2

:::::::::::::::::::::::::::::::::::::::
:: Download & Extract Page 2 Option 4
:224
cls
Echo.
:: Check if plugin is already downloaded
echo Checking if plugin is already downloaded
if exist ".\Installer-files\Plugins\REVisionFX Eff*" GOTO alrDown-224
echo Plugin isn't downloaded, continuing to download
GOTO down-224
:alrDown-224
cls
echo Plugin is already downloaded
echo Do you want to download it again?
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO SelectPlugins2
IF ERRORLEVEL 1  GOTO down-224
echo.
:down-224
cls
echo Initializing Download...
:: gdown command
gdown --folder 1dLsCdncK5u9SpvT-zOCd6S4Pr1oIUC-f -O ".\Installer-files"
color 0C
echo Download Finished!
echo Renaming rar file
REN ".\Installer-files\Boris FX Sapph*" "%BFX-Sapphire%" 2>nul
REN ".\Installer-files\Boris FX Cont*" "%BFX-Continuum%" 2>nul
REN ".\Installer-files\Boris FX Mocha*" "%BFX-Mocha%" 2>nul
REN ".\Installer-files\Boris FX Silho*" "%BFX-Silhouette%" 2>nul
REN ".\Installer-files\FXHOME Ign*" "%FXH-Ignite%" 2>nul
REN ".\Installer-files\MAXON Red Giant Magic Bull*" "%MXN-MBL%" 2>nul
REN ".\Installer-files\MAXON Red Giant Uni*" "%MXN-Universe%" 2>nul
REN ".\Installer-files\NewBlueFX Titler*" "%NFX-Titler%" 2>nul
REN ".\Installer-files\NewBlueFX Total*" "%NFX-TotalFX%" 2>nul
REN ".\Installer-files\REVisionFX Eff*" "%RFX-Effections%" 2>nul
:: Closes all instances of WinRAR, so any already opened instances wont mess up the script
echo Closing all instances of WinRAR
@echo OFF
taskkill /f /im WinRAR.exe 2>nul
echo Extracting zipped File
:: Creates directory for Plugins, if not already made
if not exist ".\Installer-files\Plugins" mkdir ".\Installer-files\Plugins" 
echo Initializing extraction
%winrar% x -o+ ".\Installer-files\%RFX-Effections%" ".\Installer-files\Plugins"
timeout /T 6 /nobreak >nul
GOTO LOOP224
:: Checks for when WinRAR closes, then deletes the old rar file after it's been extracted
:LOOP224
tasklist | find /i "WinRAR" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE224
) ELSE (
  ECHO WinRAR is still running
  Timeout /T 5 /Nobreak >nul
  GOTO LOOP224
)
:CONTINUE224
del ".\Installer-files\%RFX-Effections%"
echo.
echo Finished, Extracted to "\Installer-files\Plugins"
Timeout /T 5 /Nobreak >nul
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do if exist "%%~I\INSTALL.cmd" GOTO auto-224
GOTO SelectPlugins2

:auto-224
cls
echo There is an auto installer script for this plugin.
echo How do you want to install the plugin?
echo 1 = Auto Install
echo 2 = Manual Install
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO manual-224
IF ERRORLEVEL 1  GOTO autoinst-224
echo.
:manual-224
cls
echo For manual installation, please open this directory
echo Installer-files > Plugins > (Plugin Name)
echo and follow the instructions in the text file.
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2
:autoinst-224
cls
echo Launching auto install script...
for /D %%I in (".\Installer-files\Plugins\REVisionFX Eff*") do start "" cmd /c "%%~I\INSTALL.cmd"
Timeout /T 5 /Nobreak >nul
GOTO SelectPlugins2


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:3
cls
echo Are you sure you want to clean all files from the installer?
echo This will remove all downloaded files, but will not uninstall Vegas Pro or any Plugin.
echo 1 = Yes
echo 2 = No
echo.
C:\Windows\System32\CHOICE /C 12 /M "Type the number (1-2) of what you want." /N
cls
echo.
IF ERRORLEVEL 2  GOTO Main
IF ERRORLEVEL 1  GOTO clean-14
echo.
:clean-14
cls
color 0C
echo Cleaning up Vegas Pro files
forfiles /P ".\Installer-files" /M Vegas* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
echo Cleaning up Plugin files
forfiles /P ".\Installer-files" /M Plugins* /C "cmd /c if @isdir==TRUE rmdir /s /q @file" 2>nul
echo Cleaning up extra files
del ".\Installer-files\*.rar" 2>nul
del ".\Installer-files\*.zip" 2>nul
echo Finished cleaning up all installer Files
timeout /T 3 /nobreak >nul
GOTO Main

:Quit
cls
echo Quitting Nifer's Vegas Pro Install Script
echo Twitter - @NiferEdits
Timeout /T 3 /Nobreak >nul
@exit