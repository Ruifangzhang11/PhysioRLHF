# NeuralLLM - AI & Physiological Research Projects

This repository contains two related research projects focused on the intersection of AI and physiological signals.

## 📁 Project Structure

```
neuralLLM/
├── PhysioRLHFApp-2/          # 🏥 Physiological RLHF iOS Application
├── affective-rlhf-site/      # 🌐 Affective RLHF Web Application (submodule)
├── PhysioRLHFApp/           # 📱 Simplified iOS Application
└── README.md                # 📖 Project Documentation
```

## 🏥 PhysioRLHF - Physiological Reinforcement Learning from Human Feedback

A physiological signal-based reinforcement learning application that collects heart rate data from Apple Watch to optimize AI model training.

### Features

#### 🏥 Health Data Integration
- **Apple Watch Heart Rate Monitoring**: Real-time heart rate data collection
- **HealthKit Integration**: Access and store health data
- **WatchConnectivity**: Real-time communication between iPhone and Apple Watch

#### 🧠 AI Training Optimization
- **Physiological Signal Feedback**: Use heart rate changes as AI training feedback signals
- **Task Classification System**: Support for multiple AI training task types
- **Progress Tracking**: Record training progress and achievements

#### 📱 User Interface
- **Modern UI Design**: Intuitive interface built with SwiftUI
- **Real-time Data Display**: Live heart rate data and connection status updates
- **Task Management System**: Categorized tasks and progress tracking

### Project Structure

```
PhysioRLHFApp-2/
├── PhysioRLHFApp-2/           # Main iOS Application
│   ├── HomeView.swift         # Main Interface
│   ├── TaskView.swift         # Task Interface
│   ├── WatchHRBridge.swift    # Watch Connection Bridge
│   ├── HealthKitHR.swift      # HealthKit Integration
│   ├── SupabaseClient.swift   # Backend Data Sync
│   └── ...
├── PhysioRLHF watch Watch App/ # Apple Watch Application
│   ├── WorkoutManager.swift   # Heart Rate Monitoring Manager
│   ├── ContentView.swift      # Watch Interface
│   └── ...
└── PhysioRLHF iOS/            # iOS Application Variant
```

## 🌐 Affective-RLHF Site

An affective reinforcement learning web application providing AI training interfaces based on emotional feedback.

### Features
- **Emotional Feedback System**: AI training based on user emotional states
- **Web Interface**: Modern React/Next.js frontend
- **Real-time Interaction**: Dynamic AI training experience

## 🛠️ Technology Stack

### PhysioRLHF
- **iOS Development**: SwiftUI, UIKit
- **Apple Watch**: WatchKit, HealthKit
- **Data Synchronization**: WatchConnectivity
- **Backend Services**: Supabase
- **Health Data**: HealthKit Framework

### Affective-RLHF Site
- **Frontend**: React, Next.js
- **Styling**: Tailwind CSS
- **Deployment**: Vercel/Netlify

## 📦 Installation and Setup

### PhysioRLHF iOS Application

#### Prerequisites
- Xcode 15.0+
- iOS 18.5+
- watchOS 11.5+
- Apple Watch device (for heart rate monitoring)

#### Installation Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/Ruifangzhang11/PhysioRLHF.git
   cd PhysioRLHF
   git submodule update --init --recursive
   ```

2. **Open Project**
   ```bash
   open PhysioRLHFApp-2/PhysioRLHFApp-2.xcodeproj
   ```

3. **Configure Developer Account**
   - Select your developer account in Xcode
   - Update Bundle Identifier

4. **Run Application**
   - Select "PhysioRLHFApp-2" scheme
   - Choose your iPhone device
   - Click the run button

### Affective-RLHF Web Application

1. **Navigate to Web Project Directory**
   ```bash
   cd affective-rlhf-site
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Run Development Server**
   ```bash
   npm run dev
   ```

## 📖 Usage Guide

### PhysioRLHF iOS Application

#### Initial Setup
1. After launching the app, click the "Grant" button to authorize HealthKit permissions
2. Ensure Apple Watch is paired and Watch app is installed
3. Check Watch connection status

#### Start Training
1. Select task category (Empathy, Clarity, Calmness, etc.)
2. Click "Start" to begin heart rate monitoring
3. Complete AI training tasks
4. System provides feedback based on heart rate changes

#### Monitor Data
- Real-time heart rate display
- Training progress tracking
- Connection status monitoring

## 🔧 Development Guide

### Key Components

#### WatchHRBridge
Responsible for communication between iPhone and Apple Watch, handling heart rate data transmission and command sending.

#### WorkoutManager
Manages heart rate monitoring on Apple Watch, including HealthKit permissions and real-time data streams.

#### HomeView
Main interface displaying task categories, progress tracking, and health data status.

### Data Flow
```
Apple Watch → WorkoutManager → WatchConnectivity → WatchHRBridge → HomeView
```

## 🚀 Key Features

### Real-time Heart Rate Monitoring
- Continuous heart rate data collection from Apple Watch
- Integration with HealthKit for data persistence
- Real-time data transmission to iPhone app

### AI Training Integration
- Physiological feedback for AI model optimization
- Task-based training sessions
- Progress tracking and analytics

### Cross-device Synchronization
- Seamless communication between iPhone and Apple Watch
- Automatic data synchronization
- Connection status monitoring

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

- Project Maintainer: Ruifang Zhang
- GitHub: [@Ruifangzhang11](https://github.com/Ruifangzhang11)

## 🙏 Acknowledgments

Thanks to Apple for providing HealthKit and WatchConnectivity frameworks, and Supabase for backend service support.

## 🔬 Research Applications

This project demonstrates the potential of using physiological signals (heart rate) as feedback mechanisms for AI training, opening new possibilities in:

- **Human-AI Interaction**: More natural and responsive AI systems
- **Personalized AI**: AI models that adapt to individual physiological responses
- **Health-Aware Computing**: Computing systems that consider user health states
- **Reinforcement Learning**: Novel reward signals based on physiological feedback

## 📊 Future Work

- [ ] Integration with more physiological sensors
- [ ] Advanced AI model training algorithms
- [ ] Cross-platform compatibility
- [ ] Real-time emotion recognition
- [ ] Multi-user collaborative training
