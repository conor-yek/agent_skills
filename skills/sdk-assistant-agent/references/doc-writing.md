# ARCS SDK 文档编写与修复助手

## Step 0: 意图识别（必须先做）

| 意图 | 判断信号 | 路径 |
|------|----------|------|
| **新建文档** | 写/创建/添加 README、新驱动/组件/示例文档 | → **Path A** |
| **修复在线文档错误** | 客户反馈了在线 URL、文档内容有误、错误描述 | → **Path B** |
| **修复构建警告** | `make zh` 输出 WARNING/ERROR、CI 失败 | → **Path C** |
| **了解构建流程** | 怎么本地构建、发布流程、CI 说明 | → **Path D** |

不明确时询问：是新建文档、修复在线文档错误，还是解决构建问题？

---

## 文档系统快速参考

### URL → 源文件映射公式

在线文档 URL 到 SDK 源文件的转换规则：

```
在线 URL:
  https://docs2.listenai.com/arcs-sdk/latest/zh/html/<path>.html

对应源文件（SDK 根目录下）:
  <path>.md   或   <path>.rst
```

**示例：**

| 在线 URL（去掉前缀后） | SDK 源文件 |
|----------------------|------------|
| `drivers/lisa_uart/README.html` | `drivers/lisa_uart/README.md` |
| `components/lisa_kv/README.html` | `components/lisa_kv/README.md` |
| `samples/drivers/devices/lisa_gpio/output_basic/README.html` | `samples/drivers/devices/lisa_gpio/output_basic/README.md` |
| `get_started.html` | `docs/zh/get_started.rst` |

**前缀**（去掉这部分）：`https://docs2.listenai.com/arcs-sdk/latest/zh/html/`

### 各类型文档的源文件位置

| 类型 | SDK 中的源文件位置 | 对应的索引文件 |
|------|-------------------|---------------|
| 驱动文档 | `drivers/<lisa_xxx>/README.md` | `drivers/index_zh.rst` |
| 组件文档 | `components/<name>/README.md` | `components/index_zh.rst` |
| 示例文档 | `samples/<category>/<name>/README.md` | `samples/<category>/index_zh.rst` |
| Demo 文档 | `demos/<name>/README.md` | `demos/index_zh.rst` |
| 板级文档 | `boards/<board>/README.md` | `boards/index_zh.rst` |
| 顶层文档 | `docs/zh/*.rst` | `docs/zh/index.rst` |

**注意：** `modules/` 目录下的 README 只有在 `conf.py` 的 `external_content_contents` 里**显式列出**才会被收录，不会自动全量收录。

### 明确被排除的路径（这些文件不会出现在文档站）

以下路径即使有 README.md 也不会被构建系统收录：
```
drivers/porting_docs/**
drivers/lisa_device/**
drivers/Devices_Docs_Spec.md
samples/drivers/hal/**/README.md
samples/Samples_Spec.md
samples/drivers/devices/Devices_Samples_Spec.md
components/acomp/logger/**/README.md
demos/face_detect/src/button/FlexibleButton/README.md
```

### 有效代码块语言白名单

Sphinx/Pygments 可以正常渲染的语言标注（来自现有文档实际使用情况）：

✅ 可用：`c`、`kconfig`、`bash`、`ini`、`python`、`cmake`、`text`、`rst`、`json`、`yaml`

❌ 会产生 warning（改用 `text`）：自造的语言名、空标注后紧跟内容

### Sphinx 警告分级

以下 warning 类型已被 `suppress_warnings` 压制，**不会导致 CI 失败**，可以忽略：
```
myst.header, myst.domains, myst.xref_missing
ref.doc, ref.ref
toc.excluded, toc.not_readable, toc.not_included, toc.secnum, toc.circular
```

**会导致 CI 失败**的 warning（需要修复）：
- `WARNING: document isn't included in any toctree` — 文件存在但未在索引中注册
- `ERROR: Unknown directive type` — RST 指令拼写错误
- `ERROR: Malformed table` — RST 表格格式错误
- `WARNING: image file not readable` — 图片路径失效
- `WARNING: Pygments lexer not found for language` — 代码块语言非法

### 构建命令

```bash
cd /path/to/arcs-sdk/docs

# 普通构建（查看效果）
make zh

# CI 严格模式（任何 warning = 失败，提交前必须通过）
make zh SPHINXOPTS="-W"

# 只查看新产生的 warning/error
make zh 2>&1 | grep -E "^[^/].*(WARNING|ERROR)"

# 清理重建
make clean && make zh
```

---

## Path A: 新建文档

### Step A1: 确认信息

若用户未说明，询问：
1. 文档类型：驱动 / 组件 / 示例 / Demo？
2. 目标目录（如 `drivers/lisa_xxx`、`samples/drivers/devices/lisa_xxx/basic`）？

