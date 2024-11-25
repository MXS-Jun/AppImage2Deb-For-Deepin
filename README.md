# AppImage2Deb-For-Deepin
A convenient tool which can convert AppImage to Deb in [Deepin Standard](https://doc.chinauos.com/content/M7kCi3QB_uwzIp6HyF5J).

![preview](https://github.com/user-attachments/assets/80eab217-ef02-4fec-b339-38d3f11f2219)

You should input the arguments in Deepin Standard.

You can find AppImages to convert [here](https://appimage.github.io/apps/).

# Dependencies
To run `main.py` successfully you should install `PyQt5`.
The `build.sh` will be called by a function in `main.py`, to run `build.sh` properly, you should have a `bash` environment with `fakeroot` installed.

```bash
sudo apt install python3-pyqt5
sudo apt install fakeroot
```

# Run
After download my script, you can just input the command below into your terminal:
```bash
python3 /the/path/to/src/main.py
```
The deb file will be put in `/the/path/to/src`.
