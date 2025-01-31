# Developer: MXS-Jun
# Developer Mail: bjtuzj0328@gmail.com

import os
import sys
import subprocess

from PyQt5.QtWidgets import *
from PyQt5.QtCore import *


class Window(QWidget):
    appimage_location = ""
    package_name = ""
    software_name = ""
    architecture = ""
    version = ""
    developer = ""
    developer_mail = ""
    maintainer = ""
    maintainer_mail = ""
    category = ""
    simple_description = ""
    detailed_description = ""
    homepage = ""

    architectures = ["amd64", "arm64"]

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

    def __init__(self):
        super(Window, self).__init__()

        self.resize(480, 640)
        screen_resolution = QApplication.desktop()
        windows_resolution = self.frameSize()
        x = screen_resolution.width() // 2 - windows_resolution.width() // 2
        y = screen_resolution.height() // 2 - windows_resolution.height() // 2
        self.move(x, y)

        self.setWindowTitle("AppImage转Deb(Deepin规范)")

        self.appimage_location_label = QLabel("AppImage文件:")
        self.package_name_label = QLabel("Deb包名:")
        self.software_name_label = QLabel("软件名:")
        self.architecture_label = QLabel("软件架构")
        self.version_label = QLabel("软件版本:")
        self.developer_label = QLabel("开发者姓名:")
        self.developer_mail_label = QLabel("开发者邮箱:")
        self.maintainer_label = QLabel("维护者姓名:")
        self.maintainer_mail_label = QLabel("维护者邮箱:")
        self.category_label = QLabel("应用分类:")
        self.simple_description_label = QLabel("一句话介绍:")
        self.detailed_description_label = QLabel("详细介绍:")
        self.homepage_label = QLabel("应用主页:")

        labels = [
            self.appimage_location_label,
            self.package_name_label,
            self.software_name_label,
            self.architecture_label,
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
        self.clear_button = QPushButton("清空数据")
        self.start_button = QPushButton("开始转化")

        self.architecture_combo_box = QComboBox()
        self.architecture_combo_box.addItems(["amd64", "arm64"])
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

        self.package_name_line = QLineEdit()
        self.software_name_line = QLineEdit()
        self.version_line = QLineEdit()
        self.developer_line = QLineEdit()
        self.developer_mail_line = QLineEdit()
        self.maintainer_line = QLineEdit()
        self.maintainer_mail_line = QLineEdit()
        self.simple_description_line = QLineEdit()
        self.homepage_line = QLineEdit()

        self.detailed_description_plain_text = QPlainTextEdit()

        self.architecture = self.architectures[0]
        self.category = self.categories[0]
        self.init_UI()
        self.init_signals()

    def init_UI(self):
        info_group_box = QGroupBox("软件信息")
        info_grid_layout = QGridLayout()
        info_grid_layout.addWidget(self.appimage_location_label, 0, 0)
        info_grid_layout.addWidget(self.package_name_label, 1, 0)
        info_grid_layout.addWidget(self.software_name_label, 2, 0)
        info_grid_layout.addWidget(self.architecture_label, 3, 0)
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
        info_grid_layout.addWidget(self.package_name_line, 1, 1)
        info_grid_layout.addWidget(self.software_name_line, 2, 1)
        info_grid_layout.addWidget(self.architecture_combo_box, 3, 1)
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

        sub1_hbox_layout = QHBoxLayout()
        sub1_hbox_layout.addWidget(info_group_box)

        sub2_hbox_layout = QHBoxLayout()
        sub2_hbox_layout.addWidget(self.clear_button)
        sub2_hbox_layout.addWidget(self.start_button)

        main_vbox_layout = QVBoxLayout()
        main_vbox_layout.addLayout(sub1_hbox_layout)
        main_vbox_layout.addLayout(sub2_hbox_layout)

        self.setLayout(main_vbox_layout)

    def init_signals(self):
        self.appimage_location_button.clicked.connect(self.select_appimage)
        self.clear_button.clicked.connect(self.clear)
        self.start_button.clicked.connect(self.start)

        self.package_name_line.textChanged.connect(self.save_package_name)
        self.software_name_line.textChanged.connect(self.save_software_name)
        self.version_line.textChanged.connect(self.save_version)
        self.developer_line.textChanged.connect(self.save_developer)
        self.developer_mail_line.textChanged.connect(self.save_developer_mail)
        self.maintainer_line.textChanged.connect(self.save_maintainer)
        self.maintainer_mail_line.textChanged.connect(self.save_maintainer_mail)
        self.simple_description_line.textChanged.connect(self.save_simple_description)
        self.homepage_line.textChanged.connect(self.save_homepage)
        self.detailed_description_plain_text.textChanged.connect(
            self.save_detailed_description
        )

        self.architecture_combo_box.currentIndexChanged.connect(self.save_architecture)
        self.category_combo_box.currentIndexChanged.connect(self.save_category)

    def select_appimage(self):
        file_path, _ = QFileDialog.getOpenFileName(
            self, "选择AppImage文件", "./", "AppImage Files (*.AppImage)"
        )
        self.appimage_location = file_path

        if not file_path:
            self.appimage_location_button.setText("选择文件")
        else:
            self.appimage_location_button.setText(os.path.basename(file_path))

    def clear(self):
        choice = QMessageBox.warning(
            self, "警告", "确认清空所有数据?", QMessageBox.Yes | QMessageBox.No
        )
        if choice == QMessageBox.Yes:
            self.appimage_location = ""
            self.package_name = ""
            self.software_name = ""
            self.architecture = self.architectures[0]
            self.version = ""
            self.developer = ""
            self.developer_mail = ""
            self.maintainer = ""
            self.maintainer_mail = ""
            self.category = self.categories[0]
            self.simple_description = ""
            self.detailed_description = ""
            self.homepage = ""

            self.appimage_location_button.setText("选择文件")

            self.architecture_combo_box.setCurrentIndex(0)
            self.category_combo_box.setCurrentIndex(0)

            self.package_name_line.clear()
            self.software_name_line.clear()
            self.version_line.clear()
            self.developer_line.clear()
            self.developer_mail_line.clear()
            self.maintainer_line.clear()
            self.maintainer_mail_line.clear()
            self.simple_description_line.clear()
            self.homepage_line.clear()

            self.detailed_description_plain_text.clear()

    def start(self):
        info = ""
        info = info + "AppImage文件路径: " + self.appimage_location + "\n"
        info = info + "包名: " + self.package_name + "\n"
        info = info + "软件名: " + self.software_name + "\n"
        info = info + "软件架构：" + self.architecture + "\n"
        info = info + "版本: " + self.version + "\n"
        info = info + "开发者: " + self.developer + "\n"
        info = info + "开发者邮箱: " + self.developer_mail + "\n"
        info = info + "维护者: " + self.maintainer + "\n"
        info = info + "维护者邮箱: " + self.maintainer_mail + "\n"
        info = info + "分类: " + self.category + "\n"
        info = info + "一句话介绍: " + self.simple_description + "\n"
        info = info + "详细介绍: " + self.detailed_description + "\n"
        info = info + "主页: " + self.homepage + "\n"

        choice = QMessageBox.information(
            self, "确认配置文件", info, QMessageBox.Yes | QMessageBox.No
        )
        if choice == QMessageBox.Yes:
            current_dir = os.getcwd()

            arguments = [
                current_dir,
                self.appimage_location,
                self.package_name,
                self.software_name,
                self.architecture,
                self.version,
                self.developer,
                self.developer_mail,
                self.maintainer,
                self.maintainer_mail,
                self.category,
                self.simple_description,
                self.detailed_description,
                self.homepage,
            ]

            script_path = current_dir + "/make-deb.sh"
            result = subprocess.run(
                ["bash", script_path] + arguments, capture_output=True, text=True
            )
            print("Script output:")
            print(result.stdout)
            print("Script exit code:", result.returncode)

            if result.returncode == 0:
                QMessageBox.information(self, "提醒", "转化成功", QMessageBox.Yes)
            else:
                QMessageBox.information(self, "提醒", "转化失败", QMessageBox.Yes)

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

    def save_simple_description(self):
        self.simple_description = self.simple_description_line.text()

    def save_homepage(self):
        self.homepage = self.homepage_line.text()

    def save_detailed_description(self):
        self.detailed_description = self.detailed_description_plain_text.toPlainText()

    def save_architecture(self):
        if self.architecture_combo_box.currentIndex() == 0:
            self.architecture = "amd64"
        elif self.architecture_combo_box.currentIndex() == 1:
            self.architecture = "arm64"

    def save_category(self):
        self.category = self.categories[self.category_combo_box.currentIndex()]


if __name__ == "__main__":
    app = QApplication([])
    windows = Window()
    windows.show()
    sys.exit(app.exec())
