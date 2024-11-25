#!/bin/bash


CURRENT_DIR=$1
APPIMAGE_LOCATION=$2
ICON_LOCATION=$3
PACKAGE_NAME=$4
SOFTWARE_NAME=$5
VERSION=$6
DEVELOPER=$7
DEVELOPER_MAIL=$8
MAINTAINER=$9
MAINTAINER_MAIL=${10}
CATEGORY=${11}
SIMPLE_DESCRIPTION=${12}
DETAILED_DESCRIPTION=${13}
HOMEPAGE=${14}
PERMISSION_BITS=${15}


echo -e "\nLoading Information..."
echo ${CURRENT_DIR}
echo ${APPIMAGE_LOCATION}
echo ${ICON_LOCATION}
echo ${PACKAGE_NAME}
echo ${SOFTWARE_NAME}
echo ${VERSION}
echo ${DEVELOPER}
echo ${DEVELOPER_MAIL}
echo ${MAINTAINER}
echo ${MAINTAINER_MAIL}
echo ${CATEGORY}
echo ${SIMPLE_DESCRIPTION}
echo ${DETAILED_DESCRIPTION}
echo ${HOMEPAGE}
echo ${PERMISSION_BITS} && echo "Finish!"


echo -e "\nCreate Directories..."
PACKAGE_DIR=${CURRENT_DIR}/.appimage2deb_tmp/${PACKAGE_NAME}
APP_DIR=${PACKAGE_DIR}/opt/apps/${PACKAGE_NAME}
mkdir -p ${PACKAGE_DIR}
mkdir ${PACKAGE_DIR}/DEBIAN
mkdir -p ${APP_DIR}/entries/applications
if [ "${ICON_LOCATION##*.}" == "svg" ]; then
    mkdir -p ${APP_DIR}/entries/icons/hicolor/scalable/apps
else
    mkdir -p ${APP_DIR}/entries/icons/hicolor/512x512/apps
fi
mkdir -p ${APP_DIR}/files/bin && echo "Finish!"


echo -e "\nCreate info file..."
touch ${APP_DIR}/info
echo -e "{" > ${APP_DIR}/info
echo -e "\t\"appid\": \"${PACKAGE_NAME}\"," >> ${APP_DIR}/info
echo -e "\t\"name\": \"${SOFTWARE_NAME}\"," >> ${APP_DIR}/info
echo -e "\t\"version\": \"${VERSION}\"," >> ${APP_DIR}/info
echo -e "\t\"arch\": [\"amd64\"]," >> ${APP_DIR}/info
echo -e "\t\"permissions\": {" >> ${APP_DIR}/info
if [ "${PERMISSION_BITS:0:1}" == "1" ];then
    echo -e "\t\t\"autostart\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"autostart\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:1:1}" == "1" ];then
    echo -e "\t\t\"notification\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"notification\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:2:1}" == "1" ];then
    echo -e "\t\t\"trayicon\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"trayicon\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:3:1}" == "1" ];then
    echo -e "\t\t\"clipboard\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"clipboard\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:4:1}" == "1" ];then
    echo -e "\t\t\"account\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"account\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:5:1}" == "1" ];then
    echo -e "\t\t\"bluetooth\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"bluetooth\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:6:1}" == "1" ];then
    echo -e "\t\t\"camera\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"camera\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:7:1}" == "1" ];then
    echo -e "\t\t\"audio_record\": true," >> ${APP_DIR}/info
else
    echo -e "\t\t\"audio_record\": false," >> ${APP_DIR}/info
fi
if [ "${PERMISSION_BITS:8:1}" == "1" ];then
    echo -e "\t\t\"installed_apps\": true" >> ${APP_DIR}/info
else
    echo -e "\t\t\"installed_apps\": false" >> ${APP_DIR}/info
fi
echo -e "\t}" >> ${APP_DIR}/info
echo "}">> ${APP_DIR}/info && echo "Finish!"


echo -e "\nCreate desktop file..."
touch ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "[Desktop Entry]" > ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Type=Application" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Version=1.0" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Name=${SOFTWARE_NAME}" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Comment=${SIMPLE_DESCRIPTION}" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Exec=/opt/apps/${PACKAGE_NAME}/files/bin/${PACKAGE_NAME}" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Icon=${PACKAGE_NAME}" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Categories=${CATEGORY};" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "Terminal=false" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop
echo "StartupNotify=true" >> ${APP_DIR}/entries/applications/${PACKAGE_NAME}.desktop && echo "Finish!"


