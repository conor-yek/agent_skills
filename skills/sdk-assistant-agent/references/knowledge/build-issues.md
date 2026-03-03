# 构建问题速查

## 1. CMake 配置期错误

| 症状 | 原因 | 解决 |
|------|------|------|
| `ARCS_BASE not found, Please add ARCS_BASE...` | build.sh 向上查找 `arcs-sdk/` 目录失败 | 确认从 `arcs-sdk/` 目录（或其子目录）运行 build.sh |
| `ARCS_BASE is not defined` | CMake 层找不到 SDK 根目录 | 确认 build.sh 已自动设置，或手动 `export ARCS_BASE=...` |
| `LISTENAI_TOOLS_PATH is not defined` | CMake 找不到工具路径 | build.sh 自动从 `listenai-dev-tools/listenai-tools/` 查找；手动设置 `export LISTENAI_TOOLS_PATH=...` |
| `Tool xxx does not exist` (cmake/kconfig/mkhdr) | 工具文件路径正确但文件不存在 | 检查 `LISTENAI_TOOLS_PATH` 下对应目录（`kconfig/`, `mkhdr/`）是否完整 |
| `Kconfig parse failed, error code: N` | prj.conf 语法错误或 Kconfig 树解析失败 | 检查 prj.conf 格式：`CONFIG_XXX=y`，bool 用 y/n，string 用引号 |
| `CMake 3.19 or higher is required` | CMake 版本不足（DEFER 机制需要 3.19+） | 确认 `LISTENAI_TOOLS_PATH/cmake/bin/cmake` 版本 ≥ 3.19 |
| `Board xxx not found` | 板型名拼写错误或路径未配置 | 检查 `-DBOARD=arcs_evb` 拼写（区分大小写）；自定义板型用 `-DBOARD_SEARCH_PATH=` |
| `find_package(listenai-cmake REQUIRED) failed` | `ARCS_BASE` 未设置或指向错误路径 | 确认 `ARCS_BASE` 指向包含 `cmake/listenai-cmake-config.cmake` 的 SDK 根目录 |
| `target_link_libraries` 找不到目标 | 模块未被 Kconfig 启用 | 检查 prj.conf 和 Kconfig 依赖链 |
| `NUCLEI_TOOLCHAIN_PATH` 相关 | 交叉编译工具链路径未设置 | build.sh 自动查找 `listenai-dev-tools/gcc/`；手动设置环境变量 |
| `Ninja not found` / `Generator not found` | 构建工具缺失 | 确认 `LISTENAI_TOOLS_PATH/ninja/ninja` 存在；或用 `-G Makefile` 替代 |

## 2. 编译期错误

| 症状 | 原因 | 解决 |
|------|------|------|
| `xxx.h: No such file or directory` | 头文件路径未加入 include | 在 CMakeLists.txt 中添加 `listenai_library_include_directories(...)` |
| `implicit declaration of function 'xxx'` | 缺少头文件包含 | 添加对应的 `#include <xxx.h>` |
| `incompatible pointer type` | 函数参数类型不匹配 | 检查函数签名和实际传参类型 |
| `'xxx' undeclared` / `use of undeclared identifier` | 宏未定义（Kconfig 未开启） | 在 prj.conf 中添加 `CONFIG_xxx=y` |
| `redefinition of 'xxx'` | 同名符号多次定义 | 检查头文件保护宏 `#ifndef`；确认函数是否应为 `static` |
| `expected ';'` / 语法错误 | C 语法问题 | 检查前一行是否缺少分号或括号 |
| `warning: unused variable` | 变量声明后未使用 | 删除未使用变量或用 `(void)var;` 消除警告 |
| `error: unknown type name 'xxx_t'` | 类型定义所在的头文件未包含 | 添加定义该类型的头文件 include |

## 3. 链接期错误

