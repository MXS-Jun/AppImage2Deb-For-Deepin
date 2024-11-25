import os
import sys
import subprocess

from PyQt5.QtWidgets import *
from PyQt5.QtCore import *


class Window(QWidget):
    appimage_location = ""
    icon_location = ""
    package_name = ""
    software_name = ""
    version = ""
    developer = ""
    developer_mail = ""
    maintainer = ""
    maintainer_mail = ""
    category = ""
    simple_description = ""
    detailed_description = ""
    homepage = ""

    categories = [
        "Others",
        "Network",
        "Chat",
        "Audio",
        "AudioVideo",
        "Graphics",
        "Game",
        "Office",
        "Reading",
        "Development",
        "System",
    ]

    permissions = {
        "autostart": False,
        "notification": False,
        "trayicon": False,
        "clipboard": False,
        "account": False,
        "bluetooth": False,
        "camera": False,
        "audio_record": False,
        "installed_apps": False,
    }

    def __init__(self):
        super(Window, self).__init__()
        self.setWindowTitle("AppImage转Deb(Deepin规范)")

        self.appimage_location_label = QLabel("AppImage文件：")
        self.icon_location_label = QLabel("Icon文件：")
        self.package_name_label = QLabel("Deb包名：")
        self.software_name_label = QLabel("软件名：")
        self.version_label = QLabel("软件版本：")
        self.developer_label = QLabel("开发者姓名：")
        self.developer_mail_label = QLabel("开发者邮箱：")
        self.maintainer_label = QLabel("维护者姓名：")
        self.maintainer_mail_label = QLabel("维护者邮箱：")
        self.category_label = QLabel("应用分类：")
        self.simple_description_label = QLabel("一句话介绍：")
        self.detailed_description_label = QLabel("详细介绍：")
        self.homepage_label = QLabel("应用主页：")

        labels = [
            self.appimage_location_label,
            self.icon_location_label,
            self.package_name_label,
            self.software_name_label,
            self.version_label,
            self.developer_label,
            self.developer_mail_label,
            self.maintainer_label,
            self.maintainer_mail_label,
            self.category_label,
            self.simple_description_label,
            self.detailed_description_label,
            self.homepage_label,
        ]

        for label in labels:
            label.setAlignment(Qt.AlignmentFlag.AlignRight)

        self.appimage_location_button = QPushButton("选择文件")
        self.icon_location_button = QPushButton("选择文件")
        self.package_name_line = QLineEdit()
        self.software_name_line = QLineEdit()
        self.version_line = QLineEdit()
        self.developer_line = QLineEdit()
        self.developer_mail_line = QLineEdit()
        self.maintainer_line = QLineEdit()
        self.maintainer_mail_line = QLineEdit()
        self.category_combo_box = QComboBox()
        self.category_combo_box.addItems(
            [
                "其他应用",
                "网络应用",
                "社交沟通",
                "音乐欣赏",
                "视频播放",
                "图形图像",
                "游戏娱乐",
                "办公学习",
                "阅读翻译",
                "编程开发",
                "系统管理",
            ]
        )
        self.simple_description_line = QLineEdit()
        self.detailed_description_plain_text = QPlainTextEdit()
        self.homepage_line = QLineEdit()

        self.autostart_check_box = QCheckBox("自启动")
        self.notification_check_box = QCheckBox("使用通知")
        self.trayicon_check_box = QCheckBox("显示托盘图标")
        self.clipboard_check_box = QCheckBox("使用剪切板")
        self.account_check_box = QCheckBox("读取登录用户信息")
        self.bluetooth_check_box = QCheckBox("使用蓝牙设备")
        self.camera_check_box = QCheckBox("使用视频设备")
        self.audio_record_check_box = QCheckBox("进行录音")
        self.installed_apps_check_box = QCheckBox("读取安装软件列表")

        self.clear_button = QPushButton("清空数据")
        self.start_button = QPushButton("开始转化")

        self.category = self.categories[0]
        self.init_UI()
        self.init_signals()

    def init_UI(self):
        info_group_box = QGroupBox("软件信息")
        info_grid_layout = QGridLayout()
        info_grid_layout.addWidget(self.appimage_location_label, 0, 0)
        info_grid_layout.addWidget(self.icon_location_label, 1, 0)
        info_grid_layout.addWidget(self.package_name_label, 2, 0)
        info_grid_layout.addWidget(self.software_name_label, 3, 0)
        info_grid_layout.addWidget(self.version_label, 4, 0)
        info_grid_layout.addWidget(self.developer_label, 5, 0)
        info_grid_layout.addWidget(self.developer_mail_label, 6, 0)
        info_grid_layout.addWidget(self.maintainer_label, 7, 0)
        info_grid_layout.addWidget(self.maintainer_mail_label, 8, 0)
        info_grid_layout.addWidget(self.category_label, 9, 0)
        info_grid_layout.addWidget(self.simple_description_label, 10, 0)
        info_grid_layout.addWidget(self.detailed_description_label, 11, 0)
        info_grid_layout.addWidget(self.homepage_label, 12, 0)
        info_grid_layout.addWidget(self.appimage_location_button, 0, 1)
        info_grid_layout.addWidget(self.icon_location_button, 1, 1)
        info_grid_layout.addWidget(self.package_name_line, 2, 1)
        info_grid_layout.addWidget(self.software_name_line, 3, 1)
        info_grid_layout.addWidget(self.version_line, 4, 1)
        info_grid_layout.addWidget(self.developer_line, 5, 1)
        info_grid_layout.addWidget(self.developer_mail_line, 6, 1)
        info_grid_layout.addWidget(self.maintainer_line, 7, 1)
        info_grid_layout.addWidget(self.maintainer_mail_line, 8, 1)
        info_grid_layout.addWidget(self.category_combo_box, 9, 1)
        info_grid_layout.addWidget(self.simple_description_line, 10, 1)
        info_grid_layout.addWidget(self.detailed_description_plain_text, 11, 1)
        info_grid_layout.addWidget(self.homepage_line, 12, 1)
        info_grid_layout.setAlignment(Qt.AlignmentFlag.AlignLeft)
        info_group_box.setLayout(info_grid_layout)

        permission_group_box = QGroupBox("软件权限")
        permission_vbox_layout = QVBoxLayout()
        permission_vbox_layout.addWidget(self.autostart_check_box)
        permission_vbox_layout.addWidget(self.notification_check_box)
        permission_vbox_layout.addWidget(self.trayicon_check_box)
        permission_vbox_layout.addWidget(self.clipboard_check_box)
        permission_vbox_layout.addWidget(self.account_check_box)
        permission_vbox_layout.addWidget(self.bluetooth_check_box)
        permission_vbox_layout.addWidget(self.camera_check_box)
        permission_vbox_layout.addWidget(self.audio_record_check_box)
        permission_vbox_layout.addWidget(self.installed_apps_check_box)
        permission_group_box.setLayout(permission_vbox_layout)

        sub1_hbox_layout = QHBoxLayout()
        sub1_hbox_layout.addWidget(info_group_box)
        sub1_hbox_layout.addWidget(permission_group_box)

        sub2_hbox_layout = QHBoxLayout()
        sub2_hbox_layout.addWidget(self.clear_button)
        sub2_hbox_layout.addWidget(self.start_button)

        main_vbox_layout = QVBoxLayout()
        main_vbox_layout.addLayout(sub1_hbox_layout)
        main_vbox_layout.addLayout(sub2_hbox_layout)

        self.setLayout(main_vbox_layout)

    def init_signals(self):
        self.appimage_location_button.clicked.connect(self.select_appimage)
        self.icon_location_button.clicked.connect(self.select_icon)
        self.package_name_line.textChanged.connect(self.save_package_name)
        self.software_name_line.textChanged.connect(self.save_software_name)
        self.version_line.textChanged.connect(self.save_version)
        self.developer_line.textChanged.connect(self.save_developer)
        self.developer_mail_line.textChanged.connect(self.save_developer_mail)
        self.maintainer_line.textChanged.connect(self.save_maintainer)
        self.maintainer_mail_line.textChanged.connect(self.save_maintainer_mail)
        self.category_combo_box.currentIndexChanged.connect(self.save_category)
        self.simple_description_line.textChanged.connect(self.save_simple_description)
        self.detailed_description_plain_text.textChanged.connect(
            self.save_detailed_description
        )
        self.homepage_line.textChanged.connect(self.save_homepage)

        self.autostart_check_box.stateChanged.connect(self.set_autostart)
        self.notification_check_box.stateChanged.connect(self.set_notification)
        self.trayicon_check_box.stateChanged.connect(self.set_trayicon)
        self.clipboard_check_box.stateChanged.connect(self.set_clipboard)
        self.account_check_box.stateChanged.connect(self.set_account)
        self.bluetooth_check_box.stateChanged.connect(self.set_bluetooth)
        self.camera_check_box.stateChanged.connect(self.set_camera)
        self.audio_record_check_box.stateChanged.connect(self.set_audio_record)
        self.installed_apps_check_box.stateChanged.connect(self.set_installed_apps)

        self.clear_button.clicked.connect(self.clear)
        self.start_button.clicked.connect(self.start)

    def select_appimage(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self, "选择AppImage文件", "./", "AppImage Files (*.AppImage)"
        )
        self.appimage_location = file_path
        self.appimage_location_button.setText(os.path.basename(file_path))

    def select_icon(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self, "选择Icon文件", "./", "Icon Files (*.svg *.png)"
        )
        self.icon_location = file_path
        self.icon_location_button.setText(os.path.basename(file_path))

    def save_package_name(self):
        self.package_name = self.package_name_line.text()

    def save_software_name(self):
        self.software_name = self.software_name_line.text()

    def save_version(self):
        self.version = self.version_line.text()

    def save_developer(self):
        self.developer = self.developer_line.text()

    def save_developer_mail(self):
        self.developer_mail = self.developer_mail_line.text()

    def save_maintainer(self):
        self.maintainer = self.maintainer_line.text()

    def save_maintainer_mail(self):
        self.maintainer_mail = self.maintainer_mail_line.text()

    def save_category(self):
        self.category = self.categories[self.category_combo_box.currentIndex()]

    def save_simple_description(self):
        self.simple_description = self.simple_description_line.text()

    def save_detailed_description(self):
        self.detailed_description = self.detailed_description_plain_text.toPlainText()

    def save_homepage(self):
        self.homepage = self.homepage_line.text()

    def set_autostart(self):
        if self.autostart_check_box.isChecked():
            self.permissions["autostart"] = True
        else:
            self.permissions["autostart"] = False

    def set_notification(self):
        if self.notification_check_box.isChecked():
            self.permissions["notification"] = True
        else:
            self.permissions["notification"] = False

    def set_trayicon(self):
        if self.trayicon_check_box.isChecked():
            self.permissions["trayicon"] = True
        else:
            self.permissions["trayicon"] = False

    def set_clipboard(self):
        if self.clipboard_check_box.isChecked():
            self.permissions["clipboard"] = True
        else:
            self.permissions["clipboard"] = False

    def set_account(self):
        if self.account_check_box.isChecked():
            self.permissions["account"] = True
        else:
            self.permissions["account"] = False

    def set_bluetooth(self):
        if self.bluetooth_check_box.isChecked():
            self.permissions["bluetooth"] = True
        else:
            self.permissions["bluetooth"] = False

    def set_camera(self):
        if self.camera_check_box.isChecked():
            self.permissions["camera"] = True
        else:
            self.permissions["camera"] = False

    def set_audio_record(self):
        if self.audio_record_check_box.isChecked():
            self.permissions["audio_record"] = True
        else:
            self.permissions["audio_record"] = False

    def set_installed_apps(self):
        if self.installed_apps_check_box.isChecked():
            self.permissions["installed_apps"] = True
        else:
            self.permissions["installed_apps"] = False

    def clear(self):
        self.appimage_location = ""
        self.icon_location = ""
        self.package_name = ""
        self.software_name = ""
        self.version = ""
        self.developer = ""
        self.developer_mail = ""
        self.maintainer = ""
        self.maintainer_mail = ""
        self.category = self.categories[0]
        self.simple_description = ""
        self.detailed_description = ""
        self.homepage = ""

        for key in self.permissions.keys():
            self.permissions[key] = False

        self.appimage_location_button.setText("选择文件")
        self.icon_location_button.setText("选择文件")
        self.package_name_line.clear()
        self.software_name_line.clear()
        self.version_line.clear()
        self.developer_line.clear()
        self.developer_mail_line.clear()
        self.maintainer_line.clear()
        self.maintainer_mail_line.clear()
        self.category_combo_box.setCurrentIndex(0)
        self.simple_description_line.clear()
        self.detailed_description_plain_text.clear()
        self.homepage_line.clear()

        self.autostart_check_box.setChecked(False)
        self.notification_check_box.setChecked(False)
        self.trayicon_check_box.setChecked(False)
        self.clipboard_check_box.setChecked(False)
        self.account_check_box.setChecked(False)
        self.bluetooth_check_box.setChecked(False)
        self.camera_check_box.setChecked(False)
        self.audio_record_check_box.setChecked(False)
        self.installed_apps_check_box.setChecked(False)

    def start(self):
        info = ""
        info = info + "AppImage Location: " + self.appimage_location + "\n"
        info = info + "Icon Location: " + self.icon_location + "\n"
        info = info + "Package Name: " + self.package_name + "\n"
        info = info + "Software Name: " + self.software_name + "\n"
        info = info + "Version: " + self.version + "\n"
        info = info + "Developer: " + self.developer + "\n"
        info = info + "Developer Mail: " + self.developer_mail + "\n"
        info = info + "Maintainer: " + self.maintainer + "\n"
        info = info + "Maintainer Mail: " + self.maintainer_mail + "\n"
        info = info + "Developer: " + self.developer + "\n"
        info = info + "Category: " + self.category + "\n"
        info = info + "Simple Descrition: " + self.simple_description + "\n"
        info = info + "Detailed Description: " + self.detailed_description + "\n"
        info = info + "Homepage: " + self.homepage + "\n"

        for key in self.permissions.keys():
            info = info + key + ": " + str(self.permissions[key]) + "\n"

        choice = QMessageBox.question(
            self, "确认配置文件", info, QMessageBox.Yes | QMessageBox.No
        )
        if choice == QMessageBox.Yes:
            current_dir = os.getcwd()

            permission_bits = ""
            for key in self.permissions.keys():
                if self.permissions[key] == True:
                    permission_bits = permission_bits + "1"
                else:
                    permission_bits = permission_bits + "0"

            arguments = [
                current_dir,
                self.appimage_location,
                self.icon_location,
                self.package_name,
                self.software_name,
                self.version,
                self.developer,
                self.developer_mail,
                self.maintainer,
                self.maintainer_mail,
                self.category,
                self.simple_description,
                self.detailed_description,
                self.homepage,
                permission_bits,
            ]

            script_path = current_dir + "/build.sh"
            result = subprocess.run(
                ["bash", script_path] + arguments, capture_output=True, text=True
            )
            print("Script output:")
            print(result.stdout)
            print("Script exit code:", result.returncode)

            if result.returncode == 0:
                QMessageBox.information(self,"提醒","转化成功",QMessageBox.Yes)
            else:
                QMessageBox.information(self,"提醒","转化失败",QMessageBox.Yes)


if __name__ == "__main__":
    app = QApplication([])
    windows = Window()
    windows.show()
    sys.exit(app.exec())
