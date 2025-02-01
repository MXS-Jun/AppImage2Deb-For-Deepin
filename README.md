# 概述
一个方便的小工具，用来以[ UOS/Deepin 打包标准](https://doc.chinauos.com/content/M7kCi3QB_uwzIp6HyF5J)将 AppImage 文件转化为 deb 文件。
有 PyQt5 和 Zenity 两个版本。
在使用时，你需要以[ UOS/Deepin 打包标准](https://doc.chinauos.com/content/M7kCi3QB_uwzIp6HyF5J)输入必要参数。
你可以在[这里](https://appimage.github.io/apps/)找到你感兴趣的 AppImage 文件。

# 依赖
## PyQt5 版本
为了成功地运行 `main.py`，你需要安装 `PyQt5`, 你可以使用 `conda` 或 `venv` 来创建虚拟环境以安装 `pyqt5`。

```bash
# For example
conda install pyqt5
pip3 install pyqt5
```

你还需要 `bash` 环境，给予 `make-deb.sh` 可执行权限， 并且安装好 `fakeroot` 和 `imagemagick`。

```bash
# For example
sudo apt install imagemagick
sudo apt install fakeroot
cd /the/path/to/code/
sudo chmod +x make-deb.sh
```

## Zenity 版本
只需要 `bash` 环境，给予 `AppImage2Deb.sh` 可执行权限，并且安装好 `zenity`。

```bash
# For example
sudo apt install zenity
cd /the/path/to/code/
sudo chmod +x AppImage2Deb.sh
```

# 使用方法
## PyQt5 版本
配置好虚拟环境后，在终端模拟器激活虚拟环境，并运行 `main.py` 。

```bash
# For example
# You should activate virtual env first
cd /the/path/to/code/
python3 main.py
```

deb 文件会放在 `/the/path/to/code/`。

## Zenity 版本
配置好环境后，给予 `AppImage2Deb.sh` 可执行权限，并运行脚本。

```bash
# For example
cd /the/path/to/code/
./AppImage2Deb.sh
```
deb 文件会放在 `AppImage2Deb.sh` 同目录中生成的一个文件夹中。
