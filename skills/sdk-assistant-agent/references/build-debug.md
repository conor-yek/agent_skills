# ARCS 编译烧录调试助手

覆盖 ARCS SDK 开发的三大核心操作：**编译构建**、**固件烧录**、**串口日志查看**，以及对应的故障诊断。

## 触发条件

**操作类**（帮用户做事）:
- 编译/构建项目（build、编译、make）
- 烧录固件到设备（烧录、flash、burn）
- 查看串口日志/调试输出（串口、日志、log、monitor）
- 运行 menuconfig 配置 Kconfig

**诊断类**（帮用户排查问题）:
- 编译错误或警告（编译期 / 链接期 / CMake 配置期）
- Kconfig 选项不生效或依赖问题
- 内存溢出（ROM/RAM overflow）
- 烧录失败（串口不通、超时、BOOT 模式、eMMC 问题）
- 串口无日志输出、乱码、shell 不响应
- GDB 连接失败、断点无法命中
- 环境配置问题（工具链、CMake、Ninja）

---

## 执行流程

### Step 1: 识别用户意图

根据用户描述分为两大类：

| 意图类型 | 典型表述 | 跳转 |
|----------|----------|------|
| **A: 操作执行** | "帮我编译"、"怎么烧录"、"我要看日志"、"build 一下" | → **Step 2** |
| **B: 故障诊断** | "编译报错"、"烧录失败"、"串口没输出"、"undefined reference" | → **Step 3** |

**细分关键词**:

| 关键词 | 场景 |
|--------|------|
| build、编译、构建、make、menuconfig | 编译构建 (2A / 3A) |
| 烧录、cskburn、flash、burn、BOOT | 烧录 (2B / 3B) |
| 日志、log、串口、UART、monitor、picocom | 串口查看 (2C / 3C) |
| shell、GDB、JTAG、debug、RTT | 调试 (3C) |

**在线文档参考:**
- 快速入门（编译/烧录命令）: `get_started.html`
- GDB 调试指南: `gdb.html`
- 完整 URL 映射见 `references/knowledge/online-docs.md`

---

### Step 2: 操作执行

#### 2A: 编译构建

**信息收集**（依次确认，已知则跳过）:

1. **项目路径** — 用户要编译哪个项目？
   - 若用户说"编译 helloworld"→ 推断 `samples/helloworld`
   - 若用户说"编译当前项目"→ 询问具体路径或从工作区推断
   - 常见路径模式: `samples/<name>`, `demos/<name>`, 或用户自定义路径
2. **板型** — `arcs_evb`（EVB 评估板）还是 `arcs_mini`（Mini 开发板）？
   - 若用户未指定，询问板型
   - 若项目 `prj.conf` 或上下文中有板型信息，直接使用
3. **是否清理重建** — 是否需要 `-C` 清理？
   - 遇到奇怪问题时建议清理重建
   - 首次编译或修改了 Kconfig/CMakeLists.txt 时建议清理

**执行流程**:

```
1. 确认项目路径和板型
2. 构造编译命令:
   ./build.sh [-C] -S <项目路径> -DBOARD=<板型> [其他参数]
3. 用 Bash 工具执行命令
4. 分析输出:
   ├─ 成功 → 报告产物位置（bin/elf/map 文件）
   └─ 失败 → 跳转 Step 3A 诊断
```

**命令构造示例**:
```bash
# 基本编译
./build.sh -S samples/helloworld -DBOARD=arcs_evb

# 清理重建
./build.sh -C -S samples/helloworld -DBOARD=arcs_evb

# menuconfig 配置
./build.sh -S samples/helloworld -t menuconfig -DBOARD=arcs_evb
```

**成功时的输出分析**:
- 报告 `build/<app_name>.bin` 文件路径和大小
- 若启用了 `CONFIG_PRINT_MEMORY_USAGE=y`，解读内存使用输出（各区域 Used/Region Size/%）
- 若未启用，建议添加到 prj.conf 以便跟踪内存
- 提示下一步: "可以烧录了，需要我帮你烧录吗？"

#### 2B: 固件烧录

**前置检查**（Agent 主动执行）:

```
1. 检查 bin 文件是否存在:
   ls -l build/*.bin
   - 不存在 → 提示先编译

2. 检测可用串口:
   ls -l /dev/ttyUSB* 2>/dev/null || ls -l /dev/ttyACM* 2>/dev/null
   - 无串口 → 提示检查 USB 连接

3. 检查串口是否被占用:
   fuser /dev/ttyACM0 (或 ttyUSB0)
   - 有进程占用（如 picocom/minicom）→ kill <PID> 释放端口后再烧录

4. 提示用户操作:
   ⚠️ 烧录前请执行: 按住 BOOT 按键，然后复位开发板
```

**信息收集**:

