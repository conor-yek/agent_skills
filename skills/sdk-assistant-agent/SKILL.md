---
name: sdk-assistant-agent
description: >
  ARCS SDK / LISTENAI SDK 开发助手统一入口。当用户在此 SDK 工程中进行任何开发任务时触发，包括但不限于：
  驱动开发（LISA_DEVICE_REGISTER、API vtable、外设驱动、UART/SPI/I2C/GPIO/Flash/Display）、
  构建调试（CMake 编译错误、链接失败、Kconfig/menuconfig、map 文件、内存不足、编译烧录串口）、
  样例生成（怎么用 xxx、写个 demo/sample、使用示例）、
  组件开发（lisa_os、lisa_evt_pub、work_queue、新组件、新模块）、
  代码审查（review、检查代码、PR）、
  SDK 架构问题（SYS_INIT、FreeRTOS、ELF 段、链接脚本、自定义段）。
  凡涉及 arcs_mini、arcs_evb 板型，或 listenai_library、listenai_add_executable 等 CMake 宏的问题，均应触发此 skill。
compatibility: Designed for Claude Code in LISTENAI ARCS SDK repositories
allowed-tools: Read Glob Grep Bash WebFetch
---

# SDK 开发助手

> 系统全景图（文件职责、角色分类、加载时机）：`references/index.md`

## 意图识别与路由

分析用户输入，匹配领域，读取对应 worker 文件执行：

| 领域 | 触发信号 | 读取并执行 |
|------|----------|------------|
| **驱动开发** | 新驱动、设备注册、LISA_DEVICE、API vtable、外设、lisa_xxx 使用/移植 | `references/driver-dev.md` |
| **构建调试** | 编译/链接错误、CMake、Kconfig、menuconfig、烧录、串口日志、内存溢出 | `references/build-debug.md` |
| **样例生成** | 写示例、demo、sample、怎么用 xxx、使用方法 | `references/sample-gen.md` |
| **代码审查** [基础] | review、审查、检查代码、这段代码有问题吗、PR | `references/code-review.md` |
| **组件开发** [基础] | 新组件、新模块、evt_pub、work_queue、封装、抽象层 | `references/component-dev.md` |
| **文档编写** | 写文档、README、在线文档错误、toctree、文档发布、构建 warning | `references/doc-writing.md` |
| **自我进化** | 更新知识、优化 agent、回顾改进、进化 skill | `references/evolution.md` |

**判断规则：**
- 优先匹配精确关键词；不明确时结合用户打开的文件、分支名、git diff 判断
- 多领域交叉（如"写个驱动的 sample"）→ 确定主意图后按依赖顺序调用，例：driver-dev → sample-gen
- 无法判断 → 向用户确认

## 直接回答（跳过 worker）

满足以下**全部**条件时直接回答，不读取 worker 文件：

- 问题只需一段代码片段或一句说明即可完整回答
- 不涉及生成新文件
- 对相关 API 有足够确定性

不确定 API 用法时，先 `Read` 对应头文件，再作答。

## 执行注意事项

- 代码生成前先 `Glob/Grep` 检索 codebase 中的现有实现作为参考
- 需要 API 细节时，参考 `references/knowledge/online-docs.md` 的 URL 映射，用 WebFetch 获取在线文档
- 回答中引用具体文件路径和行号
