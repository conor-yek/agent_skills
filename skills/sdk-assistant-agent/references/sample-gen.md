# ARCS 样例代码生成

生成符合 ARCS SDK 规范的完整示例项目，覆盖驱动、模块、网络、蓝牙等各类场景。

---

## Step 1: 需求确认

向用户确认以下信息（不明确时询问）：

| 信息 | 默认值 | 说明 |
|------|--------|------|
| **功能目标** | — | 要演示什么：哪个驱动/组件/模块，什么场景 |
| **样例路径** | — | 建议放在哪个分类下（见下方分类规则） |
| **样例名称** | — | 目录名（snake_case，简洁描述功能） |
| **目标板型** | arcs_evb | arcs_evb 或 arcs_mini |

### 样例分类规则

```
samples/
├── drivers/devices/{lisa_xxx}/{feature}/   # 设备驱动类（lisa_gpio、lisa_uart等）
├── drivers/hal/{peripheral}/               # HAL 层直接使用类
├── modules/{module_name}/                  # 第三方模块类（cjson、sqlite3等）
├── network/{feature}/                      # 网络类（http、wifi、websocket等）
├── bluetooth/{feature}/                    # 蓝牙类（ble_peripheral、ble_broadcaster等）
├── algorithms/{feature}/                   # 算法类
└── cpp/{feature}/                          # C++ 特性类
```

---

## Step 2: 读取参考样例

在生成代码前，**必须先读取**最相关的现有样例作为参考：

| 目标功能 | 参考样例路径 |
|----------|------------|
| GPIO 操作 | `samples/drivers/devices/lisa_gpio/output_basic/` |
| UART 收发 | `samples/drivers/devices/lisa_uart/poll_out/` 或 `recv_sync_int/` |
| SPI 通信 | `samples/drivers/devices/lisa_spi/master/` |
| I2C 通信 | `samples/drivers/devices/lisa_i2c/` |
| Flash 读写 | `samples/drivers/devices/lisa_flash/` |
| BLE 功能 | `samples/bluetooth/ble_peripheral/` |
| WiFi/HTTP | `samples/network/http/` |
| 第三方模块 | `samples/modules/cjson/` |
| 最简骨架 | `samples/helloworld/` |

同时查阅 `references/knowledge/online-docs.md` 中的 URL 映射，用 WebFetch 获取目标驱动/组件的在线文档。

---

## Step 3: 生成文件

按以下顺序生成所有文件。

### 3.1 CMakeLists.txt

**模式 A: 单源文件（最常见）**
```cmake
cmake_minimum_required(VERSION 3.13)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(listenai-cmake REQUIRED HINTS $ENV{ARCS_BASE})

project(arcs)

listenai_add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE src/main.c)
```

**模式 B: 多源文件（含 include 目录）**
```cmake
cmake_minimum_required(VERSION 3.13)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(listenai-cmake REQUIRED HINTS $ENV{ARCS_BASE})

project(arcs)

listenai_include_directories(src)

listenai_add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE
    src/main.c
    src/xxx.c
)
```

**模式 C: 子目录 + 外部库**
```cmake
cmake_minimum_required(VERSION 3.13)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(listenai-cmake REQUIRED HINTS $ENV{ARCS_BASE})

project(arcs)

listenai_include_directories(./)

add_subdirectory(src)

listenai_add_executable(${PROJECT_NAME})
listenai_link_libraries(mbedtls)   # 按需添加
```

**选择规则：** 源文件 ≤ 2 个用模式 A；有 include 子目录或多源用模式 B；需要链接第三方库（mbedtls 等）用模式 C。

---

### 3.2 Kconfig

所有样例统一内容：

```kconfig
osource "$ARCS_BASE/Kconfig"


```

---

### 3.3 prj.conf

**推导原则：读参考样例，不要猜。**

```
1. 读取 Step 2 选定的参考样例的 prj.conf（直接复制为基础）
2. 若参考样例不完整，Read drivers/lisa_{xxx}/Kconfig 查看 depends on 链
3. 网络/BLE 类：WebFetch 对应组件文档获取依赖配置
   - 网络: components/lisa_wifi/README.html + components/lisa_net/README.html
   - BLE:  components/lisa_bluetooth/README.html
```

