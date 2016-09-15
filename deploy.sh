#!/bin/bash


# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )

DARWIN_X64="darwin-x64"
LINUX_X64="linux-x64"
LINUX_IA32="linux-ia32"
WIN32_IA32="win32-ia32"
WIN32_X64="win32-x64"

ALLPLATFORMS=($DARWIN_X64 $LINUX_X64 $LINUX_IA32 $WIN32_IA32 $WIN32_X64)
PLATFORMS=()

if [[ $# -eq 0 ]]; then
  PLATFORMS=${ALLPLATFORMS[*]}
else
  while [[ $# -gt 0 ]]
  do
    key="$1"

    case $key in
      --darwin-x64)
        PLATFORMS=("${PLATFORMS[@]}" $DARWIN_X64)
        ;;
      --linux-x64)
        PLATFORMS=("${PLATFORMS[@]}" $LINUX_X64)
        ;;
      --linux-ia32)
        PLATFORMS=("${PLATFORMS[@]}" $LINUX_IA32)
        ;;
      --win32-x64)
        PLATFORMS=("${PLATFORMS[@]}" $WIN32_X64)
        ;;
      --win32-ia32)
        PLATFORMS=("${PLATFORMS[@]}" $WIN32_IA32)
        ;;
      --all)
        PLATFORMS=${ALLPLATFORMS[*]}
        break
        ;;
      -h|--help|--usage)
        echo "Usage: bash deploy.sh [platforms]"
        echo "  platforms:"
        echo "    --all : all platforms, equivalent to no argument"
        echo "    --darwin-x64 : Mac OSX 64 bits"
        echo "    --win32-x64 : Windows 64 bits"
        echo "    --win32-ia32 : Windows 32 bits"
        echo "    --linux-x64 : Linux 64 bits"
        echo "    --linux-ia32 : Linux 32 bits"
        echo ""
        echo "  --help or -h or --usage : show this help"
        exit
        ;;
      *)
        # unknown option
        echo "unknown: $key"
        exit
        ;;
    esac
    shift # past argument or value
  done
fi
#
for dep in curl unzip sed; do
  echo "checking dependency... $dep"
  test ! $(which $dep) && echo "ERROR: missing $dep" && exit 1
done

ELECTRON_VERSION=$(npm list --depth=0 |grep electron-prebuilt | cut -f2 -d@)
VERSION=$(node -e "console.log(require('./package').version)")
PLATFORMS=("linux-x64")

mkdir -p dist
cd dist
for PLATFORM in ${PLATFORMS[*]}; do
  rm -rf $PLATFORM
  echo "https://github.com/atom/electron/releases/download/v$ELECTRON_VERSION/electron-v$ELECTRON_VERSION-$PLATFORM.zip"
  test ! -f electron-v$ELECTRON_VERSION-$PLATFORM.zip && \
    curl -LO https://github.com/atom/electron/releases/download/v$ELECTRON_VERSION/electron-v$ELECTRON_VERSION-$PLATFORM.zip
  unzip -o electron-v$ELECTRON_VERSION-$PLATFORM.zip -d $PLATFORM
done


cd linux-x64
mv electron yakyak
cp -R ../../app resources/app
cd ..
zip -r yakyak-linux-x64.zip linux-x64
# ditto -c -k --rsrc --extattr --keepParent linux-x64 yakyak-linux-x64.zip
cd ..