echo -e "\nMove Appimage..."
cp ${APPIMAGE_LOCATION} ${APP_DIR}/files/bin
mv ${APP_DIR}/files/bin/*.AppImage ${APP_DIR}/files/bin/${PACKAGE_NAME} && echo "Finish!"


echo -e "\nMove Icon..."
if [ "${ICON_LOCATION##*.}" == "svg" ]; then
    cp ${ICON_LOCATION} ${APP_DIR}/entries/icons/hicolor/scalable/apps
    mv ${APP_DIR}/entries/icons/hicolor/scalable/apps/*.svg ${APP_DIR}/entries/icons/hicolor/scalable/apps/${PACKAGE_NAME}.svg 
else
    cp ${ICON_LOCATION} ${APP_DIR}/entries/icons/hicolor/512x512/apps
    mv ${APP_DIR}/entries/icons/hicolor/512x512/apps/*.png ${APP_DIR}/entries/icons/hicolor/512x512/apps/${PACKAGE_NAME}.png
fi && echo "Finish!"


echo -e "\nCreate control..."
touch ${PACKAGE_DIR}/DEBIAN/control
echo "Package: ${PACKAGE_NAME}" > ${PACKAGE_DIR}/DEBIAN/control
echo "Version: ${VERSION}" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Section: utils" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Homepage: ${HOMEPAGE}" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Architecture: amd64" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Priority: optional" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Depends: fuse3" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Maintainer: ${MAINTAINER} <${MAINTAINER_MAIL}>" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Developer: ${DEVELOPER} <$DEVELOPER_MAIL>" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Installed-Size: $(du -sk ${PACKAGE_DIR}/opt/apps/${PACKAGE_NAME} | cut -f1)" >> ${PACKAGE_DIR}/DEBIAN/control
echo "Description: ${SIMPLE_DESCRIPTION}" >> ${PACKAGE_DIR}/DEBIAN/control
echo " ${DETAILED_DESCRIPTION}" >> ${PACKAGE_DIR}/DEBIAN/control && echo "Finish!"


echo -e "\nCreate postinst..."
touch ${PACKAGE_DIR}/DEBIAN/postinst
echo "#!/bin/bash" > ${PACKAGE_DIR}/DEBIAN/postinst
if [ "${ICON_LOCATION##*.}" == "svg" ]; then
    echo "ln -s /opt/apps/${PACKAGE_NAME}/entries/icons/hicolor/scalable/apps/${PACKAGE_NAME}.svg /usr/share/icons/hicolor/scalable/apps/${PACKAGE_NAME}.svg" >> ${PACKAGE_DIR}/DEBIAN/postinst
else
    echo "ln -s /opt/apps/${PACKAGE_NAME}/entries/icons/hicolor/512x512/apps/${PACKAGE_NAME}.png /usr/share/icons/hicolor/512x512/apps/${PACKAGE_NAME}.png" >> ${PACKAGE_DIR}/DEBIAN/postinst
fi
echo "chmod 777 /opt/apps/${PACKAGE_NAME}/files/bin/${PACKAGE_NAME}" >> ${PACKAGE_DIR}/DEBIAN/postinst
echo "chmod 777 /opt/apps/${PACKAGE_NAME}/entries/applications/${PACKAGE_NAME}.desktop" >> ${PACKAGE_DIR}/DEBIAN/postinst && echo "Finish!"


echo -e "\nCreate postrm..."
touch ${PACKAGE_DIR}/DEBIAN/postrm
echo "#!/bin/bash" > ${PACKAGE_DIR}/DEBIAN/postrm
echo "if [ -e "/usr/share/icons/hicolor/scalable/apps/${PACKAGE_NAME}.svg" ]; then" >> ${PACKAGE_DIR}/DEBIAN/postrm
echo "  rm /usr/share/icons/hicolor/scalable/apps/${PACKAGE_NAME}.svg" >> ${PACKAGE_DIR}/DEBIAN/postrm
echo "fi" >> ${PACKAGE_DIR}/DEBIAN/postrm
echo "if [ -e "/usr/share/icons/hicolor/512x512/apps/${PACKAGE_NAME}.png" ]; then" >> ${PACKAGE_DIR}/DEBIAN/postrm
echo "  rm /usr/share/icons/hicolor/512x512/apps/${PACKAGE_NAME}.png" >> ${PACKAGE_DIR}/DEBIAN/postrm
echo "fi" >> ${PACKAGE_DIR}/DEBIAN/postrm && echo "Finish!"


echo -e "\nEmpower DEBIAN..."
fakeroot chmod 755 ${PACKAGE_DIR}/DEBIAN
fakeroot chmod 644 ${PACKAGE_DIR}/DEBIAN/control
fakeroot chmod 755 ${PACKAGE_DIR}/DEBIAN/postrm
fakeroot chmod 755 ${PACKAGE_DIR}/DEBIAN/postinst && echo "Finish!"


echo -e "\nMake Deb..."
fakeroot dpkg -b ${PACKAGE_DIR} ${CURRENT_DIR} && echo "Finish!" && rm -rf ${CURRENT_DIR}/.appimage2deb_tmp
