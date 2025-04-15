#!/usr/bin/env bash
set -xe

BUILD_WD=${RDOCKER_BUILD_WD:-$(pwd)}
BUILD_DIR=${RDOCKER_BUILD_DIR:-"build"}
#BUILD_DIR=/tmp/build

VERSION=${1:-`cat VERSION`}
VERSION=${VERSION:-"0.0.0"}

echo "Building RDOCKER package version $VERSION"
echo "Build Working directory: $BUILD_WD"
echo "Build Output directory: $BUILD_DIR"

cd "$BUILD_WD"

# Configuration
NAME="rdocker"
#VERSION="1.0.0"
ARCH="amd64"
MAINTAINER="fm-labs <flowmotionlabs@gmail.com>"
LICENSE="MIT"
URL="https://github.com/fm-labs/rdocker"
DESCRIPTION="Simple, fast, secure and easy to use Docker CLI wrapper for remote Docker hosts"
#BUILD_DIR="build"
INSTALL_PREFIX="/usr/local"

# Make sure fpm,tar,rpm are installed
# ! Important: fpm requires gnu-tar version! busybox tar will not work !
command -v fpm >/dev/null 2>&1 || { echo >&2 "fpm is not installed. Install with: gem install fpm"; exit 1; }
command -v tar >/dev/null 2>&1 || { echo >&2 "tar is not installed. Install with: apt install tar"; exit 1; }
command -v rpmbuild >/dev/null 2>&1 || { echo >&2 "rpmbuild is not installed. Install with: apt install rpm"; exit 1; }

# Clean up
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create .tar.gz
#echo "📦 Building tarball..."
#mkdir -p "$BUILD_DIR/$NAME-$VERSION"
#cp -r bin lib "$BUILD_DIR/$NAME-$VERSION"
#tar czf "$BUILD_DIR/${NAME}-${VERSION}.tar.gz" -C "$BUILD_DIR" "$NAME-$VERSION"


# Package with fpm (DEB & RPM)
FPM_ARGS="--verbose"
#FPM_ARGS=""
for TARGET in tar zip apk deb rpm ; do
    echo "📦 Building $TARGET package..."

    fpm -s dir $FPM_ARGS -t "$TARGET" \
        -n "$NAME" \
        -v "$VERSION" \
        -a "$ARCH" \
        --license "$LICENSE" \
        --maintainer "$MAINTAINER" \
        --url "$URL" \
        --description "$DESCRIPTION" \
        --prefix="$INSTALL_PREFIX" \
        --package "$BUILD_DIR" \
        "bin/rdocker.sh=$INSTALL_PREFIX/bin/rdocker" \
        "lib/=$INSTALL_PREFIX/lib/$NAME/"
done

echo "✅ All packages are in $BUILD_DIR"
ls -la "$BUILD_DIR"
