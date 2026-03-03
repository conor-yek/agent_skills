# lisa_audio 驱动辅助

## 资源索引

| 资源 | 路径 |
|------|------|
| 头文件 | `drivers/lisa_audio/lisa_audio.h` |
| 在线文档 | `https://docs2.listenai.com/arcs-sdk/latest/zh/html/drivers/lisa_audio/README.html` |
| 示例 | `samples/drivers/devices/lisa_audio/` |

## 执行

并行加载：

- `Read drivers/lisa_audio/lisa_audio.h` — API 签名、配置结构体定义
- `WebFetch https://docs2.listenai.com/arcs-sdk/latest/zh/html/drivers/lisa_audio/README.html` — Kconfig 配置要求、引脚复用说明
- `Glob samples/drivers/devices/lisa_audio/**` — 可用示例场景列表

结合用户需求和资源内容，判断缺失的必要信息，向用户确认后再开发。