| 症状 | 原因 | 解决 |
|------|------|------|
| `undefined reference to 'xxx'` | 源文件未加入编译或 Kconfig 未开启 | 检查 `listenai_library_sources_ifdef` 条件；确认 prj.conf 中对应 CONFIG 已启用 |
| `multiple definition of 'xxx'` | 头文件中定义了非 static/inline 函数 | 改为 `static inline` 或将定义移到 .c 文件 |
| `section '.xxx' not found` | 自定义段 .ld.in 未通过 CMake 注册 | 在 CMakeLists.txt 中添加 `listenai_add_custom_section()` |
| 段内注册的条目为空 | 链接器优化掉了段内容 | 确保 .ld.in 中使用 `KEEP(*(SORT(...)))` |
| 符号排序异常 | 段名命名规则不统一 | 确保使用 `SORT()` + 统一命名格式 |
| `will not fit in region 'rom'` | ROM(FLASH) 空间不足 | 见下方"内存溢出分析" |
| `will not fit in region 'ram'` | RAM(SRAM) 空间不足 | 见下方"内存溢出分析" |
| `HEAP size is under the size limit!!!` | 链接脚本 ASSERT：可用堆内存小于 `__HEAP_SIZE_LIMIT` | 减小 RAM 中的其他分配（栈、BSS、数据段），或减小 `__HEAP_SIZE_LIMIT` |
| `error: wifi ram end must be less than 0x20000000 + 256 * 1024` | WIFI_RAM 区域越界 | WIFI_RAM 只能在 0x20000000 ~ 0x20040000；检查 `.wifi.noinit` 段大小 |
| `relocation truncated to fit` | 代码跳转距离超出指令范围（>±1MB） | 将高频调用函数放入 ILM/fast_text 区；或重新排列代码布局 |
| ABI mismatch: `xxx has float ABI, xxx does not` | FPU 配置不一致（ilp32f vs ilp32） | 确认所有库/目标文件使用相同 FPU 配置（`CONFIG_FPU=y/n`） |
| `Warning: custom linker section file not found` | `.ld.in` 文件路径错误 | 检查 `listenai_add_custom_section()` 中的路径是否使用绝对路径 `${CMAKE_CURRENT_SOURCE_DIR}/xxx.ld.in` |

### 内存溢出分析

**步骤 1: 启用内存使用打印（推荐）**

在 `prj.conf` 中添加：
```ini
CONFIG_PRINT_MEMORY_USAGE=y
```
编译时链接器会直接打印各内存区域的使用量：
```
Memory region         Used Size  Region Size  %age Used
          FLASH:      123456 B        8 MB      1.47%
           SRAM:       45678 B      384 KB     11.61%
```

**步骤 2: 读取 .map 文件**

```bash
# 查看各段大小汇总（段名 + 总大小）
grep -E "^\.(text|data|bss|rodata|fast)" build/<app_name>.map | head -30

# 查找 RAM 中最大的符号
grep -E "^\s+0x[0-9a-f]+\s+0x[0-9a-f]{4,}" build/<app_name>.map | sort -k2 -rn | head -20

# 查找特定模块的 ROM 占用
grep -E "build/.*\.c\.obj" build/<app_name>.map | head -30
```

**步骤 3: 读取 .symb 文件（更方便）**

编译输出的 `build/<app_name>.symb` 包含所有符号的详细信息（需 `CONFIG_COMPILE_OPTION_GENERATE_DEBUG_FILES=y`）：
```bash
# 按大小排序，找出最大符号
sort -k5 -rn build/<app_name>.symb | head -30
```

**常见优化手段**:

| 优化项 | 方法 | 节省 |
|--------|------|------|
| 减小主任务栈 | `CONFIG_MAIN_TASK_STACK_SIZE` 调小 | RAM |
| 减小日志缓冲 | `CONFIG_LOG_ASYNC_BUF_SIZE` 调小（默认 10240） | RAM |
| 减小 shell 栈 | `CONFIG_LISA_SHELL_TASK_STACK_SIZE` 调小（默认 1024） | RAM |
| 大常量加 const | `const uint8_t data[]` 放入 FLASH | RAM → ROM |
| 放入 PSRAM | `__attribute__((section(".psram.data")))` 大数据到 PSRAM | RAM |
| 移除未用模块 | 关闭 Kconfig 中不需要的 CONFIG | ROM + RAM |
| 启用 GC sections | `CONFIG_LINK_OPTION_GC_SECTIONS=y` 移除未用代码 | ROM |
| 压缩 nano libc | `CONFIG_LINK_OPTION_NANO_SPECS=y` 使用 newlib-nano | ROM |

## 4. Kconfig 依赖问题

**常见依赖链**:
```
LISA_XXX_DEVICE
  → depends on LISA_DEVICE
    → select LISA_OS
      → select MODULE_FREERTOS
```

