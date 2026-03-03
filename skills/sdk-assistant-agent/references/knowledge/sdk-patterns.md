# ARCS SDK 设计模式详解

## 1. 设备注册模式 (Section-Based Auto Registration)

核心思想：利用 ELF 自定义段实现编译时注册，运行时自动发现。

### 注册侧
```c
// 1. 定义设备实例 + 注册条目，放入 .lisa_device_registry.XX 段
LISA_DEVICE_REGISTER(
    device_name,          // 设备名（唯一标识，也是字符串名称）
    &device_api,          // API vtable 指针
    &device_priv_data,    // 私有数据
    NULL,                 // 用户数据（可选）
    device_init_fn,       // 初始化函数 int (*)(void)
    LISA_DEVICE_PRIORITY_NORMAL  // 优先级 0-99
);
```

### 发现侧
```c
// 链接器提供段起止符号
extern lisa_device_registry_entry_t __lisa_device_registry_start[];
extern lisa_device_registry_entry_t __lisa_device_registry_end[];

// lisa_device_init() 遍历段，按优先级排序后依次调用 init_fn
// lisa_device_get("name") 按名称查找，自动增加引用计数
```

### 链接脚本片段 (.ld.in)
```ld
.lisa_device_registry : {
    . = ALIGN(4);
    __lisa_device_registry_start = .;
    KEEP (*(SORT(.lisa_device_registry.*)))
    __lisa_device_registry_end = .;
} >ROM AT>ROM
```

### CMake 集成
```cmake
listenai_add_custom_section(${CMAKE_CURRENT_SOURCE_DIR}/lisa_device.ld.in)
```

## 2. API Vtable 多态模式

每个设备类型定义自己的 API 结构体（函数指针表），通过 `lisa_device_t.api` 实现多态。

```c
// 头文件中定义
typedef struct {
    int (*configure)(lisa_device_t *dev, const xxx_config_t *config);
    int (*operation_a)(lisa_device_t *dev, ...);
    int (*operation_b)(lisa_device_t *dev, ...);
} xxx_api_t;

// 提供 inline 包装（类型安全 + 空指针检查）
static inline int xxx_configure(lisa_device_t *dev, const xxx_config_t *config) {
    if (!dev || !dev->api) return LISA_DEVICE_ERR_INVALID;
    xxx_api_t *api = (xxx_api_t *)dev->api;
    return api->configure ? api->configure(dev, config) : LISA_DEVICE_ERR_NOT_SUPPORT;
}
```

## 3. 事件发布订阅模式

组件目录: `components/lisa_evt_pub/`，API 函数前缀: `lisa_evt_publisher_*`

```c
// 创建发布器
lisa_evt_publisher_t pub = lisa_evt_publisher_new();    // BIT 位匹配
lisa_evt_publisher_t pub = lisa_evt_publisher_new_eq(); // 数值精确匹配

// 订阅
lisa_evt_publisher_evt_add(pub, EVT_DATA_READY, my_callback, user_ctx);

// 取消订阅
lisa_evt_publisher_cb_remove(pub, EVT_DATA_READY, my_callback);

// 发布
lisa_evt_publisher_publish(pub, EVT_DATA_READY, data, data_len);

// 查询是否有订阅者
lisa_evt_publisher_has_subscriber(pub, EVT_DATA_READY);

// 清除所有订阅 / 销毁
lisa_evt_publisher_clear(pub);
lisa_evt_publisher_destroy(pub);

// 回调签名
void my_callback(uint32_t evt, void *data, uint32_t data_len, void *user_data);
```

## 4. 多级系统初始化模式

```c
// sys_init.ld.in 定义 5 个初始化级别，每级支持 0-99 子优先级
// Level 0: SYS_INIT_LEVEL_PRE_SYSTEM_INIT    — 无全局变量，最早执行
// Level 1: SYS_INIT_LEVEL_PRE_DEVICES_INIT   — lisa_device_init() 之前
// Level 2: SYS_INIT_LEVEL_PRE_KERNEL         — FreeRTOS 调度器启动前
// Level 3: SYS_INIT_LEVEL_POST_KERNEL        — 调度器启动后
// Level 4: SYS_INIT_LEVEL_PRE_APPLICATION    — main() 之前

// 注册方式
SYS_INIT(my_init_fn, SYS_INIT_LEVEL_POST_KERNEL, 50);
```

## 5. 组件 CMake 模式

```cmake
# 标准组件 CMakeLists.txt
listenai_library_named(module_xxx)
listenai_library_sources(src/xxx.c)
listenai_library_sources_ifdef(CONFIG_XXX_FEATURE_A src/feature_a.c)
target_include_directories(module_xxx PUBLIC include)
```

## 6. Sample 项目模式

```cmake
# 标准 sample CMakeLists.txt
cmake_minimum_required(VERSION 3.13)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
find_package(listenai-cmake REQUIRED HINTS $ENV{ARCS_BASE})
project(sample_name)
listenai_add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE src/main.c)
```

配置文件: `prj.conf` 启用所需 Kconfig 选项。