1. **bin 文件路径** — 默认 `build/<app_name>.bin`，从最近构建中推断
2. **串口设备** — 从检测结果中选择，通常是 `/dev/ttyUSB0`
3. **烧录目标** — Flash（默认）还是 eMMC（需 `--emmc`）
4. **波特率** — 默认 3000000，不稳定时建议降低

**执行流程**:

```
1. 执行前置检查
2. 提示用户进入 BOOT 模式
3. 等待用户确认
4. 构造烧录命令:
   ./tools/burn/cskburn -C arcs -s <串口> -b <波特率> 0x0 <bin文件>
5. 用 Bash 工具执行命令
6. 分析输出:
   ├─ 成功 → 提示: "烧录完成，请复位开发板运行固件"
   └─ 失败 → 跳转 Step 3B 诊断
```

**命令构造示例**:
```bash
# 基本烧录
./tools/burn/cskburn -C arcs -s /dev/ttyUSB0 -b 3000000 0x0 build/app.bin

# 烧录并验证
./tools/burn/cskburn -C arcs -s /dev/ttyUSB0 -b 3000000 --verify-all 0x0 build/app.bin

# eMMC 烧录
./tools/burn/cskburn -C arcs -s /dev/ttyUSB0 --emmc -b 3000000 0x0 build/app.bin
```

#### 2C: 串口日志查看

**检测可用工具**（Agent 主动执行）:

```bash
# 按优先级检测已安装的串口工具
which picocom 2>/dev/null && echo "picocom available"
which minicom 2>/dev/null && echo "minicom available"
which screen 2>/dev/null && echo "screen available"
python3 -c "import serial.tools.miniterm" 2>/dev/null && echo "miniterm available"
```

**检测串口设备**:
```bash
ls -l /dev/ttyUSB* 2>/dev/null || ls -l /dev/ttyACM* 2>/dev/null
```

**推荐命令**（按优先级）:

| 工具 | 命令 | 退出方式 |
|------|------|----------|
| picocom | `picocom -b 921600 /dev/ttyUSB0` | `Ctrl-A Ctrl-X` |
| minicom | `minicom -D /dev/ttyUSB0 -b 921600` | `Ctrl-A X` |
| screen | `screen /dev/ttyUSB0 921600` | `Ctrl-A K` 然后按 `Y` |
| miniterm | `python3 -m serial.tools.miniterm /dev/ttyUSB0 921600` | `Ctrl-]` |

**关键参数说明**:
- **波特率 921600** — ARCS syslog UART 默认波特率
- **8N1** — 8 数据位、无校验、1 停止位（所有工具默认值）
- 串口设备通常是 `/dev/ttyUSB0`，多设备时需确认

**执行流程**:

```
1. 检测可用串口工具和设备
2. 根据检测结果推荐命令
3. 给出完整命令和退出方式
4. 提示: 串口监视工具会独占终端，Agent 无法替你执行
   - 建议用户在另一个终端窗口中运行
   - 或使用 Bash 工具的 run_in_background 模式（有超时限制）
```

**常用操作提示**:
- 日志保存: `picocom -b 921600 /dev/ttyUSB0 --logfile output.log`
- 带时间戳: `picocom -b 921600 /dev/ttyUSB0 | ts '[%Y-%m-%d %H:%M:%S]'`（需安装 moreutils）
- 串口权限不足时: `sudo usermod -a -G dialout $USER`（需重新登录生效）

---

### Step 3: 故障诊断

**通用诊断流程**:
1. 让用户提供**完整的错误输出**（或从 Step 2 的执行结果中直接获取）
2. 读取 `references/knowledge/build-issues.md` 查找已知问题模式
3. 确认用户的**板型**和**项目路径**
4. 如需要，检查用户的 `prj.conf` 和 `CMakeLists.txt`
5. 匹配已知模式 → 给出解决方案；未知模式 → 引导式排查

#### 3A: 编译构建诊断

**自动错误分析**（从编译输出中提取关键信息）:

```
错误输出 → 提取错误行
  ├─ 包含 "CMake Error" / "FATAL_ERROR" → CMake 配置期错误
  │   ├─ "LISTENAI_TOOLS_PATH is not defined" → 工具链路径问题
  │   ├─ "ARCS_BASE is not defined" / "ARCS_BASE not found" → SDK 路径问题
  │   ├─ "Tool xxx does not exist" → 工具文件缺失
  │   ├─ "Kconfig parse failed" → prj.conf 语法错误
  │   ├─ "CMake 3.19 or higher is required" → CMake 版本不足
  │   └─ "Board xxx not found" → 板型拼写/路径错误
  ├─ 包含 "error:" (带文件名前缀) → 编译期错误
  ├─ 包含 "undefined reference" / "multiple definition" → 链接期错误
  ├─ 包含 "will not fit in region" / "overflow" → 内存溢出
  ├─ 包含 "HEAP size is under the size limit" → 堆空间不足 ASSERT
  ├─ 包含 "error: wifi ram" → WIFI_RAM 区域约束违反
  ├─ 包含 "ABI mismatch" / "has float ABI" → FPU 配置不一致
  └─ 包含 "relocation truncated" → 代码跳转距离超限
```