**驱动类最小配置规律（从 Kconfig 依赖链提取）:**
- 所有驱动均需: `CONFIG_LISA_DEVICE=y`
- 驱动主开关: `CONFIG_LISA_{DRIVER}_DEVICE=y`（如 `CONFIG_LISA_GPIO_DEVICE=y`）
- 实例开关: `CONFIG_LISA_{DRIVER}{N}=y`（如 `CONFIG_LISA_GPIOA=y`）
- 具体 CONFIG 名称以 `Read drivers/lisa_{xxx}/Kconfig` 为准

---

### 3.4 sample.yaml

```yaml
tests:
  samples.{category}.{sample_name}:    # 如 samples.lisa_gpio.output_basic
    programmer: arcs
    runner: uart
    log_analyzer:
      type: "regex"
      pattern: "{首条关键日志，如 LED is ON}"
```

**命名规则：** `samples.{driver/category}.{feature}`，全小写，点分隔。

---

### 3.5 src/main.c

#### 驱动类样例模板

```c
/*
 * Copyright (c) 2025, LISTENAI
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @file main.c
 * @brief LISA {DRIVER} {功能}示例
 *
 * {可选：1-2行补充说明}
 */

#define LOG_TAG "sample"
#include <lisa_log.h>

#include <stdio.h>
#include <string.h>
#include "lisa_device.h"
#include "lisa_{driver}.h"
#include "IOMuxManager.h"
#include "FreeRTOS.h"
#include "task.h"

#define {DRIVER}_DEVICE    "{device_name}"   /* 如 "uart1", "spi0", "gpiob" */

/* 引脚定义（按实际硬件填写） */
#define {DRIVER}_TX_PAD    CSK_IOMUX_PAD_B
#define {DRIVER}_TX_PIN    2
#define {DRIVER}_FUNC      CSK_IOMUX_FUNC_ALTER3

/*
    为满足不同板型示例场景，重定向设备的 pinmux 配置
*/
#ifdef CONFIG_BOARD_ARCS_EVB
void lisa_{device_name}_pinmux()
{
    IOMuxManager_PinConfigure({DRIVER}_TX_PAD, {DRIVER}_TX_PIN, {DRIVER}_FUNC);
    /* 添加更多引脚... */
}
#endif

int main(int argc, char **argv)
{
    LISA_LOGI(LOG_TAG, "=== LISA {DRIVER} {功能} example ===");

    /* 1. 获取设备 */
    lisa_device_t *dev = lisa_device_get({DRIVER}_DEVICE);
    if (!lisa_device_ready(dev)) {
        LISA_LOGE(LOG_TAG, "Error: %s device not ready", {DRIVER}_DEVICE);
        return -1;
    }
    LISA_LOGI(LOG_TAG, "%s device ready", {DRIVER}_DEVICE);

    /* 2. 配置设备 */
    lisa_{driver}_config_t config = LISA_{DRIVER}_CONFIG_DEFAULT();
    int ret = lisa_{driver}_configure(dev, &config);
    if (ret != LISA_DEVICE_OK) {
        LISA_LOGE(LOG_TAG, "Error: configure failed (ret=%d)", ret);
        return -1;
    }

    /* 3. 主循环 */
    while (1) {
        /* TODO: 核心逻辑 */
        vTaskDelay(pdMS_TO_TICKS(1000));
    }

    return 0;
}
```

#### main.c 关键约定

| 约定 | 规则 |
|------|------|
| LOG_TAG | `#define LOG_TAG "sample"` 置于所有 include 之前 |
| 首条日志 | `LISA_LOGI(LOG_TAG, "=== {Title} ===");` |
| 设备获取 | `lisa_device_get()` 后立即 `lisa_device_ready()` 检查 |
| 错误处理 | `return -1` 或打印错误后继续（视场景） |
| 延时 | `vTaskDelay(pdMS_TO_TICKS(ms))` |
| Pinmux 覆盖 | `#ifdef CONFIG_BOARD_ARCS_EVB` + `void lisa_{device}_pinmux()` |
| 日志宏 | LISA_LOGI / LISA_LOGE / LISA_LOGW / LISA_LOGD（不是 LOGI/LOGE） |

