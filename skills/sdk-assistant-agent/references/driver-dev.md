# ARCS 驱动开发辅助

## 设备路由（必须先做）

识别用户描述中提到的设备，读取对应子 skill 并执行其流程：

| 用户提到的设备 / 关键词 | 读取并执行 |
|------------------------|-----------|
| gpio / 引脚 / 输入输出 / 中断引脚 | `drivers/lisa_gpio.md` |
| uart / 串口 / 收发 / 波特率 | `drivers/lisa_uart.md` |
| spi / spi master / spi slave | `drivers/lisa_spi.md` |
| i2c / i2c master / 从机扫描 | `drivers/lisa_i2c.md` |
| flash / nor flash / 读写擦除 | `drivers/lisa_flash.md` |
| adc / 模数转换 / 采样 / 温度传感器 | `drivers/lisa_adc.md` |
| pwm / 占空比 / 脉宽调制 | `drivers/lisa_pwm.md` |
| hwtimer / 硬件定时器 / gpt / aon timer | `drivers/lisa_hwtimer.md` |
| rtc / 实时时钟 / 闹钟 / 日历 | `drivers/lisa_rtc.md` |
| wdt / watchdog / 看门狗 | `drivers/lisa_wdt.md` |
| sdmmc / sd卡 / mmc / tf卡 | `drivers/lisa_sdmmc.md` |
| i2s / 音频接口 / pcm 流 | `drivers/lisa_i2s.md` |
| display / 显示屏 / lcd 刷屏 / lvgl 显示 | `drivers/lisa_display.md` |
| touch / 触摸 / 触控 | `drivers/lisa_touch.md` |
| audio / 录音 / 播放 / codec / aec | `drivers/lisa_audio.md` |
| qspilcd / qspi lcd / 四线 lcd | `drivers/lisa_qspilcd.md` |
| dvp / 摄像头接口 / camera 接口 | `drivers/lisa_dvp.md` |
| camera / 摄像头 / sensor / 拍照 | `drivers/lisa_camera.md` |
| rgb / led灯带 / ws2812 / sk6812 | `drivers/lisa_rgb.md` |
| pinmux / 引脚复用 / iomux / 引脚功能 | `drivers/pinmux.md` |

## 不明确时

若用户描述涉及多个设备，或设备不明确：

1. 列出可能的候选设备，询问用户确认
2. 确认后再读取对应 .md 文件
