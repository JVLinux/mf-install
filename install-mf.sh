#!/bin/sh
# VARIABLES
gameid="$1"					# Steam Game ID
scriptdir=$(dirname "$0")			# Script directory
nbparams=$#					# Nb. of parameters

# FUNCTIONS
testParams() {
  [ $1 -ne 1 ] && echo "Type the steam game ID in parameter" && exit 3
}

testPath() {
  [ -z "$WINEPREFIX" ] && WINEPREFIX="${HOME}/.local/share/Steam/steamapps/compatdata/$gameid/pfx"
  [ ! -e "$WINEPREFIX" ] && echo "WINEPREFIX path $WINEPREFIX not found" && exit 2
  [ -z "$WINEPREFIX" ] && echo "WINEPREFIX not set" && exit 1

  set -e
}

overrideDll() {
  wine reg add "HKEY_CURRENT_USER\Software\Wine\DllOverrides" /v $1 /d native /f
}

copyDll() {
  cd "$scriptdir"
  cp -v syswow64/* "$WINEPREFIX/drive_c/windows/syswow64"
  cp -v system32/* "$WINEPREFIX/drive_c/windows/system32"
}

applyOverride() {
  overrideDll "mf"
  overrideDll "mferror"
  overrideDll "mfplat"
  overrideDll "mfreadwrite"
  overrideDll "msmpeg2adec"
  overrideDll "msmpeg2vdec"
  overrideDll "sqmapi"
}

wineRegedit() {
  wine start regedit.exe mf.reg
  wine start regedit.exe wmf.reg
  wine64 start regedit.exe mf.reg
  wine64 start regedit.exe wmf.reg

  wine64 regsvr32 msmpeg2vdec.dll
  wine64 regsvr32 msmpeg2adec.dll

  wine regsvr32 msmpeg2vdec.dll
  wine regsvr32 msmpeg2adec.dll
}


# START
testParams "$nbparams"
testPath
copyDll
applyOverride
export WINEDEBUG="-all"
wineRegedit
exit 0
