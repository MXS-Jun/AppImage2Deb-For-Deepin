#!/usr/bin/env bash

# 禁用辅助功能支持，减少 zenity 的报错输出
export GTK_A11Y=none

# 读取 AppImage 文件地址
APPIMAGE_FILE=`zenity --file-selection --title="选择 AppImage 文件"`

case $? in
    0)
        echo "[STATUS] APPIMAGE_FILE=${APPIMAGE_FILE}"
        ;;
    1)
        echo "[WARN] 没有选择文件"
        exit 1
        ;;
    -1)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 创建工作目录
APPIMAGE_NAME=`basename "${APPIMAGE_FILE}"`
WORK_DIR=`realpath "./${APPIMAGE_NAME%.*}"`

mkdir "${WORK_DIR}"

case $? in
    0)
        echo "[STATUS] 工作目录创建成功"
        echo "[STATUS] APPIMAGE_NAME=${APPIMAGE_NAME}"
        echo "[STATUS] WORK_DIR=${WORK_DIR}"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 复制 AppImage 到工作目录
cp "${APPIMAGE_FILE}" "${WORK_DIR}"

case $? in
    0)
        echo "[STATUS] 复制 AppImage 到工作目录成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 赋予 AppImage 可执行权限
PASSWORD=`zenity --entry \
--title="输入密码" \
--text="输入 sudo 密码以赋权 AppImage 文件" \
--entry-text "" \
--hide-text`

case $? in
    0)
        echo "[STATUS] PASSWORD=${PASSWORD}"
        ;;
    1)
        echo "[WARN] 取消输入密码"
        exit 1
        ;;
    -1)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

(echo "${PASSWORD}" | sudo -S chmod +x "${WORK_DIR}/${APPIMAGE_NAME}")

case $? in
    0)
        echo "[STATUS] AppImage 可执行权限已经成功赋予"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 进入工作目录
cd "${WORK_DIR}"

case $? in
    0)
        echo "[STATUS] 进入工作目录成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 解压 AppImage
"./${APPIMAGE_NAME}" --appimage-extract > /dev/null

case $? in
    0)
        echo "[STATUS] AppImage 解压成功"
        rm "./${APPIMAGE_NAME}"
        echo "[STATUS] 复制到工作目录的 AppImage 删除成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 获取必要的 deb 打包信息
zenity --forms --title="获取必要信息" \
       --text="输入必要的 deb 打包信息" \
       --separator=$'\n' \
       --add-entry="包名" \
       --add-entry="版本" \
       --add-entry="作者" \
       --add-entry="邮箱" > info.txt

case $? in
    0)
        echo "[STATUS] 必要的 deb 打包信息已写入到 info.txt"
        ;;
	1)
        echo "[WARN] 取消输入 deb 打包信息"
        exit 1
        ;;
    -1)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

mapfile -t INFO_LINES < "./info.txt"

for i in "${!INFO_LINES[@]}"; do
    trimmed_line=$(echo "${INFO_LINES[$i]}" | sed 's/^[ \t]*//;s/[ \t]*$//')
    INFO_LINES[$i]="$trimmed_line"
done

case $? in
    0)
        echo "[STATUS] 已读取 info.txt 中存储的信息到 INFO_LINES"
        echo "[STATUS] INFO_LINES="${INFO_LINES[@]}""
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

ID="${INFO_LINES[0]}"
VERSION="${INFO_LINES[1]}"
MAINTAINER="${INFO_LINES[2]}"
MAIL="${INFO_LINES[3]}"

echo "[STATUS] ID=${ID}"
echo "[STATUS] VERSION=${VERSION}"
echo "[STATUS] MAINTAINER=${MAINTAINER}"
echo "[STATUS] MAIL=${MAIL}"

# 构建符合 uos 的 deb 打包标准的目录结构
{
    mkdir "./${ID}/"
    mkdir "./${ID}/DEBIAN/"
    touch "./${ID}/DEBIAN/control"

    mkdir -p "./${ID}/opt/apps/${ID}/entries/applications/"
    mkdir -p "./${ID}/opt/apps/${ID}/entries/icons/hicolor/512x512/apps/"
    mkdir -p "./${ID}/opt/apps/${ID}/entries/icons/hicolor/scalable/apps/"

    mkdir "./${ID}/opt/apps/${ID}/files/"

    touch "./${ID}/opt/apps/${ID}/info"
}

