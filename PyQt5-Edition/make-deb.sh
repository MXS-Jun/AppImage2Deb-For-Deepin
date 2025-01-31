#!/bin/bash

WORKING_DIR=$1
APPIMAGE_LOCATION=$2
PACKAGE_NAME=$3
SOFTWARE_NAME=$4
ARCHITECTURE=$5
VERSION=$6
DEVELOPER=$7
DEVELOPER_MAIL=$8
MAINTAINER=$9
MAINTAINER_MAIL=${10}
CATEGORY=${11}
SIMPLE_DESCRIPTION=${12}
DETAILED_DESCRIPTION=${13}
HOMEPAGE=${14}

cp "$APPIMAGE_LOCATION" "$WORKING_DIR"
cd "$WORKING_DIR" || exit

APPIMAGE_NAME="${APPIMAGE_LOCATION##*/}"
fakeroot chmod +x ./"$APPIMAGE_NAME"
./"$APPIMAGE_NAME" --appimage-extract >/dev/null
echo "Extract AppImage Successfully!"

# TODO 有些图像的分辨率不是标准的，这会导致映射出问题

ICON_SIZE=$(identify -format "%w" ./squashfs-root/*.png)
mkdir -p ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/icons/hicolor/"$ICON_SIZE"x"$ICON_SIZE"/apps
cp ./squashfs-root/*.png ./"$PACKAGE_NAME".png
mv ./"$PACKAGE_NAME".png ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/icons/hicolor/"$ICON_SIZE"x"$ICON_SIZE"/apps

mkdir ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/applications
cp ./squashfs-root/*.desktop ./"$PACKAGE_NAME".desktop
mv ./"$PACKAGE_NAME".desktop ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/applications

sed -i "s|^Name=.*|Name=$SOFTWARE_NAME|" \
    ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/applications/"$PACKAGE_NAME".desktop

sed -i "s|^Exec=.*|Exec=/opt/apps/$PACKAGE_NAME/files/AppRun|" \
    ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/applications/"$PACKAGE_NAME".desktop

sed -i "s|^Icon=.*|Icon=/opt/apps/$PACKAGE_NAME/entries/icons/hicolor/${ICON_SIZE}x${ICON_SIZE}/apps/$PACKAGE_NAME|" \
    ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/applications/"$PACKAGE_NAME".desktop

sed -i "s|^Categories=.*|Categories=$CATEGORY;|" \
    ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/entries/applications/"$PACKAGE_NAME".desktop

mkdir ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/files
mv ./squashfs-root/* ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/files
mv ./squashfs-root/.[!.]* ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/files
rmdir ./squashfs-root

touch ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/info
{
    echo "{"
    echo -e "\t\"appid\": \"$PACKAGE_NAME\""
    echo "}"
} >>./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME"/info

mkdir ./"$PACKAGE_NAME"/DEBIAN
touch ./"$PACKAGE_NAME"/DEBIAN/control
touch ./"$PACKAGE_NAME"/DEBIAN/postinst

INSTALLED_SIZE=$(du -sk ./"$PACKAGE_NAME"/opt/apps/"$PACKAGE_NAME" | cut -f1)
{
    echo "Package: ""$PACKAGE_NAME"
    echo "Version: ""$VERSION"
    echo "Architecture: ""$ARCHITECTURE"
    echo "Section: utils"
    echo "Priority: Optional"
    echo "Installed-Size: ""$INSTALLED_SIZE"
    echo "Developer: ""$DEVELOPER"" <""$DEVELOPER_MAIL"">"
    echo "Maintainer: ""$MAINTAINER"" <""$MAINTAINER_MAIL"">"
    echo "Homepage: ""$HOMEPAGE"
    echo "Description: ""$SIMPLE_DESCRIPTION"
    echo " ""$DETAILED_DESCRIPTION"
} >>./"$PACKAGE_NAME"/DEBIAN/control

{
    echo "#!/bin/bash"
    echo "chmod -R 777 /opt/apps/""$PACKAGE_NAME""/*"
    echo "ln -s /opt/apps/$PACKAGE_NAME/entries/icons/hicolor/${ICON_SIZE}x${ICON_SIZE}/apps/$PACKAGE_NAME.png \
    /usr/share/icons/hicolor/${ICON_SIZE}x${ICON_SIZE}/apps/$PACKAGE_NAME.png"
} >>./"$PACKAGE_NAME"/DEBIAN/postinst

fakeroot chmod 755 ./"$PACKAGE_NAME"/DEBIAN
fakeroot chmod 644 ./"$PACKAGE_NAME"/DEBIAN/control
fakeroot chmod 755 ./"$PACKAGE_NAME"/DEBIAN/postinst
echo "Construct Package Successfully!"

fakeroot dpkg -b ./"$PACKAGE_NAME" . >/dev/null && echo "Make deb Successfully"

rm ./"$APPIMAGE_NAME"
rm -rf ./"$PACKAGE_NAME"
