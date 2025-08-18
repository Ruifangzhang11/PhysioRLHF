# PhysioRLHF - Physiological Reinforcement Learning from Human Feedback

一个基于生理信号的强化学习应用，通过Apple Watch收集心率数据来优化AI模型的训练。

## 功能特性

### 🏥 健康数据集成
- **Apple Watch心率监测**：实时收集用户心率数据
- **HealthKit集成**：访问和存储健康数据
- **WatchConnectivity**：iPhone与Apple Watch实时通信

### 🧠 AI训练优化
- **生理信号反馈**：使用心率变化作为AI训练反馈信号
- **任务分类系统**：支持多种AI训练任务类型
- **进度追踪**：记录训练进度和成就

### 📱 用户界面
- **现代化UI设计**：使用SwiftUI构建的直观界面
- **实时数据展示**：心率数据和连接状态实时更新
- **任务管理系统**：分类任务和进度追踪

## 项目结构

```
PhysioRLHFApp-2/
├── PhysioRLHFApp-2/           # 主iOS应用
│   ├── HomeView.swift         # 主界面
│   ├── TaskView.swift         # 任务界面
│   ├── WatchHRBridge.swift    # Watch连接桥接
│   ├── HealthKitHR.swift      # HealthKit集成
│   ├── SupabaseClient.swift   # 后端数据同步
│   └── ...
├── PhysioRLHF watch Watch App/ # Apple Watch应用
│   ├── WorkoutManager.swift   # 心率监测管理
│   ├── ContentView.swift      # Watch界面
│   └── ...
└── PhysioRLHF iOS/            # iOS应用变体
```

## 技术栈

- **iOS开发**：SwiftUI, UIKit
- **Apple Watch**：WatchKit, HealthKit
- **数据同步**：WatchConnectivity
- **后端服务**：Supabase
- **健康数据**：HealthKit Framework

## 安装和运行

### 前提条件
- Xcode 15.0+
- iOS 18.5+
- watchOS 11.5+
- Apple Watch设备（用于心率监测）

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone <your-repo-url>
   cd neuralLLM
   ```

2. **打开项目**
   ```bash
   open PhysioRLHFApp-2/PhysioRLHFApp-2.xcodeproj
   ```

3. **配置开发者账号**
   - 在Xcode中选择你的开发者账号
   - 更新Bundle Identifier

4. **运行应用**
   - 选择"PhysioRLHFApp-2" scheme
   - 选择你的iPhone设备
   - 点击运行按钮

## 使用说明

### 首次设置
1. 启动应用后，点击"Grant"按钮授予HealthKit权限
2. 确保Apple Watch已配对并安装Watch应用
3. 检查Watch连接状态

### 开始训练
1. 选择任务类别（Empathy, Clarity, Calmness等）
2. 点击"Start"开始心率监测
3. 完成AI训练任务
4. 系统会根据心率变化提供反馈

### 监控数据
- 实时心率显示
- 训练进度追踪
- 连接状态监控

## 开发说明

### 主要组件

#### WatchHRBridge
负责iPhone与Apple Watch之间的通信，处理心率数据传输和命令发送。

#### WorkoutManager
管理Apple Watch上的心率监测，包括HealthKit权限和实时数据流。

#### HomeView
主界面，显示任务分类、进度追踪和健康数据状态。

### 数据流
```
Apple Watch → WorkoutManager → WatchConnectivity → WatchHRBridge → HomeView
```

## 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 项目维护者：Ruifang Zhang
- 邮箱：[your-email@example.com]

## 致谢

感谢Apple提供的HealthKit和WatchConnectivity框架，以及Supabase提供的后端服务支持。
