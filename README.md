# luci-app-woltools 网络唤醒工具

## 项目介绍

luci-app-woltools 是一个基于 LuCI 的网络唤醒工具，可以通过发送特殊的网络数据包（魔术包）来远程唤醒局域网内的计算机设备。

### 平台支持

本项目基于OpenWrt标准构建系统开发，支持多种硬件平台架构，包括但不限于：
- x86/x86_64 架构
- ARM/ARM64 架构 (如树莓派、NanoPi等)
- MIPS/MIPS64 架构
- PowerPC 架构

只要您的设备运行OpenWrt系统，无论是商用路由器、工控机还是DIY设备，均可安装使用本工具。

### 主要功能

- 添加、编辑和删除需要唤醒的设备信息
- 设置设备名称、MAC地址和网络接口
- 一键执行网络唤醒操作
- 支持多种网络接口选择

## 编译指南

### 基础环境要求

#### 通用Linux环境（包括OpenWrt设备）

1. 安装基础编译工具链：
```bash
# Debian/Ubuntu/麒麟系统
sudo apt-get update
sudo apt-get install -y build-essential gcc g++ make

# OpenWrt系统
opkg update
opkg install gcc g++ make

# CentOS/RHEL系统
sudo yum update
sudo yum groupinstall "Development Tools"
```

2. 安装OpenWrt SDK依赖：
```bash
# Debian/Ubuntu/麒麟系统
sudo apt-get install -y git wget file rsync ccache
sudo apt-get install -y zlib1g-dev libncurses5-dev ncurses-dev gawk flex gettext libssl-dev xsltproc libxml2-utils
sudo apt-get install -y python3 python3-pip
sudo apt-get install -y perl binutils-dev

# OpenWrt系统
opkg install git wget file rsync ccache
opkg install zlib ncurses gawk flex gettext-full openssl-util xsltproc libxml2-utils
opkg install python3 python3-pip
```

### OpenWrt SDK 环境设置

1. 下载并设置OpenWrt SDK：
```bash
# 下载SDK（请根据您的目标平台选择相应的SDK版本）
wget https://downloads.openwrt.org/releases/22.03.5/targets/x86/64/openwrt-sdk-22.03.5-x86-64_gcc-11.2.0_musl.Linux-x86_64.tar.xz

# 解压SDK
tar xf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*

# 设置SDK目录权限
chmod -R +x scripts/
chown -R $(whoami):$(whoami) .
```

2. 配置环境变量：
```bash
# 配置SDK环境变量
export STAGING_DIR=$(pwd)/staging_dir
export PATH=$PATH:$STAGING_DIR/host/bin:$STAGING_DIR/toolchain/bin

# 确保feeds脚本有执行权限
chmod +x scripts/feeds
```

### 依赖包

本项目依赖以下包：
- luci-base
- etherwake

注意：本项目不再依赖timeout命令，已优化实现方式以适配更多系统。

在OpenWrt设备上，可以通过以下命令安装依赖：
```bash
# 更新软件源
opkg update

# 安装依赖包
opkg install luci-base etherwake
```

在其他Linux系统上，这些依赖包会在编译过程中自动处理，无需手动安装。

## 编译步骤

1. 确保您已经正确设置了OpenWrt SDK环境，并且位于SDK根目录下：
```bash
cd /path/to/openwrt-sdk
```

2. 在SDK的package目录下创建项目目录：
```bash
mkdir -p package/luci-app-woltools
```

3. 克隆项目代码到package目录：
```bash
git clone https://github.com/your-username/luci-app-woltools.git package/luci-app-woltools
```

4. 更新feeds（确保luci相关依赖可用）：
```bash
# 使用完整路径执行feeds脚本
./scripts/feeds update -a
./scripts/feeds install -a
```

5. 选择要编译的包：
```bash
make menuconfig
# 在 LuCI -> 3. Applications 中选择 luci-app-woltools
```

6. 开始编译：
```bash
make package/luci-app-woltools/compile V=s
```

编译完成后，可以在 `bin/packages/[架构]/base/` 目录下找到编译好的ipk文件。

## 安装说明

### 上传ipk文件

有两种方式可以将编译好的ipk文件上传到OpenWrt/iStoreOS系统：

1. 通过Web界面上传：
   - 登录OpenWrt/iStoreOS Web管理界面
   - 进入「系统」->「文件传输」或「软件包」
   - 选择并上传ipk文件

2. 通过SCP命令上传：
   ```bash
   scp luci-app-woltools_*.ipk root@<设备IP>:/tmp/
   ```

### 安装ipk文件

1. 通过SSH连接到OpenWrt/iStoreOS系统：
   ```bash
   ssh root@<设备IP>
   ```

2. 执行安装命令：
   ```bash
   cd /tmp
   opkg install luci-app-woltools_*.ipk
   /etc/init.d/rpcd restart
   ```

## 使用说明

### 访问界面

1. 安装完成后，在Web界面的「服务」菜单下可以找到「局域网唤醒工具」
2. 点击进入管理界面

### 添加设备

1. 在设备列表下方的「添加新设备」区域：
   - 输入设备主机名（便于识别）
   - 输入设备的MAC地址（格式为XX:XX:XX:XX:XX:XX）
   - 选择网络接口（通常为eth0或br-lan）
   - 点击「添加设备」按钮

### 唤醒设备

1. 在设备列表中找到需要唤醒的设备
2. 点击对应设备行中的「唤醒」按钮
3. 系统会发送魔术包到指定的MAC地址，唤醒目标设备

### 管理设备

1. 修改网络接口：
   - 在设备列表中选择设备的网络接口下拉框
   - 选择新的网络接口
   - 系统会自动保存更改

2. 删除设备：
   - 点击设备行中的「删除」按钮
   - 确认删除操作

## 常见问题

### 唤醒失败的可能原因

1. 目标设备未正确配置网络唤醒功能（需在BIOS/UEFI中启用WOL功能）
2. MAC地址输入错误
3. 选择了错误的网络接口
4. 目标设备与路由器之间的网络设备不支持或阻止了魔术包

### 如何确认设备支持网络唤醒

1. 检查设备的BIOS/UEFI设置，确保启用了以下选项之一：
   - Wake on LAN
   - WOL
   - Remote Wake Up
   - Power On By PCI-E

2. 在Windows系统中：
   - 打开设备管理器
   - 找到网络适配器
   - 右键点击属性
   - 在高级或电源管理选项卡中，确保启用了网络唤醒相关选项

3. 在Linux系统中：
   ```bash
   sudo ethtool <网卡名称> | grep Wake-on
   # 输出应包含 Wake-on: g
   ```

### 编译问题排查

1. 确保所有依赖包版本兼容
2. 编译过程中如遇到错误，请检查：
   - 编译环境是否完整
   - 依赖包是否安装成功
   - SDK版本是否匹配
3. 建议在资源充足的系统上进行编译

## 贡献指南

欢迎提交问题报告和功能建议。如果您想贡献代码，请遵循以下步骤：

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request

## 开源协议

本项目采用 [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html) 开源协议。

该协议允许您自由地使用、修改和分发本软件，但要求：
- 任何修改后的版本或衍生作品必须以相同的许可证发布
- 必须保留原始版权声明
- 如果您分发修改后的版本，必须提供相应的源代码

详细条款请参阅 [GNU通用公共许可证第3版](https://www.gnu.org/licenses/gpl-3.0.html)。