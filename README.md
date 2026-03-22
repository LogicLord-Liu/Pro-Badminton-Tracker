<div align="center">

# 🏸 Pro Badminton Tracker (PBT)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/LogicLord-Liu/Pro-Badminton-Tracker?color=orange&logo=github&style=flat-square)](https://github.com/LogicLord-Liu/Pro-Badminton-Tracker/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Stars](https://img.shields.io/github/stars/LogicLord-Liu/Pro-Badminton-Tracker?style=social)](https://github.com/LogicLord-Liu/Pro-Badminton-Tracker/stargazers)

**一款专为羽毛球爱好者打造的专业级计分与复盘工具。**

[🚀 快速开始](#-安装与运行) • [✨ 项目特色](#-项目特色) • [🛠️ 技术细节](#️-技术细节) • [📋 待办清单](#-待办清单-roadmap)

---

Pro Badminton Tracker 旨在提供最流畅、最直观的计分体验。
采用 iOS 设计语言，支持丝滑的暗黑模式切换，并具备精准的比赛走势记录与图片导出功能。

</div>

## ✨ 项目特色

| 🏆 纯粹体验 | 🎨 视觉美学 | 📱 全平台 |
| :--- | :--- | :--- |
| **完全开源免费**：无内购，无隐藏费用。 | **iOS 视觉风格**：基于 Cupertino 界面设计。 | **Flutter 驱动**：支持 Android 与 iOS。 |
| **纯净无广告**：拒绝干扰，专注于每一分球。 | **一键主题切换**：完美适配明亮与暗黑模式。 | **线性振动**：细腻的触感反馈提示。 |

---

## 🚀 主要功能

### 1. 专业计分系统
*   **灵活赛制**：支持 1 局、3 局 2 胜或 5 局 3 胜制。
*   **标准 BWF 逻辑**：严格遵循世界羽联计分规则（包括 11 分间歇提醒、21 分及平分加分规则）。

### 2. 深度历史回溯
*   **全历程记录**：自动记录比赛中产生的所有得分瞬间。
*   **长按回溯 (Revert)**：在历史面板中长按任意比分点，可瞬间将比赛恢复到该时刻，轻松修正误判。
*   **分局统计**：清晰展示每一局的比分走势与关键点。

### 3. 数据导出与分享
*   **长图战报**：一键生成精美的图片战报，包含对阵双方及最终比分走势。
*   **系统级分享**：支持保存至系统相册或直接发送给好友，展示你的胜利时刻。

---

## 🛠️ 技术细节

### 核心架构
*   **Framework**: `Flutter 3.x` (Material 3 + Cupertino)
*   **State Management**: `Provider` + `ChangeNotifier`

### 关键插件
*   `gal`: 跨平台相册高效存储
*   `share_plus`: 调用系统原生分享界面
*   `render_repaint_boundary`: 将复杂 UI 转换为高清晰度图片导出

---

## 📸 预览图

| 首页计分 | 历史记录 | 战报分享 |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/200x400?text=Score+UI" width="200"> | <img src="https://via.placeholder.com/200x400?text=History+UI" width="200"> | <img src="https://via.placeholder.com/200x400?text=Share+Image" width="200"> |
| *标准计分界面* | *分点回溯功能* | *一键生成战报* |

---

## 📥 安装与运行

### 环境准备
确保您的本地环境已安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)。

### 步骤说明
1.  **克隆仓库**
    ```bash
    git clone https://github.com/LogicLord-Liu/Pro-Badminton-Tracker.git
    cd Pro-Badminton-Tracker
    ```

2.  **获取依赖**
    ```bash
    flutter pub get
    ```

3.  **启动应用**
    ```bash
    flutter run
    ```

---

## 📋 待办清单 (Roadmap)

- [ ] **🗣️ 语音播报**：集成 TTS 技术，支持中英文实时比分自动播报。
- [ ] **⌨️ 蓝牙外设联动**：支持通过蓝牙翻页笔、耳机线控进行远程计分。
- [ ] **📈 数据可视化**：增加比赛走势折线图，深度分析选手的“分水岭”时刻。
- [ ] **🔄 屏幕适配**：增加 iPad 适配及横屏布局模式。
- [ ] **⏱️ 自动计时器**：记录每局比赛耗时，分析比赛强度。

---

## 🤝 参与贡献

我们欢迎所有形式的贡献！
*   如果您发现了 Bug，请提交 [Issue](https://github.com/LogicLord-Liu/Pro-Badminton-Tracker/issues)。
*   如果您有关于“羽毛球竞赛规则”的专业优化建议，欢迎联系我。
*   欢迎提交 Pull Request 来完善代码。

## 📜 开源协议

本项目基于 **MIT License** 协议开源。你可以自由地使用、修改和分发，但请保留原作者的版权信息。

---

<div align="center">

**Developed with ❤️ by [LogicLord-Liu](https://github.com/LogicLord-Liu)**

如果您觉得这个项目对你有帮助，欢迎点一个 **Star** ⭐！

</div>