# pinmux 引脚复用辅助

## 资源索引

| 资源 | 路径 |
|------|------|
| 头文件 | `IOMuxManager.h` |
| 驱动文档 | `https://docs2.listenai.com/arcs-sdk/latest/zh/html/drivers/lisa_pinmux/README.html` |
| 工具文档 | `https://docs2.listenai.com/arcs-sdk/latest/zh/html/tools/pinmux_tool_zh.html` |

## 执行

并行加载：

- `Read IOMuxManager.h` — `IOMuxManager_PinConfigure` 签名、PAD/PIN/FUNC 枚举定义
- `WebFetch https://docs2.listenai.com/arcs-sdk/latest/zh/html/drivers/lisa_pinmux/README.html` — 引脚功能映射表、配置说明
- `WebFetch https://docs2.listenai.com/arcs-sdk/latest/zh/html/tools/pinmux_tool_zh.html` — 引脚复用工具使用说明

结合用户需求和资源内容，判断缺失的必要信息，向用户确认后再开发。
