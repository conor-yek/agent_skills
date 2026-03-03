# Agent 进化记录

## v0.1.0 (2026-02-26) - 初始版本

### 创建内容
- 建立 Agent 框架：统一入口 (arcs-agent) + 进化机制 (arcs-evolution)
- 初始化知识基线：MEMORY.md + sdk-patterns.md + driver-patterns.md + build-issues.md
- 创建 5 个 skill stub: driver-dev, build-debug, sample-gen, code-review, component-dev

### 知识来源
- 通过 codebase 探索提取 SDK 架构模式
- 参考 lisa_device、lisa_uart、lisa_evt_pub、custom_section 等核心实现

### 待改进
- Skill stub 待充实为完整实现
- 知识库需要在实际使用中持续验证和补充
- 路由规则需要根据实际意图分布调优

## v0.1.1 (2026-02-27) - 知识库校准与路径修复

### 变更内容
- [MEMORY.md]: CMake 版本 3.13+ → 3.19+（与 extensions.cmake 一致）
- [MEMORY.md]: sys_init 级别名改为完整宏名 `SYS_INIT_LEVEL_*`，补充 `SYS_INIT()` 注册宏
- [MEMORY.md]: 日志宏补充 LOGV/LOGH
- [MEMORY.md]: modules/ 移除不存在的 lwIP，补充 demos/docs/test/tools/defconfig 目录
- [MEMORY.md]: soc/arcs/ → soc/arcs/hal/ 精确路径
- [sdk-patterns.md]: evt_pub 补充完整 API (_cb_remove, _clear, _destroy, _has_subscriber)
- [sdk-patterns.md]: sys_init 级别宏名修正 + 注册示例
- [conventions.md]: 补充 LOGV/LOGH 宏
- [sdk-architecture.md]: sys_init 启动流程级别名修正 + SYS_INIT 注册方式
- [evolution/SKILL.md]: arcs-agent/arcs-evolution 旧名引用 → sdk-assistant-agent

### 变更原因
- 对照 codebase 验证发现知识库存在多处不一致
- evolution/SKILL.md 中残留了重命名前的路径引用

### 效果预期
- 知识库与 codebase 实际代码保持一致，减少误导
- Phase 2 skill 实现时可基于准确的知识基线

### 待改进
- LOGH 宏的具体参数签名需进一步确认
- modules/ 完整列表可在 Phase 2 中按需补充

## v0.2.0 (2026-02-27) - 知识文件迁移至工程目录

### 变更内容
- [knowledge/]: 将 sdk-patterns.md, driver-patterns.md, build-issues.md, evolution-log.md 从 auto memory 迁移到工程内 `knowledge/` 目录
- [SKILL.md]: 知识文件路径 `memory/xxx.md` → `knowledge/xxx.md`
- [evolution/SKILL.md]: 知识文件路径 `memory/xxx.md` → `knowledge/xxx.md`
- [driver-dev/SKILL.md]: `memory/driver-patterns.md` → `knowledge/driver-patterns.md`
- [DEVELOPMENT_PLAN.md]: 更新 DD-002 设计决策，反映新的知识存储方案
- [memory/MEMORY.md]: 精简为轻量索引，所有详细知识链接指向工程目录

### 变更原因
- auto memory 不在 git 中，无法团队共享
- 知识文件分散在两个位置，维护和演进时容易遗漏
- 统一到工程目录后可 git 管理、团队协作、PR review

### 效果预期
- 所有知识文件在 `.claude/skills/sdk-assistant-agent/knowledge/` 统一管理
- MEMORY.md 保持轻量索引角色，自动加载时指引到工程目录
- 演进更新只需修改工程内文件，路径一致

### 待改进
- 随着 Phase 2 skill 实现，knowledge/ 下可能需要新增领域知识文件

## v0.3.0 (2026-02-27) - 集成在线文档到 Agent 知识体系

### 变更内容
- [knowledge/online-docs.md]: 新建文档站结构索引，包含完整 URL 映射（20 个驱动、16 个组件、7 类示例、2 个板型、3 个工具）和快速入门核心命令摘要
- [SKILL.md]: Step 1 增加第 3 步——涉及具体驱动/组件使用时通过 WebFetch 获取在线文档；注意事项补充在线文档引用和互补说明
- [driver-dev/SKILL.md]: Step 2 增加在线文档中驱动说明页面的参考指引
- [build-debug/SKILL.md]: Step 1 增加快速入门和 GDB 调试指南的文档 URL 引用
- [sample-gen/SKILL.md]: Step 2 增加在线文档示例分类页面的参考指引
- [memory/MEMORY.md]: 补充板型（arcs_mini/arcs_evb）、编译/烧录命令快速参考、在线文档 URL；知识文件列表增加 online-docs.md

### 变更原因
- Agent 知识体系完全基于 codebase 探索，缺少官方文档中的使用说明、注意事项和最佳实践
- 用户询问"怎么用 xxx"类问题时需要更完整的上下文
- 需要能引导用户查看对应的官方文档页面

### 效果预期
- Agent 可通过 WebFetch 按需获取在线文档，补充 codebase 不包含的使用说明
- 回答中可附带官方文档链接，方便用户深入查看
- 编译/烧录等常用命令在 MEMORY.md 中即时可用，无需额外查找