**CMake 配置期错误**:

| 错误模式 | 原因 | 解决方案 |
|----------|------|----------|
| `ARCS_BASE is not set` | 未设置 SDK 根目录 | build.sh 会自动设置，确认从 SDK 根目录运行 |
| `Board xxx not found` | 板型名拼写错误或自定义板型路径未设置 | 检查 `-DBOARD=` 参数；自定义板型用 `-DBOARD_SEARCH_PATH=` |
| `find_package(xxx) failed` | 缺少依赖包 | 检查 Kconfig 是否启用对应模块 |
| `CMake version too old` | CMake 版本 < 3.19 | 升级 CMake 或检查 `LISTENAI_TOOLS_PATH` |
| `target_link_libraries` 找不到目标 | 模块未被 Kconfig 启用 | 检查 prj.conf 和 Kconfig 依赖 |

**编译期错误**:

| 错误模式 | 原因 | 解决方案 |
|----------|------|----------|
| `xxx.h: No such file or directory` | 头文件路径未加入 include | 检查 CMakeLists.txt 的 `listenai_library_include_directories` |
| `implicit declaration of function` | 缺少头文件包含或函数未声明 | 添加对应的 `#include` |
| `incompatible pointer type` | 类型不匹配 | 检查函数签名和参数类型 |
| `xxx undeclared` / `use of undeclared identifier` | 宏未定义（Kconfig 未开启） | 检查 prj.conf 中对应 `CONFIG_xxx=y` 是否启用 |
| `redefinition of xxx` | 同名符号多次定义 | 检查头文件保护宏，确认函数是否应为 static |

**链接期错误**:

| 错误模式 | 原因 | 解决方案 |
|----------|------|----------|
| `undefined reference to xxx` | 源文件未编译或 Kconfig 未开启 | 检查 `listenai_library_sources_ifdef` 条件；确认 prj.conf |
| `multiple definition of xxx` | 非 static 函数定义在头文件中 | 改为 `static inline` 或移到 .c 文件 |
| `section .xxx not found` | 自定义段 .ld.in 未注册 | 在 CMakeLists.txt 中添加 `listenai_add_custom_section()` |
| `will not fit in region` / `overflow` | ROM/RAM 空间不足 | 检查 .map 文件，优化大数组/启用 XIP/调整栈大小 |

**内存溢出分析指引** — 读取 `references/knowledge/build-issues.md` 第 3 节和第 7 节获取完整指引

快速步骤:
```
1. 启用内存统计: 在 prj.conf 添加 CONFIG_PRINT_MEMORY_USAGE=y，重新编译
2. 查看各段占用: 读取 build/<app_name>.map 中的段大小
3. 找最大符号:
   grep -E "^\s+0x[0-9a-f]+\s+0x[0-9a-f]{4,}" build/<app_name>.map | sort -k2 -rn | head -20
4. 常见优化: 见 build-issues.md 内存溢出分析
```

**Kconfig 依赖问题**:
- 如果直接在 prj.conf 中设置 `CONFIG_XXX=y` 但不生效，检查 Kconfig 的 `depends on` 依赖链
- 使用 `./build.sh -S <path> -t menuconfig -DBOARD=<board>` 确认选项可见性
- 常见依赖链: `LISA_XXX_DEVICE → LISA_DEVICE → LISA_OS → MODULE_FREERTOS`

**环境检查** — 确认必要环境变量:
- `NUCLEI_TOOLCHAIN_PATH` — GCC 交叉编译工具链路径
- `LISTENAI_TOOLS_PATH` — CMake / Ninja 等构建工具路径
- `ARCS_BASE` — SDK 根目录（build.sh 自动查找，通常无需手动设置）
- build.sh 会向上查找 `listenai-dev-tools/` 目录自动设置这两个变量

#### 3B: 烧录问题诊断

**诊断决策树**:

```
烧录失败
├─ "Cannot open /dev/ttyUSB0"
│   ├─ 串口不存在 → 检查 USB 连接，运行 ls /dev/ttyUSB*
│   └─ 权限不足 → sudo usermod -a -G dialout $USER，重新登录
├─ 超时 / 无响应
│   ├─ 未进入 BOOT 模式 → 按住 BOOT + 复位
│   ├─ 波特率过高 → 降低到 1500000 或 921600
│   └─ USB 线材问题 → 换线或换 USB 口
├─ 验证失败
│   ├─ Flash 数据残留 → 先 --erase-all 再烧录
│   └─ 波特率不稳定 → 降低波特率重试
└─ eMMC 烧录失败
    ├─ SDIO 引脚未连接 → 检查 PA4~PA9 连接
    └─ 存储器未供电 → 检查 eMMC/T卡 供电
```