**排查方法**:
1. 运行 `./build.sh -S <path> -t menuconfig -DBOARD=<board>` 检查选项可见性
2. 如果选项不可见，说明其 `depends on` 条件未满足
3. 在 Kconfig 文件中搜索该选项，检查依赖链上每个条件
4. 在 prj.conf 中逐一启用依赖项

**常见坑**:
- 直接在 prj.conf 中 `CONFIG_LISA_XXX_DEVICE=y` 但未满足依赖 → menuconfig 中选项隐藏，配置被忽略
- `select` 会自动启用目标，`depends on` 需要手动满足
- Kconfig 的 `bool`/`int`/`string` 类型需要正确的赋值格式

## 5. 烧录问题

| 症状 | 原因 | 解决 |
|------|------|------|
| `Cannot open /dev/ttyUSB0` | 串口不存在 | 检查 USB 连接，运行 `ls /dev/ttyUSB*` |
| `Permission denied: /dev/ttyUSB0` | 串口权限不足 | `sudo usermod -a -G dialout $USER`，重新登录 |
| `Failed opening device` | **串口被其他程序占用**（picocom、minicom、screen 等） | 关闭占用串口的终端程序再重试；可用 `fuser /dev/ttyACM0` 查找占用进程 |
| 超时 / 无响应 | 未进入 BOOT 模式 | **按住 BOOT 按键后复位开发板** |
| 超时 / 无响应 | 波特率过高 | 降低波特率: `-b 1500000` 或 `-b 921600` |
| 超时 / 无响应 | USB 线材问题 | 更换 USB 线或 USB 口 |
| 验证失败 | Flash 数据残留 | 先 `--erase-all` 再重新烧录 |
| 验证失败 | 传输不稳定 | 降低波特率重试 |
| eMMC 烧录失败 | SDIO 引脚未连接 | 检查 PA4~PA9 连接 |
| eMMC 烧录失败 | 存储器未供电 | 检查 eMMC/T卡 供电 |
| `No such file` (bin 文件) | 未编译或编译失败 | 先执行编译，确认 build/*.bin 存在 |

**波特率参考**:
- 稳定范围: 1500000 ~ 3000000（推荐）
- 快速开发: 6000000（部分环境不稳定）
- 排障降速: 921600

## 6. 串口问题

| 症状 | 原因 | 解决 |
|------|------|------|
| 完全无输出 | 波特率不匹配 | 终端设置为 **921600** |
| 完全无输出 | TX/RX 反接 | 交换 TX/RX 连线 |
| 完全无输出 | syslog backend 未启用 | 确认 `CONFIG_SYSLOG_UART_BACKEND=y` |
| 完全无输出 | 固件未运行 | 确认烧录成功并已复位 |
| 乱码 | 波特率不匹配 | 确认终端波特率与 `CONFIG_SYSLOG_UART_BAUDRATE` 一致 |
| 乱码 | 数据位/校验位错误 | 确认 **8N1**（8数据位、无校验、1停止位） |
| shell 不响应 | lisa_shell 未启用 | `CONFIG_LISA_SHELL=y` |
| shell 不响应 | stack size 不足 | 增大 `CONFIG_LISA_SHELL_TASK_STACK_SIZE` |
| shell 不响应 | UART 配置错误 | shell 依赖 syslog UART backend，确认 syslog 配置正确 |
| 日志级别不对 | 运行时级别限制 | 检查 `CONFIG_LOG_LEVEL_*`，设置为 DEBUG 或 VERBOSE |
| 部分日志丢失 | 异步缓冲区不足 | 增大 `CONFIG_LOG_ASYNC_BUF_SIZE` |

**串口连接参数速查**:

| 板型 | UART | 引脚 | 波特率 | 配置 |
|------|------|------|--------|------|
| arcs_evb | UART0 | PA2(RX) / PA3(TX) | 921600 | 8N1 |
| arcs_mini | UART0 | PB2(TX) | 921600 | 8N1 |

## 7. ARCS 芯片内存布局速查

> 来源: `startup/arcs/system.ld` + `soc/arcs/hal/chip/arcs/arch/flash.ld`

### SDK 默认链接脚本内存区域（system.ld）

| 别名 | 物理内存 | 起始地址 | 大小 | 用途 |
|------|----------|----------|------|------|
| ROM / FLASH | Flash | 由 memap.h 定义 | 8MB（典型） | 代码、只读数据、自定义段 |
| RAM / SRAM | SRAM | 由 memap.h 定义 | 384KB（典型） | 数据段、BSS、堆、栈 |
| ITCM / ILM | ILM | 由 memap.h 定义 | 16KB | 高频中断处理代码（最快访问） |
| DTCM / DLM | DLM | 由 memap.h 定义 | 8KB | 时间敏感数据（最快访问） |
| PSRAM | PSRAM | 由 memap.h 定义 | 大容量 | 大缓冲区、LVGL 资源 |
| WIFI_RAM | WIFI RAM | 0x20000000 | 256KB | WIFI 栈专用（约束：不可超出此范围） |
| LUNA_RAM | LUNA RAM | 由 memap.h 定义 | - | 共享内存（sharedmem 段） |
| BTRAM / RAM_BT | BT RAM | 由 memap.h 定义 | - | 蓝牙栈专用 |

### 段名到内存区域的映射（代码放置指引）

| 属性/段名 | 放置位置 | 用途 |
|-----------|----------|------|
| 普通函数（默认） | ROM | 从 Flash 执行（XIP 不适用时复制到 SRAM） |
| `__attribute__((section(".itcm_text")))` | ITCM | 中断处理、高频调用（最低延迟） |
| `__attribute__((section(".ramcode")))` 或 `.fast_text` | SRAM | RAM 执行代码（比 Flash 快） |
| `__attribute__((section(".fast_data")))` | SRAM | 快速访问数据 |
| `__attribute__((section(".dtcm")))` | DTCM | 时间敏感变量 |
| `__attribute__((section(".psram.text")))` | PSRAM | 不常访问的大型代码（如 LVGL） |
| `__attribute__((section(".psram.data")))` | PSRAM | 大型数据（图片资源等） |
| `__attribute__((section(".noinit")))` | SRAM | 不初始化变量（重启保留） |

### 自定义段 .ld.in 模板

```ld
/* .ld.in 存储段示例 */

