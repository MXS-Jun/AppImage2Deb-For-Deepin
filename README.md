# Abstract
A convenient tool which can convert AppImage to Deb in [Deepin Standard](https://doc.chinauos.com/content/M7kCi3QB_uwzIp6HyF5J).

![ui](https://github.com/user-attachments/assets/2bea6e4a-6b95-4956-bf83-a5ab975038ca)

You should input the arguments in Deepin Standard.

Basically, the quality of the deb package you build based on the arguments you provided.

You can find AppImages to convert [here](https://appimage.github.io/apps/).

The program will not extract AppImages to make debs, it will use an original single AppImage file to make a deb.

# Dependencies
To run `main.py` successfully you should install `PyQt5`, you can use `conda` or `venv` to create a virtual environment to install `pyqt5`.

```bash
conda install pyqt5
pip3 install pyqt5
```

The `build.sh` will be called by a function in `main.py`, to run `build.sh` properly, you should have a `bash` environment with `fakeroot` and `imagemagick` installed.

```bash
sudo apt install imagemagick
sudo apt install fakeroot
```

It only supports amd64 architecture.

# Usage
After download my script, you can just input the command below into your terminal:

```bash
cd /the/path/to/src/
python3 main.py
```

The deb file will be put in `/the/path/to/src`.
