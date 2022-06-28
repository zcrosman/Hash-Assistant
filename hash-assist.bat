@echo off
Setlocal EnableDelayedExpansion
:: Update paths as needed
set hc=C:\Users\%username%\Downloads\hashcat\hashcat-6.2.5
set wireshark=C:\Program Files\Wireshark
set pcaps=C:\Users\%username%\Documents\pcaps


:menu
cls
echo        Hashcat Session Manager Menu
echo .........................................
echo 1 - Load a session
echo 2 - Continue a session 
echo 3 - Hashcat automation scripts 
echo 4 - View configurations
echo.


SET /P M=Type 1 - 4 then press ENTER: 
IF %M%==1 GOTO select_restore
IF %M%==2 GOTO continue_crack
IF %M%==3 GOTO automation_menu
IF %M%==4 GOTO view_configs

cls
echo That is not a valid option!
echo Choose an option between 1-4
echo.
pause

GOTO menu

:automation_menu
cls
echo        Hashcat Automation Tools
echo -----------------------------------------
echo.
echo.
echo Wifi Related (WPA-PBKDF2-PMKID+EAPOL)
echo -----------------------------------------
echo    1 - (Step 1) Combine pcap files
echo    2 - (Step 2) hcxpcapngtool (create file)
echo.
echo Other
echo -----------------------------------------
echo    3 - Install hcxpcapngtool (requires WSL)
echo    4 - Return to main menu
echo.
SET /P M=Type 1 - 4 then press ENTER: 
IF %M%==1 GOTO combine_format
IF %M%==2 GOTO hcxpcapngtool
IF %M%==3 GOTO install_hcx
IF %M%==4 GOTO menu



:hcxpcapngtool
cd %pcaps%
SET /P hash=What should the wifi hash be saved as:  
echo Saving hashcat compatible hash:
echo Windows path: %hc%\%hash%

set lin_hc=\mnt\%hc%\%hash%
set lin_hc=%lin_hc:\=/%
set lin_hc=%lin_hc::=%
::TODO find better solution for drive letter in WSL
set lin_hc=%lin_hc:C=c%     



set lin_pc=\mnt\%pcaps%\combined.pcap
set lin_pc=%lin_pc:\=/%
set lin_pc=%lin_pc::=%
::TODO find better solution for drive letter in WSL
set lin_pc=%lin_pc:C=c%  


@echo on
wsl hcxpcapngtool -o %lin_hc% -E essid.txt %lin_pc%
@echo off
pause
GOTO automation_menu



:install_hcx
wsl apt update
wsl apt install -y hcxtools
echo.
echo.
echo Confirm hcxtools was installed correclty
echo.
echo.
pause
GOTO automation_menu


:view_configs
cls
@REM I would like to add more to this
echo Update directories if needed
echo ----------------------------
echo Wireshark:          %wireshark%
echo Hashcat directory:  %hc%
echo pcap files:         %pcaps%
echo.
echo.
pause
GOTO menu



:combine_format
cd %wireshark%
cls
echo This will overwrite the file "combined.pcap" in the pcap direcotry
echo Please rename the original combined.pcap file if it exists
echo.
echo Merging pcap files in the directory below
echo ------------------------------------------
echo %pcaps%
pause
echo.
echo.
mergecap.exe -w %pcaps%\combined.pcap %pcaps%\*.pcap
echo.
echo.
pause
GOTO automation_menu


:continue_crack
IF [!session!] == [] ( 
    echo No session set!
    echo Continue to the main menu and select a saved session
    echo.
    pause
    GOTO menu
) else (
cls
echo Continuing Hashcat session from the restore file below:
cd C:\Users\Z\Downloads\hashcat\hashcat-6.2.5
echo Session Name: !session!
echo Restore file: !restore!
echo Folder Path:  !folder!
echo File Name:    !name!

cd %hc%
@REM This script assumes that restore files are saved in the same dir as hashcat.exe
@echo on
%hc%\hashcat.exe --session %session% --restore
@echo off
pause
)
GOTO menu

:select_restore
cls
echo Choose a resore session
echo -----------------------
set /a count = 0
for /f %%A in ('dir /b /s %hc%\*.restore') do (
    set /a count += 1
    set file=%%A
    Set folder=%%~dpA
    Set name=%%~nxA
    Set session=!name:~0,-8!
    echo !count! - Session Name: !session!
    echo     File Name:    !name!
    echo     Folder Path:  !folder:~0,-1!
    echo.
)
echo.
SET /P W=Select resore session 1-!count!: 


set /a count = 1
for /f %%z in ('dir /b /s %hc%\*.restore') do (
	if "!count!" == "%W%" (
        echo.
        set restore=%%z
        GOTO show_save
	)
	set /a count += 1
)

@REM this is still part of the find retore function
:show_save
For %%A in ("%restore%") do (
    Set folder=%%~dpA
    Set name=%%~nxA
    Set session=!name:~0,-8!
    cls
    echo     Selected Session
    echo ------------------------
    echo Session Name: !session!
    echo File Name:    !name!
    echo Folder Path:  !folder:~0,-1!
    echo.
)
pause
GOTO continue_crack