**波特率建议**:
| 场景 | 波特率 | 说明 |
|------|--------|------|
| 稳定烧录 | 1500000 ~ 3000000 | 推荐范围 |
| 快速开发 | 6000000 | 可尝试，部分环境不稳定 |
| 排障降速 | 921600 | 不稳定时使用 |

**烧录目标选择**:
- Flash 烧录（默认）— 直接烧录，无需额外参数
- eMMC/T卡 烧录 — 需要 `--emmc` 参数，通过 SDIO 接口（PA4~PA9）

#### 3C: 串口与调试问题诊断

**串口无输出排查**:

```
无日志输出
├─ 检查物理连接
│   ├─ 波特率是否 921600？
│   ├─ TX/RX 是否反接？
│   └─ USB 转串口芯片是否被识别？(ls /dev/ttyUSB*)
├─ 检查软件配置 (prj.conf)
│   ├─ CONFIG_SYSLOG_UART_BACKEND=y (默认开启)
│   ├─ CONFIG_SYSLOG_UART_DEVICE_UART0=y (确认 UART 端口)
│   └─ CONFIG_SYSLOG_UART_BAUDRATE=921600 (确认波特率)
├─ 检查引脚配置
│   ├─ arcs_evb: PA2(RX) / PA3(TX) (UART0, PAD_A)
│   └─ arcs_mini: PB2(TX) (UART0, PAD_B)
└─ 固件本身问题
    ├─ 固件是否成功烧录？
    └─ main() 是否有日志输出语句？
```

**串口乱码排查**:
- 最常见原因: **波特率不匹配** — 确认终端设置为 921600
- 检查 `CONFIG_SYSLOG_UART_BAUDRATE` 是否与终端一致
- 少数情况: 数据位/校验位设置错误，确认 8N1

**lisa_log 配置诊断**（需 `CONFIG_LOG=y`）:
- 日志级别: `CONFIG_LOG_LEVEL_ASSERT/ERROR/WARN/INFO/DEBUG/VERBOSE`
- 异步模式: `CONFIG_LOG_MODE_ASYNC=y`（默认开启，性能更好）
- 缓冲区大小: `CONFIG_LOG_ASYNC_BUF_SIZE`（默认 10240）
- 单行最大长度: `CONFIG_LOG_LINE_BUF_SIZE`（默认 1024）
- SEGGER RTT 后端: `CONFIG_LOG_BACKEND_SEGGER_RTT=y`（需 J-Link）

**lisa_shell 不响应排查**:
- 确认 `CONFIG_LISA_SHELL=y`
- 确认 syslog UART backend 正常工作（shell 依赖它）
- 检查 stack size 是否足够: `CONFIG_LISA_SHELL_TASK_STACK_SIZE`（默认 1024）
- shell 与 syslog 共享同一 UART 端口

**GDB/JTAG 调试**:
- 需要: J-Link V11+、ARCS J-Link 设备配置文件
- GDB 工具: `${NUCLEI_TOOLCHAIN_PATH}/bin/riscv64-unknown-elf-gdb`
- J-Link 脚本: `jtagscan0.JLinkScript`(core0/AP) 或 `jtagscan1.JLinkScript`(core1/CP)
- SDK 示例默认运行在 **core1(CP核心)**，调试时使用 `jtagscan1.JLinkScript`

---

### Step 4: 知识沉淀

如果在诊断过程中遇到新类型的问题：
1. 记录到 `references/knowledge/build-issues.md` 对应分类下
2. 包含: 错误模式、根因、解决方案
3. 若为常见问题，同步更新本 SKILL.md 的诊断表格

---

## 在线文档参考

需要完整参数说明或详细配置时，WebFetch 对应页面（URL 前缀见 `references/knowledge/online-docs.md`）：

| 内容 | 文档路径 |
|------|----------|
| 编译/烧录完整命令和参数 | `get_started.html` |
| cskburn 完整参数 | `tools/burn/README.html` |
| GDB 调试完整指南（含 JLink 安装） | `gdb.html` |
| 板型引脚定义 | `boards/arcs_evb/README.html` 或 `boards/arcs_mini/README.html` |

**串口连接参数（板型相关，此处保留）:**

| 板型 | UART | 引脚 | 波特率 |
|------|------|------|--------|
| arcs_evb | UART0 | PA2(RX)/PA3(TX) | 921600 |
| arcs_mini | UART0 | PB2(TX) | 921600 |
