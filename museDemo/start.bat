@echo off
echo --------------------------------------------
echo Welcome to the FEDELE_AI Research Group BCI2V Program.
echo Version: 1.0
echo Build: 2025-23-02 for CEE4803/LMC4813
echo Developed @ Georgia Tech. Go Jackets!
echo --------------------------------------------

REM Searching for Muse devices
muselsl list
echo --------------------------------------------

REM Automatically select the first Muse device and extract its MAC address
for /f "tokens=6" %%a in ('muselsl list ^| findstr /i "Found device"') do (
    set MuseDeviceAddress=%%a
    goto found
)
:found

REM Check if a Muse device was found
if not defined MuseDeviceAddress (
    echo No Muse device found. Exiting...
    exit /b 1
)

echo Found Muse device with MAC address: %MuseDeviceAddress%

REM Start the Muse stream in a new window (non-blocking)
echo Starting Muse stream...
start "Muse Stream" muselsl stream --address %MuseDeviceAddress% -b auto

REM Wait a few seconds to allow the stream to initialize
timeout /t 10

REM Now start demo.py to process the EEG data
echo Starting EEG data acquisition...
python demo.py
