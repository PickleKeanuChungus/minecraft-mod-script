@echo off
SETLOCAL EnableDelayedExpansion

:: directory for new build updates
set releaseServer=https://raw.githubusercontent.com/PickleKeanuChungus/minecraft-mod-script/master/builds

:: directory for package updates
set packageServer=https://raw.githubusercontent.com/PickleKeanuChungus/minecraft-mod-script/master/packages

:: current build id for this script (higher number == newer)
set buildid=3

:: download latest build id from server and set it to variable
:: i could probably save it directly to a variable but heck that, i just want to finish this
curl -s -o latest-build-id %releaseServer%/latest-build-id
set /p latestbuildid=<latest-build-id

:: check for update by comparing build ids
if !latestbuildid! gtr !buildid! (

    echo === PickleKeanuChungus's Mod Downloader ===

    :: prompt user if they want to update
    set /p update=There's a new update for PickleKeanuChungus's Mod Downloader. Would you like to update it? ^(Y/n^) 

    if /i not "!update!"=="n" (

        :: download new script files and overwrite the current file
        echo Updating PKC Mod Downloader...
        curl -s -o mod-downloader.bat %releaseServer%/!latestbuildid!/mod-downloader.bat

        :: close the program and let the user relaunch it
        echo PKC Mod Downloader has been updated. Please relaunch this program to finish the update.
        ENDLOCAL
        goto :eof
    )
)

:: download all available package versions
curl -s -o version-list %packageServer%/versions

:: set up package downloader user interface
clear
echo === PickleKeanuChungus's Mod Downloader ===
echo Pick a Minecraft mod package to download:
echo.

:: assign an id to each package
set x=0
for /f %%G in (version-list) DO (
    set prefix=%%G
    set prefix=!prefix:~0,2!
    if /i not "!prefix!"=="--" (
        echo !x!^) %%G
        set package[!x!]=%%G
        set /a x+=1
    )
    
)

echo.
echo Press any other number to exit.
echo.

:: offer a choice to the user for which package to download unless there is only one package
if !x! gtr 0 (
    set /P pchoice=Pick a package to download: 
) else (
    set pchoice=0
)

:: make sure that the package id is a valid option
if not !pchoice!=="" if !pchoice! lss !x! if !pchoice! geq 0 (

    :: download the specified package file
    curl -s -o download-list %packageServer%/!package[%pchoice%]!
    if not exist out-!package[%pchoice%]! (
        mkdir out-!package[%pchoice%]!
    )

    :: download every mod listed in the package file
    :: forgot to update change directory command last version
    cd out-!package[%pchoice%]!
    for /f %%H in (../download-list) DO (
        set prefix=%%H
        set prefix=!prefix:~0,2!
        if /i not "!prefix!"=="--" (
            echo Downloading %%H...
            curl --remote-name --remote-header-name %%H
        )
    
    )
    cd ..
)
ENDLOCAL