case $? in
    0)
        echo "[STATUS] 符合 uos 的 deb 打包标准的目录结构构建成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 写入 info 文件
echo -e "{\n    \"appid\": \"${ID}\"\n}" > "./${ID}/opt/apps/${ID}/info"

case $? in
    0)
        echo "[STATUS] 写入 info 文件成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 移动 AppImage 解压后的 squashfs-root/ 内容到 bin/
mv "./squashfs-root/" "./${ID}/opt/apps/${ID}/files/"
mv "./${ID}/opt/apps/${ID}/files/squashfs-root/" "./${ID}/opt/apps/${ID}/files/bin/"

case $? in
    0)
        echo "[STATUS] 移动 AppImage 解压后的 squashfs-root/ 内容到 bin/ 成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 创建并写入内容到 start.sh 文件
touch "./${ID}/opt/apps/${ID}/files/start.sh"

{
    printf "#!/usr/bin/env bash\n"
    printf 'if [ -n "$1" ]; then'"\n"
    printf '    file_path="$1"'"\n"
    printf '    file_path="${file_path#file://}"'"\n"
    printf "    /opt/apps/${ID}/files/bin/AppRun "'"${file_path}"'"\n"
    printf "else\n"
    printf "    /opt/apps/${ID}/files/bin/AppRun\n"
    printf "fi\n"
} > "./${ID}/opt/apps/${ID}/files/start.sh"

case $? in
    0)
        echo "[STATUS] 创建并写入内容到 start.sh 文件成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 寻找 .desktop 文件
DESKTOP_FILE="$(find "./${ID}/opt/apps/${ID}/files/bin/" -type f -name "*.desktop" -print -quit)"
DESKTOP_FILE="$(readlink -f "${DESKTOP_FILE}")"

case $? in
    0)
        echo "[STATUS] DESKTOP_FILE=${DESKTOP_FILE}"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 将 .desktop 文件复制到 applications/ 并修改文件名
cp "${DESKTOP_FILE}" "./${ID}/opt/apps/${ID}/entries/applications/${ID}.desktop"

case $? in
    0)
        echo "[STATUS] 成功将 ${DESKTOP_FILE_NAME} 文件复制到 applications/ 并修改文件名为 ${ID}.desktop"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 修改 .desktop 文件的 Exec 字段
sed -i "s#^Exec=.*#Exec=/opt/apps/${ID}/files/start.sh %f#" "./${ID}/opt/apps/${ID}/entries/applications/${ID}.desktop"

case $? in
    0)
        echo "[STATUS] 成功修改 .desktop 文件的 Exec 字段"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 获取 Installed-Size
INSTALLED_SIZE=$(du -sk "./${ID}/opt/apps/${ID}/" | awk '{print $1}')

case $? in
    0)
        echo "[STATUS] INSTALL_SIZE=${INSTALLED_SIZE}"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 获取 icon 文件名
ICON_FIELD=$(grep -iE '^Icon=' "${DESKTOP_FILE}" | cut -d= -f2 | tr -d ' \n\r')
IMAGE_SUFFIXES="svg|png|xpm"
if [[ "${ICON_FIELD}" =~ \.(${IMAGE_SUFFIXES})$ ]]; then
    echo "[STATUS] ICON_FIELD=${ICON_FIELD}"
else
    ICON_FIELD="${ICON_FIELD}.suffix"
    echo "[STATUS] ICON_FIELD=${ICON_FIELD}"
fi
ICON_FILE="$(basename "$ICON_FIELD")"
ICON_NAME="${ICON_FILE%.*}"
echo "[STATUS] ICON_FILE=${ICON_FILE}"
echo "[STATUS] ICON_NAME=${ICON_NAME}"

# 将 icon 文件放到指定位置
SVG_FILE_NAME="${ICON_NAME}.svg"
PNG_FILE_NAME="${ICON_NAME}.png"
SVG_FILE="./${ID}/opt/apps/${ID}/files/bin/${SVG_FILE_NAME}"
PNG_FILE="./${ID}/opt/apps/${ID}/files/bin/${PNG_FILE_NAME}"

