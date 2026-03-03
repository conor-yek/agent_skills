# 驱动开发模式与模板

## 标准驱动文件结构

```
drivers/lisa_xxx/
├── CMakeLists.txt          # 构建配置
├── Kconfig                 # 配置选项
├── include/
│   └── lisa_xxx.h          # 公共 API 头文件（vtable + inline 包装）
├── lisa_xxx_arcs.c         # ARCS 平台适配层实现
└── lisa_xxx.ld.in          # 自定义段（如需要）
```

## CMakeLists.txt 模板

```cmake
listenai_library_named(module_lisa_xxx)
listenai_library_sources_ifdef(CONFIG_LISA_XXX_DEVICE lisa_xxx_arcs.c)
target_include_directories(module_lisa_xxx PUBLIC include)
```

## Kconfig 模板

```kconfig
menuconfig LISA_XXX_DEVICE
    bool "Enable LISA XXX Driver"
    default n
    depends on LISA_DEVICE
    help
        Enable LISA XXX device driver.

if LISA_XXX_DEVICE
config LISA_XXX_BUFFER_SIZE
    int "Buffer size"
    default 256
endif
```

## 头文件模板 (lisa_xxx.h)

关键要素:
1. 配置结构体 `lisa_xxx_config_t`
2. 事件枚举 `lisa_xxx_event_t`（如需回调）
3. 回调类型 `lisa_xxx_callback_t`（如需回调）
4. API vtable `lisa_xxx_api_t`
5. inline 包装函数（含空指针检查和 ERR_NOT_SUPPORT 兜底）

## 平台适配层模板 (lisa_xxx_arcs.c)

关键要素:
1. 私有数据结构体（存放运行时状态）
2. 实现 API vtable 中的所有函数
3. 填充静态 API 实例
4. 使用 `LISA_DEVICE_REGISTER` 注册

## 常见陷阱

- 忘记在 Kconfig 中添加 `depends on LISA_DEVICE`
- vtable 函数指针为 NULL 时未在 inline 包装中兜底
- 中断回调中使用了非 ISR 安全的 FreeRTOS API
- DMA 传输时未检查内存对齐
- 忘记在 CMakeLists.txt 中用 `_ifdef` 做条件编译
