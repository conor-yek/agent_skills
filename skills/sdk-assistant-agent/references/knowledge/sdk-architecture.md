# ARCS SDK 架构全景图

## 分层架构

```
┌─────────────────────────────────────────────┐
│            Application (samples/)            │
├─────────────────────────────────────────────┤
│         Components (components/)             │
│  lisa_os │ lisa_log │ lisa_evt_pub │ lisa_kv  │
│  lisa_net│ lisa_http│ lisa_wifi    │ work_queue│
├─────────────────────────────────────────────┤
│           Drivers (drivers/)                 │
│  lisa_device (基类框架)                       │
│  uart│spi│i2c│gpio│flash│display│adc│pwm│...│
├─────────────────────────────────────────────┤
│          Modules (modules/)                  │
│  FreeRTOS│lwIP│mbedtls│lvgl│cjson│sqlite│...│
├─────────────────────────────────────────────┤
│           SoC HAL (soc/arcs/)                │
├─────────────────────────────────────────────┤
│          Board (boards/arcs_evb/)            │
├─────────────────────────────────────────────┤
│         Startup (startup/arcs/)              │
│  system.c → sysmain.c → main()              │
└─────────────────────────────────────────────┘
```

## 启动流程

```
Reset
  → SystemInit() [system.c]        # Level 0: PRE_SYSTEM_INIT
  → scatload (数据段加载)
  → sys_init Level 1               # SYS_INIT_LEVEL_PRE_DEVICES_INIT
  → lisa_device_init()             # 自动注册所有设备
  → sys_init Level 2               # SYS_INIT_LEVEL_PRE_KERNEL
  → vTaskStartScheduler()          # FreeRTOS 启动
  → sys_init Level 3               # SYS_INIT_LEVEL_POST_KERNEL
  → sys_init Level 4               # SYS_INIT_LEVEL_PRE_APPLICATION
  → main() [用户代码]
注册方式: SYS_INIT(init_fn, level, sub_priority)
```

## 构建系统

```
CMakeLists.txt (项目根)
  → find_package(listenai-cmake)   # 加载构建系统
  → listenai_add_executable()      # 创建可执行目标
  → target_sources()               # 添加用户源文件
  ↓
cmake/extensions.cmake             # 核心宏定义
  → listenai_find_modules()        # 自动发现模块
  → listenai_library_named()       # 创建库目标
  → listenai_add_custom_section()  # 自定义链接段
  ↓
Kconfig → autoconf.h               # 配置→编译常量
  → CONFIG_XXX=y → #define CONFIG_XXX 1
```
