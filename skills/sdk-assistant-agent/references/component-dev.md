# ARCS 组件开发辅助

帮助开发者创建符合 ARCS SDK 规范的功能组件。

## 执行流程

### Step 1: 确认组件定位

向用户确认（不明确时询问）：

| 信息 | 说明 |
|------|------|
| **组件名称** | snake_case，如 `lisa_xxx` |
| **功能目标** | 组件做什么，对外提供哪些能力 |
| **依赖** | 依赖哪些驱动/其他组件 |
| **是否需要 evt_pub** | 是否需要事件发布订阅 |

### Step 2: 加载参考资源

```
并行加载:
① Glob components/lisa_*/CMakeLists.txt → 选择最相关的组件
② Read 选中组件的 CMakeLists.txt + Kconfig + 头文件 → 结构参考
③ Read references/knowledge/sdk-patterns.md → 组件 CMake 模式、evt_pub 用法
④ Read references/knowledge/conventions.md → 编码约定
```

### Step 3: 生成骨架文件

按以下结构生成：

```
components/lisa_xxx/
├── include/
│   └── lisa_xxx.h       # 公共 API 头文件
├── lisa_xxx.c           # 实现
├── CMakeLists.txt       # listenai_library_named(module_lisa_xxx)
├── Kconfig              # menuconfig LISA_XXX + 子选项
└── README.md            # 文档（可选，按需生成）
```

**CMakeLists.txt 模板：**
```cmake
listenai_library_named(module_lisa_xxx)
listenai_library_sources_ifdef(CONFIG_LISA_XXX lisa_xxx.c)
target_include_directories(module_lisa_xxx PUBLIC include)
```

**Kconfig 模板：**
```kconfig
menuconfig LISA_XXX
    bool "Enable LISA XXX Component"
    default n
    help
        Enable LISA XXX component.

if LISA_XXX
# 子配置项
endif
```

### Step 4: 验证

- [ ] CMake target 使用 `listenai_library_named` + `listenai_library_sources_ifdef`
- [ ] Kconfig 选项与 CMake 条件编译一致
- [ ] 头文件有 `#pragma once` 和 C++ 兼容保护
- [ ] 若使用 evt_pub，确认回调签名与 `lisa_evt_pub` API 一致
