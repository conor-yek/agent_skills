# ARCS 代码审查

按 ARCS SDK 规范对代码进行基础审查。

## 执行流程

### Step 1: 加载审查基准

```
并行读取:
- references/knowledge/conventions.md → 编码约定（命名、日志、错误码）
- references/knowledge/driver-patterns.md → 驱动模式（vtable、注册、inline 包装）
```

### Step 2: 收集待审查代码

```
1. 若用户指定了文件 → Read 对应文件
2. 若用户说"审查当前改动" → git diff HEAD 获取变更
3. 若用户提供了 PR → gh pr diff 获取变更
```

### Step 3: 逐维度检查

对照 conventions.md 和 driver-patterns.md，检查以下维度：

| 维度 | 检查项 |
|------|--------|
| **SDK 约定** | `#define LOG_TAG` 在 include 前；使用 `LISA_LOGI(LOG_TAG, ...)` 形式；头文件 `#pragma once` 或 `#ifndef` 保护 |
| **API 设计** | vtable 中每个函数指针有对应 `static inline` 包装；包装含 `!dev \|\| !dev->api` 检查；无支持时返回 `LISA_DEVICE_ERR_NOT_SUPPORT` |
| **线程安全** | 回调/ISR 中不使用阻塞 FreeRTOS API（用 `_from_isr` 变体）；共享数据有互斥保护 |
| **内存安全** | DMA 缓冲区对齐；动态分配有释放路径；栈变量不传递给异步操作 |
| **构建集成** | `listenai_library_sources_ifdef` 做条件编译；Kconfig `depends on LISA_DEVICE`；CMake 路径使用 `${CMAKE_CURRENT_SOURCE_DIR}` |

### Step 4: 输出审查报告

```
格式:
- 按严重程度分类: 🔴 错误 / 🟡 警告 / 🔵 建议
- 每条包含: 文件:行号、问题描述、修复建议
- 结尾汇总: N 个错误 / M 个警告 / K 个建议
```
