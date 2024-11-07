
chcp 65001
@echo off

REM Set the port number same as your mobile end's FTP/HTTP server, e.g., 2121 or 2221
set port=9999
set http_port=8080

REM Variable for user confirmations
set store=""

echo:
echo 1. Check if you're only connected to a hotspot network. Nothing will be displayed of not connected; press Ctrl+C to exit
echo:
echo 2. Confirm your keyboard/input method has switched back to ENG, otherwise you won't be able to input y/n
echo:

netsh wlan show interface | findstr /C:"Description" /C:"SSID" /C:"Radio" /C:"Transmit" /C:"Receive" /C:"Signal" /C:"State"
echo:
echo Windows needs 30 seconds to complete configuration upon connecting to a new WiFi or hotspot, please wait and then continue manually
pause
echo:

setlocal enabledelayedexpansion
REM Find all IPv4 addresses with Default Gateway in the ipconfig output, and extract the IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Default Gateway"') do (
    REM Extract the Default Gateway IP address
    set ip=%%a

    REM Remove any leading spaces from the IP address
    set ip=!ip:~1!

    REM Split the IP address into four octets
    for /f "tokens=1-4 delims=." %%b in ("!ip!") do (
        set _o1=%%b
        set _o2=%%c
        set _o3=%%d
        set _o4=%%e
    )

    REM User confirmation whether one of the IP should be the FTP/HTTP server's address
    set /p "store=?. Is '!_o1!.!_o2!.!_o3!.!_o4!' your FTP/HTTP server's address (y/n): "
    if /i "!store!"=="y" (
        REM Store IP address to variable
        set "stored_ips=!_o1!.!_o2!.!_o3!.!_o4!"
        REM Leave loop
        goto :EndLoopI
    )
)
:EndLoopI

REM Exit the loop if the IP address is confirmed
if "%stored_ips%"=="" (
    echo:
    echo No FTP address available or no y input to confirm, press any key to exit
    pause
    goto :End
)

echo:
echo 2. Get the name of the wireless hotspot network (SSID), so that the network type can be changed from public to private
REM 

echo:

REM 2. The network type must be private, otherwise file transfer will not work
REM Variable to store WLAN SSID
set "wlan_ssid="

REM List all connected wireless networks, user selects correct SSID
for /f "tokens=1,* delims=:" %%A in ('netsh wlan show interfaces ^| findstr "\<SSID\>"') do (
    REM Extract SSID name
    set wlan_ssid=%%B

    REM Remove any leading spaces from the SSID
    set wlan_ssid=!wlan_ssid:~1!

    set /p "store=?. Is the wireless hotspot's SSID: !wlan_ssid! (y/n): "
    if /i "!store!"=="y" (
        REM Leave loop
        goto :EndLoopII
    )
)
:EndLoopII

REM Exit if no SSID available
if "!wlan_ssid!"=="" (
    echo:
    echo No SSID available or no y input to confirm, press any key to exit
    pause
    goto :End
)

REM Export SSID to current path
echo!wlan_ssid! > %~dp0\temp_wlan_ssid.txt

REM Send SSID to PowerShell script to change network type to private
start /wait powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\Windows-NetworkProfileToPrivate-EN.ps1"
echo?. This script will display an error message, ignore it
timeout /t 1
del %~dp0\temp_wlan_ssid.txt

REM 3. User chooses the file transfer protocol type. FTP is fastest but least secure, SFTP/FTPes speed limited by openSSL

echo:
echo Current FTP server port number configured as %port%, HTTP server port number configured as %http_port%
:prompt
set /p "pr=Which file server protocol to use [1: FTP/FTPes | 2: SFTP | 3: HTTP]？: "

REM Limit user input content to 1-3
if "%pr%"=="1" (
    echo:
    echo...Selected FTP/FTPes file server
) else if "%pr%"=="2" (
    echo:
    echo...Selected SFTP file server
) else if "%pr%"=="3" (
    echo:
    echo...Selected HTTP file server
) else (
    echo Invalid input, try again
    goto prompt
)

echo:
echo Please check if the FTP server is running before continuing.

REM 4. Get the full address based on the user-selected protocol
if %pr%==1 set "proto=ftp://"
if %pr%==2 set "proto=sftp://" 
if %pr%==3 set "proto=http://"
if %pr%==3 set "port=%http_port%"
echo:

set /p "store=Confirm opening FTP/HTTP server address: %proto%%stored_ips%:%port% (y/n): "
if /i %store%==y (
    echo 4. Creating network location: My Computer/This PC\\!wlan_ssid!
    echo    Since each time you open a mobile hotspot, the phone's network address changes, delete the network address!wlan_ssid! after use.
    echo %~dp0Windows-CreateNetworkLocation.vbs "!wlan_ssid!" "%proto%%stored_ips%:%port%"
    cscript //nologo %~dp0\Windows-CreateNetworkLocation.vbs "!wlan_ssid!" "%proto%%stored_ips%:%port%"
    echo:

    echo Opening: %proto%%stored_ips%:%port%
    start %SystemRoot%\\explorer.exe "%proto%%stored_ips%:%port%"
    echo:
    echo 5. If the file names have special characters, transferring them to the FTP server may cause error 501
    echo    Place files with special characters in a folder or transfer the folder containing them to the FTP server
    echo:
    echo 6. After transferring files, disconnect the WLAN first and then shut down other services
    echo    Since each time you open a mobile hotspot, the phone's network address changes, delete the network address!wlan_ssid! after use.
)

echo:
echo Explorer window for FTP will eventually open automatically，please wait for 50~90 second.
echo:
echo 1 extra step to be done after file transfer completes, please complete transfer and then press Enter to continue...
pause

REM 5. Deleting current WiFi Profile
echo Deleting WiFi profile for current SSID, this prevents a long delay to open FTP explorer window next time
netsh wlan delete profile name="!wlan_ssid!"

echo:
echo If you have any other WiFi Hotspot logged below, you will suffer the same long delay when opening any FTP explorer program window. You can delete these profiles with: netsh wlan delete profile name="SSID-Name"
netsh wlan show profiles
pause

:End