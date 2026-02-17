#!/bin/bash

# Configuration
APP_NAME="sistem_antrean_satker"
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //; s/+.*//')
MAINTAINER="ma-sum <masum@example.com>"
DESCRIPTION="Sistem Antrean Satker application"

# Paths
BUILD_DIR="build/linux/x64/release/bundle"
DIST_DIR="dist/linux"
DEB_DIR="$DIST_DIR/$APP_NAME-$VERSION-linux-x64"

echo "Packaging Linux version $VERSION..."

# Clean and create directories
rm -rf "$DIST_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/lib/$APP_NAME"
mkdir -p "$DEB_DIR/usr/share/applications"

# Copy build files
cp -r "$BUILD_DIR/"* "$DEB_DIR/usr/lib/$APP_NAME/"

# Create executable link
cat <<EOF > "$DEB_DIR/usr/bin/$APP_NAME"
#!/bin/bash
/usr/lib/$APP_NAME/$APP_NAME "\$@"
EOF
chmod +x "$DEB_DIR/usr/bin/$APP_NAME"

# Create .desktop file
cat <<EOF > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop"
[Desktop Entry]
Name=Sistem Antrean Satker
Exec=$APP_NAME
Icon=$APP_NAME
Type=Application
Categories=Utility;
EOF

# Create control file
cat <<EOF > "$DEB_DIR/DEBIAN/control"
Package: $APP_NAME
Version: $VERSION
Architecture: amd64
Maintainer: $MAINTAINER
Description: $DESCRIPTION
Depends: libgtk-3-0, libglib2.0-0
EOF

# Build package
dpkg-deb --build "$DEB_DIR"

# Move to dist/linux and rename
mv "$DIST_DIR/$APP_NAME-$VERSION-linux-x64.deb" "$DIST_DIR/$APP_NAME.deb"

echo "Linux package created at $DIST_DIR/$APP_NAME.deb"
