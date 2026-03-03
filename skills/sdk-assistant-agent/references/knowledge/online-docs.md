# ARCS SDK 在线文档索引

> 本文件为 Agent 提供在线文档的结构索引和 URL 映射，用于快速定位官方文档页面。
> 当用户询问驱动/组件的使用方法、配置、API 细节时，通过 WebFetch 获取对应页面内容。

## 文档站信息

- **基础 URL**: `https://docs2.listenai.com/arcs-sdk/latest/zh/html/`
- **版本**: latest（跟随 SDK 最新发布版本）
- **Doxygen API 参考**: `api_doc.html`
- **Change Log**: `CHANGELOG.html`

## 文档结构总览

| 章节 | URL 路径 | 说明 |
|------|----------|------|
| 快速入门 | `get_started.html` | 环境搭建、编译、烧录 |
| GDB 调试 | `gdb.html` | GDB 调试指南 |
| 板型支持 | `boards/index_zh.html` | arcs_mini / arcs_evb |
| 设备驱动 | `drivers/index_zh.html` | 20 个驱动的 API 文档 |
| 组件 | `components/index_zh.html` | 服务/网络/算法组件 |
| 示例 | `samples/index_zh.html` | 7 类示例项目 |
| Demo 示例 | `demos/index_zh.html` | 完整演示项目 |
| 工具 | `tools/index_zh.html` | cskburn、fatfs、pinmux |
| 第三方库 | `thirds.html` | 50+ 第三方库列表 |
| API 参考 | `api_doc.html` | Doxygen 生成的 API 文档 |

## 设备驱动 URL 映射

所有驱动文档 URL 前缀: `drivers/`

| 驱动 | codebase 目录 | 文档路径 |
|------|--------------|----------|
| Pinmux | `drivers/lisa_pinmux/` | `drivers/lisa_pinmux/README.html` |
| GPIO | `drivers/lisa_gpio/` | `drivers/lisa_gpio/README.html` |
| ADC | `drivers/lisa_adc/` | `drivers/lisa_adc/README.html` |
| UART | `drivers/lisa_uart/` | `drivers/lisa_uart/README.html` |
| HWTIMER | `drivers/lisa_hwtimer/` | `drivers/lisa_hwtimer/README.html` |
| Flash | `drivers/lisa_flash/` | `drivers/lisa_flash/README.html` |
| SDMMC | `drivers/lisa_sdmmc/` | `drivers/lisa_sdmmc/README.html` |
| SPI | `drivers/lisa_spi/` | `drivers/lisa_spi/README.html` |
| QSPI LCD | `drivers/lisa_qspilcd/` | `drivers/lisa_qspilcd/README.html` |
| Display | `drivers/lisa_display/` | `drivers/lisa_display/README.html` |
| PWM | `drivers/lisa_pwm/` | `drivers/lisa_pwm/README.html` |
| RTC | `drivers/lisa_rtc/` | `drivers/lisa_rtc/README.html` |
| WDT | `drivers/lisa_wdt/` | `drivers/lisa_wdt/README.html` |
| Audio | `drivers/lisa_audio/` | `drivers/lisa_audio/README.html` |
| I2C | `drivers/lisa_i2c/` | `drivers/lisa_i2c/README.html` |
| I2S | `drivers/lisa_i2s/` | `drivers/lisa_i2s/README.html` |
| Touch | `drivers/lisa_touch/` | `drivers/lisa_touch/README.html` |
| DVP | `drivers/lisa_dvp/` | `drivers/lisa_dvp/README.html` |
| Camera | `drivers/lisa_camera/` | `drivers/lisa_camera/README.html` |
| RGB LCD | `drivers/lisa_rgb/` | `drivers/lisa_rgb/README.html` |

## 组件 URL 映射

所有组件文档 URL 前缀: `components/`

### 服务组件

| 组件 | codebase 目录 | 文档路径 |
|------|--------------|----------|
| 文件系统 | `modules/fs/` | `modules/fs/README.html` |
| Shell | `components/lisa_shell/` | `components/lisa_shell/README.html` |
| sys_heap | `components/sys_heap/` | `components/sys_heap/README.html` |
| Logger (lisa_log) | `components/lisa_log/` | `components/lisa_log/README.html` |
| 事件发布 (lisa_evt_pub) | `components/lisa_evt_pub/` | `components/lisa_evt_pub/README.html` |
| Work Queue | `components/work_queue/` | `components/work_queue/README.html` |
| Audio Player | `components/app_player/` | `components/app_player/README.html` |

