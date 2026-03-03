---
name: smart-commit
description: >
  智能 Git 提交助手，自动生成中文 Conventional Commits 格式的提交信息并创建签名提交。
  具备 submodule 感知能力——检测到 submodule 变更时自动引导先在 submodule 内提交，再更新父仓库引用。
  无 submodule 时作为普通 commit 助手工作。

  当用户说"帮我提交"、"生成 commit"、"写提交信息"、"commit 一下"、"提交代码"、
  "submodule 提交"、"同步提交 submodule"、"submodule commit"时触发。
  即使用户只是简单说"提交"或"commit"，也应使用此 skill。
  提交完成后会询问是否推送到远端分支。
license: MIT
---

# Smart Commit — 智能提交助手

根据当前代码修改，生成中文 Conventional Commits 提交信息，并通过 `git commit -s` 创建签名提交。
自动检测 submodule 变更，按正确顺序处理提交。

## 执行流程

### 第一步：分析工作区

并行运行：

```bash
git status                    # 所有变更（含 submodule 状态）
git diff --cached --stat      # 已暂存文件统计
git diff --stat               # 未暂存文件统计
```

根据结果判断：

- **无任何变更**（working tree clean）→ 告知用户，结束
- **包含 submodule 变更**（`modified: <path> (modified content)` 或 `(new commits)`）→ 进入第二步
- **纯普通文件** → 跳过第二步，直接进入第三步

### 第二步：处理 submodule（仅在检测到 submodule 变更时执行）

运行 `git submodule status` 获取完整 submodule 列表。

对每个有变更的 submodule：

**2a. 展示变更摘要并确认**

```bash
git -C <submodule_path> diff --stat HEAD
```

默认询问用户是否提交此 submodule。当用户明确表达"全部提交"、"一起提交"等意图时，自动处理所有 submodule 不再逐个确认。

**2b. 确保在正确分支上**

```bash
git -C <submodule_path> branch --show-current
```

- 已在分支上 → 直接使用
- detached HEAD → 询问用户选择分支（建议与父仓库同名分支，或 `main`/`master`）

**2c. 暂存并提交**

```bash
# 精确暂存，不使用 git add .
git -C <submodule_path> add <file1> <file2> ...
git -C <submodule_path> commit -s -m "<提交信息>"
```

提交成功后输出确认：
```
submodule <path>: <short_hash> — <type>(<scope>): <标题>
```

### 第三步：暂存与安全检查

**3a. 处理暂存状态**

- 有已暂存文件 → 仅针对已暂存文件生成提交信息
- 无已暂存文件 → 展示所有未暂存改动，询问用户是否全部 add
- 有 submodule 引用变更 → 一并暂存 submodule 路径

```bash
# 精确暂存，逐个列出文件
git add <file1> <file2> ...
```

**3b. 安全检查**

对即将提交的文件做基础检查：

1. **敏感文件** — 检查是否包含 `.env`、`credentials`、`*secret*`、`*.key`、`*.pem` 等文件。发现时警告用户并建议加入 `.gitignore`
2. **冲突标记** — 在待提交文件中搜索 `<<<<<<<`、`=======`、`>>>>>>>`。发现时阻止提交，报告冲突文件
3. **大文件** — 检查是否有超过 1MB 的新增文件。发现时提醒用户确认

任一检查失败时报告问题并等待用户处理，不自动跳过。

### 第四步：生成提交信息并提交

分析修改内容，识别模块和改动类型，生成提交信息。

```bash
git commit -s -m "$(cat <<'EOF'
<生成的提交信息>
EOF
)"
```

### 第五步：汇总报告

提交完成后输出摘要：

```
── 提交完成 ──────────────────────────────────
Commit: <hash前8位> — <type>(<scope>): <标题>
文件:   N 个文件变更，+X / -Y 行
```

如果涉及 submodule，额外展示：

