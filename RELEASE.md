# luci-app-woltools v1.0.0 - 首个x86架构版本发布

## 📢 发布说明

我们很高兴地宣布 luci-app-woltools 网络唤醒工具的首个x86架构版本正式发布！这是一款基于LuCI的网络唤醒工具，专为OpenWrt/iStoreOS系统设计，可以通过发送魔术包远程唤醒局域网内的计算机设备。

## ✨ 主要功能

- 添加、编辑和删除需要唤醒的设备信息
- 设置设备名称、MAC地址和网络接口
- 一键执行网络唤醒操作
- 支持多种网络接口选择
- 简洁直观的Web管理界面

## 🖥️ 平台支持

本次发布主要针对x86/x86_64架构设备，同时也兼容其他架构：
- ✅ x86/x86_64 架构（本次发布重点）
- ARM/ARM64 架构 (如树莓派、NanoPi等)
- MIPS/MIPS64 架构
- PowerPC 架构

只要您的设备运行OpenWrt/iStoreOS系统，无论是商用路由器、工控机还是DIY设备，均可安装使用本工具。

## 📦 安装方法

### 方法一：通过Web界面安装

1. 下载本页面提供的ipk文件
2. 登录OpenWrt/iStoreOS Web管理界面
3. 进入「系统」->「文件传输」或「软件包」
4. 选择并上传ipk文件
5. 安装完成后重启rpcd服务：`/etc/init.d/rpcd restart`

### 方法二：通过SSH安装

1. 下载本页面提供的ipk文件
2. 通过SCP上传到设备：
   ```bash
   scp luci-app-woltools_*.ipk root@<设备IP>:/tmp/
   ```
3. SSH连接到设备并安装：
   ```bash
   ssh root@<设备IP>
   cd /tmp
   opkg install luci-app-woltools_*.ipk
   /etc/init.d/rpcd restart
   ```

## 🚀 使用说明

1. 安装完成后，在Web界面的「服务」菜单下找到「局域网唤醒工具」
2. 添加设备：
   - 输入设备主机名
   - 输入设备MAC地址（格式为XX:XX:XX:XX:XX:XX）
   - 选择网络接口（通常为eth0或br-lan）
3. 唤醒设备：点击设备列表中对应设备的「唤醒」按钮

## 📝 注意事项

- 确保目标设备已在BIOS/UEFI中启用网络唤醒功能
- 确保输入的MAC地址正确
- 选择正确的网络接口

## 🔄 依赖说明

本工具依赖以下包：
- luci-base
- etherwake

## 📜 开源协议

本项目采用 [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html) 开源协议。

---

感谢您使用luci-app-woltools！如有问题或建议，欢迎在Issues中反馈。