if [[ -L "${SVG_FILE}" || -e "${SVG_FILE}" ]]; then
    resolved_svg=$(readlink -f "${SVG_FILE}")
    cp -f "${resolved_svg}" "./${ID}/opt/apps/${ID}/entries/icons/hicolor/scalabel/apps/${ID}.svg"
    echo "[STATUS] SVG 图标已复制到指定位置"
elif [[ -L "${PNG_FILE}" || -e "${PNG_FILE}" ]]; then
    resolved_png=$(readlink -f "${PNG_FILE}")
    ../SR-PNG "${resolved_png}" "./${ID}/opt/apps/${ID}/entries/icons/hicolor/512x512/apps/${ID}.png"
    echo "[STATUS] PNG 图标已超分辨率到 512x512 并复制到指定位置"
else
    echo "[WARN] 没有找到图标文件"
fi

# 修改 .desktop 文件的 Icon 字段
sed -i "s#^Icon=.*#Icon=${ID}#" "./${ID}/opt/apps/${ID}/entries/applications/${ID}.desktop"

case $? in
    0)
        echo "[STATUS] 成功修改 .desktop 文件的 Icon 字段"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 从 .desktop 文件的 comment 获取 description
DESCRIPTION="$(grep '^Comment=' "${DESKTOP_FILE}" | awk -F'=' '{print $2}')"
DESCRIPTION="${DESCRIPTION##*([[:space:]])}"
DESCRIPTION="${DESCRIPTION%%*([[:space:]])}"

case $? in
    0)
        echo "[STATUS] DESCRIPTION=${DESCRIPTION}"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# TODO 从 .desktop 文件的 Categories 解析 section
CATEGORIES="$(grep -Ei '^Categories=' "${DESKTOP_FILE}" | cut -d= -f2 | tr -d ' ')"

case $? in
    0)
        echo "[STATUS] CATEGORIES=${CATEGORIES}"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

map_category_to_section() {
    case "$1" in
        "Development")    echo "devel" ;;
        "Utility")        echo "utils" ;;
        "Game")           echo "games" ;;
        "Education")      echo "edu" ;;
        "Network")        echo "net" ;;
        "Graphics")       echo "graphics" ;;
        "AudioVideo")     echo "sound" ;;
        "Science")        echo "science" ;;
        "Settings")       echo "admin" ;;
        "System")         echo "admin" ;;
        "Office")         echo "text" ;;
        *)                echo "utils" ;;
    esac
}

CATEGORIES=$(echo "${CATEGORIES}" | sed 's/;\+/;/g; s/;$//')
IFS=';' read -ra CATEGORY_ARRAY <<< "${CATEGORIES}"

SECTION=""
for category in "${CATEGORY_ARRAY[@]}"; do
    if [[ -n "${category}" ]]; then
        mapped_section="$(map_category_to_section "${category}")"
        if [[ -n "${mapped_section}" ]]; then
            SECTION="${mapped_section}"
            break
        fi
    fi
done

case $? in
    0)
        echo "[STATUS] SECTION="${SECTION}""
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 写入 control 文件
{
    printf "Package: ${ID}\n"
    printf "Version: ${VERSION}\n"
    printf "Section: ${SECTION}\n"
    printf "Priority: optional\n"
    printf "Architecture: amd64\n"
    printf "Installed-Size: ${INSTALLED_SIZE}\n"
    printf "Maintainer: ${MAINTAINER} <${MAIL}>\n"
    printf "Description: ${DESCRIPTION}\n"
} > "./${ID}/DEBIAN/control"

case $? in
    0)
        echo "[STATUS] 写入 control 文件成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 更改用户组和权限
echo "${PASSWORD}" | sudo -S chown -R root:root "./${ID}"
echo "${PASSWORD}" | sudo -S chmod -R 755 "./${ID}"

case $? in
    0)
        echo "[STATUS] 更改用户组和权限成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac

# 生成 deb 包
printf "[STATUS] "
zenity --info --text="正在生成 deb 包，生成结束后会弹出信息框，请耐心等待" &
dpkg-deb --build "./${ID}" . &
pid=$!

wait ${pid}

case $? in
    0)
        echo "[STATUS] 生成 deb 包成功"
        zenity --info --text="生成 deb 包成功"
        ;;
    *)
        echo "[ERROR] 发生意外错误"
        exit -1
        ;;
esac
