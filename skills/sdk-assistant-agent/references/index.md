# SDK 开发助手系统全景图

AI 读此文件即可了解整个 skill 体系的结构、文件职责和加载时机，无需遍历目录。

---

## 文件角色定义

| 角色 | 说明 |
|------|------|
| `[ROUTER]` | 意图识别 + 路由，自身不产生实质输出 |
| `[WORKER]` | 执行特定领域任务，产生代码/文档等输出 |
| `[REFERENCE]` | 被动知识库，由 worker 按需加载，不主动读取 |
| `[META]` | 关于 skill 系统本身的维护指令，仅在编辑/进化 skill 时使用 |

---

## 入口层

| 文件 | 角色 | 职责 |
|------|------|------|
| `SKILL.md` | `[ROUTER]` | 意图识别，路由到对应 worker |

---

## Worker 层

按需读取，不预加载。

| 文件 | 角色 | 职责 |
|------|------|------|
| `references/driver-dev.md` | `[ROUTER]` | 识别目标设备，路由到具体驱动 worker |
| `references/build-debug.md` | `[WORKER]` | 编译构建、固件烧录、串口调试、故障诊断 |
| `references/sample-gen.md` | `[WORKER]` | 生成完整示例项目（CMakeLists / prj.conf / Kconfig / main.c / README） |
| `references/code-review.md` | `[WORKER]` | SDK 代码审查，检查编码规范、API 使用、内存安全（基础） |
| `references/component-dev.md` | `[WORKER]` | 组件骨架生成（基础） |
| `references/doc-writing.md` | `[WORKER]` | 文档编写/修复，覆盖 README、在线文档、构建告警 |

### 驱动设备 Worker（由 `references/driver-dev.md` 路由）

| 文件 | 设备 | 主要场景 |
|------|------|----------|
| `references/drivers/lisa_gpio.md` | GPIO | 输入/输出/中断引脚 |
| `references/drivers/lisa_uart.md` | UART | 轮询/中断/DMA 收发 |
| `references/drivers/lisa_spi.md` | SPI | Master/Slave 通信 |
| `references/drivers/lisa_i2c.md` | I2C | Master 通信、从机扫描 |
| `references/drivers/lisa_flash.md` | Flash | NOR Flash 读写擦除 |
| `references/drivers/lisa_adc.md` | ADC | 模数转换、采样 |
| `references/drivers/lisa_pwm.md` | PWM | 占空比、脉宽调制 |
| `references/drivers/lisa_hwtimer.md` | HWTIMER | 硬件定时器、GPT、AON |
| `references/drivers/lisa_rtc.md` | RTC | 实时时钟、闹钟 |
| `references/drivers/lisa_wdt.md` | WDT | 看门狗 |
| `references/drivers/lisa_sdmmc.md` | SDMMC | SD 卡、MMC、TF 卡 |
| `references/drivers/lisa_i2s.md` | I2S | 音频接口、PCM 流 |
| `references/drivers/lisa_display.md` | Display | 显示屏、LCD 刷屏、LVGL |
| `references/drivers/lisa_touch.md` | Touch | 触摸/触控 |
| `references/drivers/lisa_audio.md` | Audio | 录音/播放/Codec/AEC |
| `references/drivers/lisa_qspilcd.md` | QSPI LCD | 四线 LCD |
| `references/drivers/lisa_dvp.md` | DVP | 摄像头接口 |
| `references/drivers/lisa_camera.md` | Camera | 摄像头/Sensor |
| `references/drivers/lisa_rgb.md` | RGB | LED 灯带、WS2812、SK6812 |
| `references/drivers/pinmux.md` | Pinmux | 引脚复用、IOMUX |

---

## Knowledge 层（Reference）

被动引用，由 worker 在需要时加载。主 SKILL.md **不预加载**这些文件。

| 文件 | 内容 | 适用 worker |
|------|------|-------------|
| `references/knowledge/conventions.md` | 编码约定（命名、日志宏、错误码、Kconfig 规范） | driver-dev、sample-gen、component-dev、code-review |
| `references/knowledge/driver-patterns.md` | 驱动开发模式（vtable、inline 包装、设备注册） | driver-dev、code-review |
| `references/knowledge/sdk-patterns.md` | SDK 通用模式（SYS_INIT、evt_pub、work_queue） | component-dev、code-review |
| `references/knowledge/sdk-architecture.md` | SDK 分层架构、启动流程、内存布局 | 架构类问题 |
| `references/knowledge/build-issues.md` | 已知构建/链接问题模式及解决方案 | build-debug |
| `references/knowledge/online-docs.md` | 在线文档 URL 索引（驱动/组件/板型/示例） | 任何需要在线文档时 |
| `references/knowledge/evolution-log.md` | Agent 进化历史记录 | `[META]` evolution 专用 |

---

## Meta 层

仅在维护 skill 系统本身时使用，日常任务执行中**不需要加载**。

| 文件 | 用途 |
|------|------|
| `references/design-principles.md` | skill 设计原则，编写/修改任何 skill 文件前必读 |
| `references/evolution.md` | `[META/WORKER]` Agent 自我进化流程：审计知识库、优化 prompt、沉淀模式 |

---

## 路径说明

所有相对路径均以 `sdk-assistant-agent/` 为根目录计算。
例：worker 文件引用 `references/knowledge/build-issues.md`，完整路径为 `skills/sdk-assistant-agent/references/knowledge/build-issues.md`。
