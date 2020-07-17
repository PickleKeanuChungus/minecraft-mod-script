@echo off
SETLOCAL EnableDelayedExpansion
set releaseServer=https://raw.githubusercontent.com/PickleKeanuChungus/minecraft-mod-script/master/builds
set packageServer=https://raw.githubusercontent.com/PickleKeanuChungus/minecraft-mod-script/master/packages
set buildid=1
curl -s -o latest-build-id %releaseServer%/latest-build-id
set /p latestbuildid=<latest-build-id
if !latestbuildid! gtr !buildid! (
    set /p update=There's a new update for PickleKeanuChungus's Mod Downloader. Would you like to update it? ^(Y/n^) 
    if /i not "!update!"=="n" (
        echo Updating PKC Mod Downloader...
        curl -s -o mod-downloader.bat %releaseServer%/!latestbuildid!/mod-downloader.bat
        :: curl -s -o mod-downloader.sh %releaseServer%/!latestbuildid!/mod-downloader.sh
        echo PKC Mod Downloader has been updated. Please relaunch this program to finish the update.
        ENDLOCAL
        goto :eof
    )
)
curl -s -o version-list %packageServer%/versions
clear
:packagePrompt
echo === PickleKeanuChungus's Mod Downloader ===
echo Pick a Minecraft mod package to download:
echo.
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
if !x! gtr 0 (
    set /P pchoice=Pick a package to download: 
) else (
    set pchoice=0
)
if not !pchoice!=="" if !pchoice! lss !x! if !pchoice! geq 0 (
    curl -s -o download-list %packageServer%/!package[%pchoice%]!
    if not exist out (
        mkdir out
    )
    cd out
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
