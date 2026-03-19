#!/bin/bash
# SDK Assistant Agent 校验脚本
# 用法: bash .claude/skills/sdk-assistant-agent/scripts/validate_skill.sh

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=== SDK Assistant Agent 校验 ==="
echo "目录: $SKILL_DIR"
echo ""

# 1. 检查 index.md 完整性
echo "--- 检查 index.md 完整性 ---"
for f in "$SKILL_DIR"/references/*.md; do
    basename=$(basename "$f")
    [ "$basename" = "index.md" ] && continue
    if ! grep -q "$basename" "$SKILL_DIR/references/index.md" 2>/dev/null; then
        echo "ERROR: $basename 未在 index.md 中注册"
        ((ERRORS++))
    fi
done

# 2. 检查文件头类型声明
echo "--- 检查文件头类型声明 ---"
for f in "$SKILL_DIR"/references/*.md "$SKILL_DIR"/references/experience/*.md "$SKILL_DIR"/references/knowledge/*.md; do
    [ -f "$f" ] || continue
    basename=$(basename "$f")
    [ "$basename" = ".gitkeep" ] && continue
    if ! head -1 "$f" | grep -q '<!-- type:' 2>/dev/null; then
        echo "WARNING: $f 缺少类型声明头"
        ((WARNINGS++))
    fi
done

# 3. 检查 experience 条目格式
echo "--- 检查 experience 条目格式 ---"
for f in "$SKILL_DIR"/references/experience/*.md; do
    [ -f "$f" ] || continue
    basename=$(basename "$f")
    [ "$basename" = ".gitkeep" ] && continue

    # 检查每个二级标题下是否有"场景"和"日期"
    in_entry=false
    has_scene=false
    has_date=false
    entry_title=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^##\  ]]; then
            if $in_entry && (! $has_scene || ! $has_date); then
                [ "$has_scene" = false ] && echo "ERROR: $basename 条目 '$entry_title' 缺少'场景'字段" && ((ERRORS++))
                [ "$has_date" = false ] && echo "ERROR: $basename 条目 '$entry_title' 缺少'日期'字段" && ((ERRORS++))
            fi
            in_entry=true
            has_scene=false
            has_date=false
            entry_title="${line#\#\# }"
        fi
        [[ "$line" =~ ^-\ 场景： ]] && has_scene=true
        [[ "$line" =~ ^-\ 日期： ]] && has_date=true
    done < "$f"

    # 检查最后一个条目
    if $in_entry && (! $has_scene || ! $has_date); then
        [ "$has_scene" = false ] && echo "ERROR: $basename 条目 '$entry_title' 缺少'场景'字段" && ((ERRORS++))
        [ "$has_date" = false ] && echo "ERROR: $basename 条目 '$entry_title' 缺少'日期'字段" && ((ERRORS++))
    fi
done

# 4. 检查 experience 版本标记格式
echo "--- 检查版本标记格式 ---"
for f in "$SKILL_DIR"/references/experience/*.md; do
    [ -f "$f" ] || continue
    basename=$(basename "$f")
    [ "$basename" = ".gitkeep" ] && continue

    grep -n "^- 版本：" "$f" 2>/dev/null | while IFS= read -r match; do
        lineno=$(echo "$match" | cut -d: -f1)
        content=$(echo "$match" | cut -d: -f2-)
        if ! echo "$content" | grep -qE '(<=|>=|=)\s*[0-9]+\.[0-9]+' 2>/dev/null; then
            echo "WARNING: $basename:$lineno 版本标记格式不规范: $content"
            ((WARNINGS++)) || true
        fi
    done
done

echo ""
echo "=== 校验完成: $ERRORS 个错误, $WARNINGS 个警告 ==="
[ $ERRORS -eq 0 ] && echo "PASS" || echo "FAIL"
exit $ERRORS