```
── 提交完成 ──────────────────────────────────
submodule <path>:
  分支:  <branch>
  Commit: <hash> — <提交标题>
  文件:  N 个文件变更

父仓库:
  Commit: <hash> — <提交标题>
  文件:  N 个文件变更
```

### 第六步：询问是否推送到远端

提交完成后，主动询问用户是否将提交推送到远端分支。

**6a. 收集待推送信息**

对每个已提交的仓库（submodule 和父仓库），检查远端跟踪状态：

```bash
# 检查当前分支及其远端跟踪分支
git [-C <path>] branch -vv --list $(git [-C <path>] branch --show-current)
# 检查是否有未推送的提交
git [-C <path>] log @{upstream}..HEAD --oneline 2>/dev/null
```

**6b. 询问用户**

用 `AskUserQuestion` 询问，选项：

- **全部推送**（推荐）— 按顺序推送所有已提交的仓库（submodule 先于父仓库）
- **仅推送父仓库** — 只推送父仓库（无 submodule 时不展示此选项）
- **暂不推送** — 跳过推送，仅展示手动推送命令供参考

**6c. 执行推送**

用户选择推送后，按顺序执行：

```bash
# 1. 先推送 submodule（如有）
git -C <submodule_path> push origin <branch>
# 若远端无此分支，使用 -u 建立跟踪
git -C <submodule_path> push -u origin <branch>

# 2. 再推送父仓库
git push origin <branch>
```

推送完成后输出结果：

```
── 推送完成 ──────────────────────────────────
submodule <path>: → origin/<branch> ✓
父仓库:          → origin/<branch> ✓
```

推送失败时报告错误（如远端冲突、权限不足），不自动 force push，等待用户处理。

**6d. 用户选择暂不推送**

输出手动推送命令供参考：

```
如需推送，可执行：
  git -C <submodule_path> push origin <branch>
  git push origin <branch>
```

---

## 提交信息格式

```
<type>(<scope>): <简短中文标题>

<详细说明，2-3行：
- 具体改动内容
- 改动原因
- 影响范围>
```

**标题规则**：一行，不超过 50 字符。scope 使用具体模块名（如 `lisa_uart`、`build`、`docs`）。

### Type 类型

| Type | 说明 | 适用场景 |
|------|------|----------|
| `feat` | 新功能 | 新增功能、接口、模块 |
| `fix` | 修复 | Bug 修复、问题修正 |
| `refactor` | 重构 | 不影响功能的代码结构调整 |
| `perf` | 性能 | 性能优化 |
| `docs` | 文档 | 文档新增或修改 |
| `style` | 格式 | 代码格式、空白、分号等 |
| `test` | 测试 | 测试用例增删改 |
| `chore` | 杂务 | 构建脚本、CI、依赖更新 |

如果涉及 submodule，父仓库提交信息中应包含 submodule 变更摘要：

```
<type>(<scope>): <中文描述>

submodule 更新:
- <path>: <旧hash前8位> → <新hash前8位>（<一句话说明>）

<其他改动说明>
```

---

## 错误处理

| 错误情况 | 处理方式 |
|----------|----------|
| submodule 内有冲突 | 停止，报告冲突文件，等待用户解决 |
| submodule detached HEAD | 询问用户选择分支后再提交 |
| submodule 远端分支不存在 | 自动使用 `push -u` 建立跟踪 |
| 推送被远端拒绝 | 报告错误（如需 pull/rebase），不 force push |
| 推送权限不足 | 报告错误，提示检查远端权限 |
| pre-commit hook 失败 | 报告错误内容，不重试，等待用户修复 |
| 无任何变更可提交 | 告知用户 working tree clean |

---

## 注意事项

- 使用 `git commit -s` 添加 Signed-off-by 签名，不添加 Co-Authored-By
- 精确暂存文件（逐个 `git add <file>`），避免 `git add .` 或 `git add -A`
- 提交信息使用 HEREDOC 传递，确保格式正确
- 提交完成后主动询问是否推送，推送顺序为 submodule 先于父仓库
- 绝不自动 force push，推送失败时报告错误等待用户处理