### 网络组件

| 组件 | codebase 目录 | 文档路径 |
|------|--------------|----------|
| WebSocket | `components/lisa_websocket/` | `components/lisa_websocket/README.html` |
| SNTP | `components/lisa_sntp/` | `components/lisa_sntp/README.html` |
| HTTP | `components/lisa_http/` | `components/lisa_http/README.html` |
| WiFi | `components/lisa_wifi/` | `components/lisa_wifi/README.html` |
| Bluetooth | `components/lisa_bluetooth/` | `components/lisa_bluetooth/README.html` |
| Modem | `components/lisa_modem/` | `components/lisa_modem/README.html` |
| Net | `components/lisa_net/` | `components/lisa_net/README.html` |

### 算法组件

| 组件 | codebase 目录 | 文档路径 |
|------|--------------|----------|
| 语音唤醒 | `components/acomp/wakeup/` | `components/acomp/wakeup/README.html` |
| 人脸识别 | `components/acomp/fd/` | `components/acomp/fd/README.html` |

## 板型支持 URL 映射

| 板型 | 文档路径 |
|------|----------|
| ARCS Mini 开发板 | `boards/arcs_mini/README.html` |
| ARCS EVB 评估板 | `boards/arcs_evb/README.html` |
| 板型使用指南 | `boards/BOARD_USAGE.html` |
| 自定义板型开发 | `boards/BOARD_TEMPLATE.html` |

## 示例 URL 映射

所有示例文档 URL 前缀: `samples/`

| 示例分类 | 文档路径 |
|----------|----------|
| Hello World | `samples/helloworld/README.html` |
| 设备驱动示例 | `samples/drivers/devices/index_zh.html` |
| 组件模块示例 | `samples/modules/index_zh.html` |
| 网络示例 | `samples/network/index_zh.html` |
| Bluetooth 示例 | `samples/bluetooth/index_zh.html` |
| 算法组件示例 | `samples/algorithms/index_zh.html` |
| C++ 示例 | `samples/cpp/index_zh.html` |

## Demo URL 映射

| Demo | 文档路径 |
|------|----------|
| 人脸识别演示 | `demos/face_detect/README.html` |

## 工具 URL 映射

| 工具 | 文档路径 |
|------|----------|
| cskburn 烧录工具 | `tools/burn/README.html` |
| FAT32 镜像打包 | `tools/fatfs_package/README.html` |
| 引脚复用配置 | `tools/pinmux_tool_zh.html` |

## 关键页面摘要

### 快速入门核心命令

**环境变量设置:**
```bash
export NUCLEI_TOOLCHAIN_PATH=/path/to/listenai-dev-tools/gcc
export LISTENAI_TOOLS_PATH=/path/to/listenai-dev-tools/listenai-tools
```

**编译命令:**
```bash
./build.sh -S samples/helloworld -DBOARD=arcs_evb       # 增量编译
./build.sh -C -S samples/helloworld -DBOARD=arcs_evb    # 清除后重新编译
```
- `-S`: 项目源码路径
- `-DBOARD`: 目标板型（必须）
- `-C`: 清除构建目录（可选）

**烧录命令:**
```bash
./tools/burn/cskburn -s /dev/ttyUSB0 -b 3000000 0x0 build/helloworld.bin -C arcs
```
- `-s`: 串口设备路径
- `-b`: 波特率（推荐 3000000）
- `0x0`: Flash 偏移地址
- `-C arcs`: 芯片类型

**烧录前置操作:** 按住 BOOT 脚后复位开发板，进入烧录模式。

## URL 构建规则

完整 URL = 基础 URL + 文档路径

示例: `https://docs2.listenai.com/arcs-sdk/latest/zh/html/` + `drivers/lisa_uart/README.html`
→ `https://docs2.listenai.com/arcs-sdk/latest/zh/html/drivers/lisa_uart/README.html`