### Step A2: 并行加载参考上下文

```
① Read  <目标模块头文件>（drivers/lisa_xxx/lisa_xxx.h 或 components/xxx/include/xxx.h）
   → 获取真实 API 函数签名、结构体、枚举，不要凭记忆写 API
② Glob  同类型目录下的 README.md，Read 1-2 个质量好的现有文档
   → 驱动类参考 drivers/lisa_uart/README.md
   → 组件类参考 components/lisa_kv/README.md（若存在）
   → 示例类参考同 category 下的其他 README.md
```

### Step A3: 按模板生成

#### 驱动文档模板（`drivers/lisa_xxx/README.md`）

```markdown
# <驱动名称> 驱动

<一句话：基于 lisa_device 框架的 XXX 驱动，提供 YYY 功能>

## 功能特性

- **特性1**：说明
- **特性2**：说明

## 配置选项

在 `prj.conf` 中启用：

​```kconfig
CONFIG_LISA_XXX_DEVICE=y
​```

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `CONFIG_LISA_XXX_DEVICE` | 启用 XXX 驱动 | n |

## API 接口

### 数据结构

​```c
/* 从头文件复制真实的结构体定义 */
​```

### 核心 API

​```c
/* 从头文件复制真实函数签名，每个函数加一行中文注释 */
int lisa_xxx_do_something(lisa_device_t *dev, ...);
​```

## 使用示例

### 基本用法

​```c
#define LOG_TAG "xxx_example"
#include <lisa_log.h>
#include <lisa_xxx.h>

/* 完整可编译的示例代码 */
​```

## 注意事项

1. 注意事项1
2. 注意事项2
```

#### 组件文档模板（`components/<name>/README.md`）

```markdown
# <组件名称> 组件

<一句话功能说明>

## 📖 组件概述

### 主要功能
- **功能1**：说明

## 🚀 快速开始

### 1. 启用配置

​```kconfig
CONFIG_<COMPONENT>=y
​```

### 2. 基本使用

​```c
/* 示例代码 */
​```

## 🔧 配置选项

| 配置项 | 说明 | 默认值 |
|--------|------|--------|

## 📋 API 参考

### 数据结构

### 主要 API

## ⚠️ 注意事项
```

#### 示例文档模板（`samples/<category>/<name>/README.md`）

```markdown
# <示例名称>

<示例功能简介>

## 📖 示例说明

### 功能演示
- 演示功能1

### 硬件要求
- 开发板：arcs_mini 或 arcs_evb

## 🚀 快速开始

### 1. 构建项目

​```bash
./build.sh -C -S samples/<category>/<name> -DBOARD=arcs_evb
​```

### 2. 烧录运行

​```bash
./tools/burn/cskburn -s /dev/ttyUSB0 -b 3000000 0x0 build/<name>.bin -C arcs
​```

### 3. 查看输出

​```text
[预期串口输出内容]
​```

## 🔧 配置说明

## 📋 代码解析

## 🔍 预期输出

## ⚠️ 注意事项
```

### Step A4: 更新索引文件

在对应的 `index_zh.rst` 中**追加条目**（不加则文档不出现在文档站）：

```rst
.. toctree::
    :maxdepth: 1

    existing/README.md
    <new_name>/README.md     ← 新增这一行
```

若是示例新分类，先创建 `samples/<new_category>/index_zh.rst`，再在 `samples/index_zh.rst` 中注册：

```rst
# samples/new_category/index_zh.rst
.. _samples_new_category:

新分类名称
==========

.. toctree::
    :maxdepth: 1

    my_sample/README.md
```

### Step A5: 强制验证（不可跳过）

```bash
cd docs && make zh 2>&1 | grep -E "WARNING|ERROR"
```

期望输出：空（无新增 warning）。

若有 warning，逐条对照 **Path C** 的诊断表修复后再提交。

---

## Path B: 修复在线文档错误

### Step B1: 定位源文件

从客户提供的在线 URL 推导源文件路径：

```
去掉前缀: https://docs2.listenai.com/arcs-sdk/latest/zh/html/
将 .html 改为 .md（或 .rst）
```

**示例：**
```
客户反馈 URL:
  https://docs2.listenai.com/arcs-sdk/latest/zh/html/drivers/lisa_spi/README.html

源文件:
  drivers/lisa_spi/README.md
```

```bash
# 验证文件存在
ls drivers/lisa_spi/README.md
```

若文件不存在，检查是否：
- 路径中有多余层级（参照 `samples/` 下的深层目录结构）
- 对应 RST 文件（`docs/zh/` 下的 `.rst` 文件）

### Step B2: 读取文件并理解错误

