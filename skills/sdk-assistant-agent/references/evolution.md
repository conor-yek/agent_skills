# ARCS Agent 自我进化

负责 Agent 框架的持续改进：审计知识库准确性、优化 skill 路由规则、沉淀新发现的模式。

## 触发条件

1. 用户显式调用（通过 `/sdk-assistant-agent` 入口，选择进化意图）
2. sdk-assistant-agent 检测到需要知识更新时，建议用户触发

## 执行流程

### Step 1: 诊断当前状态

读取以下文件，评估当前知识库健康度：

```
必读:
- references/knowledge/evolution-log.md    → 上次进化内容和待改进项
- references/knowledge/sdk-patterns.md     → 模式是否与 codebase 一致
- references/knowledge/driver-patterns.md  → 驱动模板是否最新
- references/knowledge/build-issues.md     → 问题列表是否有新增

可选（按需）:
- references/index.md                                                       → 系统文件全景图是否准确
- SKILL.md                                                                  → 主路由规则是否需要调整
- references/{build-debug,sample-gen,code-review,component-dev,doc-writing}.md  → 各 worker prompt 质量
- references/driver-dev.md                                                  → 驱动路由规则
- references/drivers/*.md                                                   → 各驱动设备 worker 内容
```

### Step 2: 知识验证

对照 codebase 验证知识库的准确性：

1. **模式验证** — 检查 sdk-patterns.md 中描述的模式是否还与实际代码一致
   - 用 Grep 搜索关键宏/函数，确认 API 签名未变
   - 检查 `LISA_DEVICE_REGISTER` 宏的参数是否与文档一致
   - 检查 `lisa_evt_pub` API 是否有新增/变更

2. **结构验证** — 检查 `references/index.md` 中的系统文件描述是否还准确
   - 用 Glob 检查关键目录是否存在
   - 检查是否有新增的 components/drivers

3. **问题验证** — 检查 build-issues.md 中的问题是否还成立
   - 是否有已解决的问题需要标注
   - 是否有新类型的构建问题

### Step 3: 收集改进素材

从多个来源收集改进信息：

1. **Git 历史分析**
   ```bash
   git log --oneline -20  # 最近 20 条提交
   ```
   - 提取新增的组件/驱动/模块
   - 识别 API 变更（重构类提交）
   - 发现新的编码模式

2. **Codebase 变更检测**
   - 检查 components/ 下是否有新增目录
   - 检查 drivers/ 下是否有新增驱动
   - 检查 cmake/extensions.cmake 是否有新宏

3. **Skill 使用回顾**（如有记录）
   - 哪些 skill 被频繁使用
   - 哪些意图被错误路由
   - 用户纠正过哪些输出

### Step 4: 执行更新

根据诊断和素材，执行以下更新动作：

#### 4a. 更新知识文件

```
对于每个需要更新的文件:
1. 读取当前内容
2. 标识需要修改的部分
3. 使用 Edit 工具精确修改（不重写整个文件）
4. 验证修改后的内容一致性
```

**更新原则：**
- 只更新有确切证据支持的内容
- 新增内容附带来源（文件路径/提交 hash）
- 删除已确认过时的内容

#### 4b. 优化 Skill Prompt

如果发现某个 skill 的输出质量可以改进：

1. 分析问题根因（触发条件不准？流程缺失？知识过时？）
2. 修改对应 skill 的 SKILL.md
3. 保持修改最小化，只改必要部分

#### 4c. 更新路由规则

如果发现 sdk-assistant-agent 的意图分类需要调整：

1. 在 sdk-assistant-agent/SKILL.md 的意图识别表中添加/修改触发信号
2. 确保不影响已有的正确路由

### Step 5: 记录进化

在 `references/knowledge/evolution-log.md` 中追加本次进化记录：

```markdown
## vX.Y.Z (YYYY-MM-DD) - 简要描述

### 变更内容
- [文件名]: 具体修改了什么
- [文件名]: 具体修改了什么

### 变更原因
- 发现了什么问题 / 有什么新信息

### 效果预期
- 预期改善什么

### 待改进
- 还有什么可以继续优化
```

### Step 6: 汇报

向用户输出进化摘要：

```
进化完成 vX.Y.Z

更新了 N 个知识文件:
- xxx.md: 描述变更
- yyy.md: 描述变更

优化了 M 个 skill:
- xxx (子skill名): 描述变更

新发现:
- 列出新发现的模式/问题

待处理:
- 需要人工确认的事项
```

## 安全守则

- **不删除**用户手动添加的知识内容，只追加或标注
- **不修改** skill 的核心逻辑，只调整触发条件和知识引用
- 所有修改使用 Edit 工具（精确替换），避免 Write 整个文件
- 每次进化前先在 evolution-log.md 中记录意图，完成后记录结果