/* 放入 ROM（Flash）*/
.my_section : {
    . = ALIGN(4);
    __my_section_start = .;
    KEEP (*(SORT(.my_section.*)))
    __my_section_end = .;
} >ROM AT>ROM

/* 初始化数据放入 RAM（Flash 中存储，运行时从 Flash 复制到 RAM）*/
.my_ram_data : {
    . = ALIGN(4);
    __my_ram_data_start = .;
    KEEP (*(.my_ram_data.*))
    __my_ram_data_end = .;
} >RAM AT>ROM

/* 不初始化放入 RAM（NOLOAD：不占用 Flash）*/
.my_bss (NOLOAD) : {
    . = ALIGN(4);
    __my_bss_start = .;
    KEEP (*(.my_bss.*))
    __my_bss_end = .;
} >RAM
```

### 常见 CMakeLists.txt 模式

```cmake
cmake_minimum_required(VERSION 3.13)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
find_package(listenai-cmake REQUIRED HINTS $ENV{ARCS_BASE})
project(my_app)

# 头文件（全局可见）
listenai_include_directories(include/)

# 子目录（先于 listenai_add_executable）
add_subdirectory(src)

# 可执行目标（必须在库定义之后）
listenai_add_executable(${PROJECT_NAME})

# 直接链接外部库（mbedtls、lvgl 等）
listenai_link_libraries(mbedtls)

# 自定义内存段
listenai_add_custom_section(${CMAKE_CURRENT_SOURCE_DIR}/my_sections.ld.in)
```

**CMakeLists.txt 常见错误**:
- `listenai_add_executable` 必须在所有 `add_subdirectory` **之后**（listenai 宏内部使用 DEFER，顺序灵活，但惯例上后置）
- `listenai_library_named` 必须在 `listenai_library_sources` 之前
- `listenai_add_custom_section` 的路径必须是绝对路径

### Kconfig 配置文件优先级（高到低）

```
CMake 命令行 -DCONFIG_xxx=y    ← 最高优先级（覆盖所有）
prj.conf (APPLICATION_SOURCE_DIR)
.config (构建目录 build/.config)  ← menuconfig 保存结果
SDK 默认值 (Kconfig default)      ← 最低优先级
```

> **注意**: 命令行 `-DCONFIG_xxx=y` 写入 `build/misc/generated/extra_kconfig_options.conf`，优先级最高，便于 CI 覆盖配置。