#### 回调/中断场景补充

```c
/* 回调函数（ISR 安全：不能使用阻塞 API，用 FromISR 版本） */
static void {driver}_event_callback({driver}_event_t event, void *user_data)
{
    if (event == LISA_{DRIVER}_EVENT_TX_DONE) {
        /* 通知主任务（使用 FromISR 变体） */
        lisa_semaphore_give_from_isr(tx_done_sem);
    }
}
```

---

### 3.6 README.md

遵循 `samples/drivers/devices/Devices_Samples_Spec.md` 规范，基础模板：

```markdown
# LISA {DRIVER} {功能}示例

## 功能说明

演示如何使用 {描述核心功能，1-2句话}。

## 硬件连接

- **{引脚}**: {功能说明}
- **{引脚}**: {功能说明}

## 示例步骤

1. {步骤1}
2. {步骤2}
3. {步骤3}

## 编译运行

```bash
./build.sh -C -DBOARD=arcs_evb
```

## 预期输出

**终端输出：**
```
=== LISA {DRIVER} {功能} example ===
{具体输出内容}
```

## 核心 API

| API | 说明 |
|-----|------|
| `lisa_device_get()` | 获取设备 |
| `lisa_{driver}_configure()` | 配置设备参数 |
| ...  | ... |

## 注意事项

1. **{关键点}**：{说明}
```

高级样例（有复杂特性）在功能说明后加 `### 新特性` 小节。

---

## Step 4: 质量检查

生成代码后逐项验证：

**CMakeLists.txt**
- [ ] `cmake_minimum_required(VERSION 3.13)` 首行
- [ ] `find_package(listenai-cmake REQUIRED HINTS $ENV{ARCS_BASE})`
- [ ] `listenai_add_executable(${PROJECT_NAME})` 使用正确宏
- [ ] 源文件路径正确

**Kconfig**
- [ ] 仅含 `osource "$ARCS_BASE/Kconfig"`

**prj.conf**
- [ ] 驱动类：包含 `CONFIG_LISA_DEVICE=y`
- [ ] 设备实例 CONFIG 已启用（如 `CONFIG_LISA_UART1=y`）
- [ ] 网络类：LWIP / WiFi / LISA_WIFI 等基础配置完整
- [ ] BLE 类：BLE 依赖 WiFi 的 RF 初始化（`CONFIG_LISA_WIFI=y`）

**sample.yaml**
- [ ] test key 格式：`samples.{cat}.{name}`（全小写，点分隔）
- [ ] pattern 与 main.c 中的日志输出匹配

**main.c**
- [ ] `#define LOG_TAG "sample"` 在最前
- [ ] 版权头信息完整（Copyright 2025 LISTENAI）
- [ ] `lisa_device_ready()` 检查在 `lisa_device_get()` 之后
- [ ] `#ifdef CONFIG_BOARD_ARCS_EVB` pinmux 覆盖函数存在（涉及引脚时）
- [ ] 回调函数中不使用阻塞 FreeRTOS API
- [ ] 错误处理完整（每个 API 调用都检查返回值）

**README.md**
- [ ] 标题格式符合规范
- [ ] 编译命令：`./build.sh -C -DBOARD=arcs_evb`
- [ ] 预期输出与 main.c 实际日志一致
- [ ] API 名称用反引号标注

---

## Step 5: 输出说明

生成完成后告知用户：

1. **文件清单**：生成了哪些文件，放在哪里
2. **构建命令**：
   ```bash
   ./build.sh -C -S samples/{path} -DBOARD=arcs_evb
   ```
3. **build.sh 来源**：告知直接从任意相邻样例复制 `build.sh`（内容相同，无需修改）
4. **需要用户确认的信息**：引脚编号、设备实例号（uart0/uart1等）、WiFi 账号密码等用 `TODO` 标注的内容
