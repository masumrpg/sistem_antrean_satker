#!/bin/bash

# Configuration
APP_NAME="etiket"
APP_ID="io.etiket"
BINARY_NAME="e-tiket"
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //; s/+.*//')
MAINTAINER="Ma'sum <mclasix@gmail.com>"
DESCRIPTION="E-Tiket - Pelayanan Terpadu"
ICON_SOURCE="assets/images/logo.png"

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
mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$DEB_DIR/usr/share/metainfo"

# Copy build files
cp -r "$BUILD_DIR/"* "$DEB_DIR/usr/lib/$APP_NAME/"

# Copy icon with APPLICATION_ID name
cp "$ICON_SOURCE" "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/$APP_ID.png"

# Create executable link
cat <<EOF > "$DEB_DIR/usr/bin/$APP_NAME"
#!/bin/bash
/usr/lib/$APP_NAME/$BINARY_NAME "\$@"
EOF
chmod +x "$DEB_DIR/usr/bin/$APP_NAME"

# Create .desktop fileID.desktop"
[Desktop Entry]
Name=E-Tiket
Comment=Sistem Pelayanan Terpadu
Exec=$APP_NAME %U
Icon=$APP_ID
Type=Application
Categories=Utility;Office;
Terminal=false
EOF

# Create metainfo file
cat <<EOF > "$DEB_DIR/usr/share/metainfo/$APP_ID.metainfo.xml"
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>$APP_ID</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>GPL-3.0+</project_license>
  <name>E-Tiket</name>
  <summary>Sistem Pelayanan Terpadu - E-Tiket</summary>
  <description>
    <p>E-Tiket adalah sistem manajemen antrian desktop yang dirancang khusus untuk institusi pemerintah Indonesia.</p>
  </description>
  <icon type="stock">$APP_ID</icon>
</component>lity;
Terminal=false
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