```
① Read  <源文件>
② 若客户描述的是 API 或代码错误，同时 Read 对应头文件验证
```

### Step B3: 错误类型与修复策略

| 错误类型 | 处理方式 |
|----------|----------|
| **内容错误**（API 签名/参数说明有误） | Read 头文件获取正确签名，更新文档 |
| **代码示例无法编译/运行** | 参考同类 sample 的 main.c，修正示例代码 |
| **配置说明有误**（Kconfig 项不存在/名称错误） | Grep `CONFIG_` 在 Kconfig 文件中验证，修正 |
| **链接失效**（指向不存在页面） | 改为绝对 URL 或删除链接 |
| **内容缺失**（功能有文档但未记录） | Read 头文件补充 |
| **中文表述有误/不准确** | 直接编辑修正 |

### Step B4: 修复后强制验证（不可跳过）

```bash
cd docs && make zh 2>&1 | grep -E "WARNING|ERROR"
```

期望输出：与修复前相比无新增 warning。

---

## Path C: 修复构建 Warning/Error

### Step C1: 获取构建输出

若用户未提供，请用户运行：
```bash
cd docs && make zh 2>&1 | grep -E "WARNING|ERROR"
```

### Step C2: 诊断对照表

| 警告/错误信息 | 根本原因 | 修复方法 |
|--------------|----------|----------|
| `WARNING: document isn't included in any toctree` | 文件存在但未在 `index_zh.rst` 注册 | 在对应 `index_zh.rst` 添加条目 |
| `ERROR: Unknown directive type "xxx"` | RST 指令名拼写错误 | 修正指令名（如 `.. toctree::` 不是 `.. toc::`）|
| `ERROR: Malformed table` | RST 表格列宽不一致 | 对齐表格中 `---` 分隔行的长度 |
| `WARNING: image file not readable: xxx` | 图片路径相对于文档文件，但文件被 external_content 复制后路径变了 | 改用绝对路径或将图片放在 `docs/assets/` |
| `WARNING: Pygments lexer not found for language "xxx"` | 代码块语言标注非法 | 改为白名单中的语言（见快速参考）|
| `ERROR: Unknown interpreted text role "xxx"` | RST 角色不存在 | 删除或改为 MyST 语法 |
| `WARNING: Title underline too short` | RST 文件标题下的 `===` 长度不足 | 将 `===` 补齐至与标题等长 |
| `WARNING: Could not lex literal_block as "xxx"` | 同 Pygments lexer 问题 | 改为 `text` |

### Step C3: 定位并修复

```bash
# 查看完整上下文（警告所在行号）
cd docs && make zh 2>&1 | grep -A2 "WARNING\|ERROR"
```

根据文件路径（warning 中已给出）Read 对应文件，修复后重新验证。

### Step C4: 验证通过

```bash
make zh SPHINXOPTS="-W"
# 无输出或无 WARNING/ERROR = 通过
```

---

## Path D: 构建流程说明

### 本地构建

```bash
cd /path/to/arcs-sdk/docs

# 1. 首次安装依赖
pip install -r requirements.txt

# 2. 构建中文文档
make zh

# 3. 查看结果
xdg-open output/zh/html/index.html
```

### 文档收录机制

```
SDK 源文件（drivers/、components/、samples/ 等下的 *.md/*.rst）
    ↓  [external_content 扩展在构建时自动复制]
docs/zh/<同路径>/   （构建工作区，.gitignore 忽略）
    ↓  [Sphinx 处理，MyST 解析 Markdown]
    ↓  [doxyrunner 生成 Doxygen API HTML]
docs/output/zh/html/   （本地预览）
    ↓  [Read the Docs 部署]
https://docs2.listenai.com/arcs-sdk/latest/zh/html/
```

**关键**：写好 README.md 后，必须在 `index_zh.rst` 中注册，文档才会出现在文档站。

### CI 集成

```yaml
# 触发条件：MR 到 master 或 develop/* 分支
script:
  - cd docs && make zh SPHINXOPTS="-W"
  # 任何 warning = CI 失败 = MR 无法合并
```

**提交前本地验证**：
```bash
make zh SPHINXOPTS="-W" 2>&1 | grep -E "WARNING|ERROR"
# 空输出 = 安全提交
```

### MyST Markdown 可用语法（已启用的扩展）

| 功能 | 语法 |
|------|------|
| 提示框 | `````{note}````` / `````{warning}````` / `````{tip}````` |
| 任务列表 | `- [ ] 待做` / `- [x] 已完成` |
| 删除线 | `~~文字~~` |
| 数学公式 | `$...$` 或 `$$...$$` |
| 定义列表 | `term\n: definition` |
| HTML 图片 | `<img src="..." width="...">` |
