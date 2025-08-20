# NeuralTrain 🧠

**Train Your AI with Physiology**

NeuralTrain is a cutting-edge iOS application that combines physiological feedback with AI training, creating a unique human-AI interaction experience. The app uses heart rate monitoring and user preferences to train AI models through Reinforcement Learning from Human Feedback (RLHF).

## 🌟 Features

### 🏠 Home Dashboard
- **Real-time Heart Rate Monitoring** - Live BPM tracking with Apple Watch integration
- **Daily Goals & Streaks** - Track your AI training progress
- **Smart Connection Status** - Seamless iOS-Watch connectivity
- **Personalized Greetings** - Dynamic user-specific welcome messages

### 🎯 Task Training
- **5 AI Training Categories**:
  - 🤝 **Empathy** - Understanding and compassion
  - 📝 **Clarity** - Clear and concise communication
  - 🧘 **Calmness** - Peaceful and composed responses
  - ✨ **Creativity** - Innovative and imaginative thinking
  - ✅ **Factuality** - Accurate and truthful information

- **Interactive Task Flow**:
  - 30-second reading phases for each option
  - Real-time heart rate data collection
  - Physiological preference analysis
  - Card-flipping animations for engaging UX

### 👤 User Profile & Analytics
- **Neural Network Visualization** - High-tech circuit board brain showing your AI training progress
- **Task History** - Detailed analytics of completed tasks with heart rate comparisons
- **User Authentication** - Secure login and registration system
- **Progress Tracking** - Visual representation of neural connections and training milestones

### 📊 Advanced Analytics
- **Heart Rate Comparison Charts** - Side-by-side analysis of physiological responses
- **Statistical Analysis** - Average, median, and mode calculations for each option
- **Task Metadata** - Comprehensive data including prompts, choices, and timestamps
- **Backend Integration** - Supabase-powered data storage and retrieval

## 🛠 Technical Stack

### Frontend
- **SwiftUI** - Modern iOS UI framework
- **WatchKit** - Apple Watch integration
- **Charts Framework** - Data visualization
- **Combine** - Reactive programming

### Backend & Data
- **Supabase** - Backend-as-a-Service
- **HealthKit** - Health data integration
- **WatchConnectivity** - iOS-Watch communication
- **UserDefaults** - Local data persistence

### Key Technologies
- **RLHF (Reinforcement Learning from Human Feedback)**
- **Physiological Computing**
- **Real-time Data Processing**
- **Neural Network Visualization**

## 📱 Platform Support

- **iOS 18.5+** - Primary application
- **watchOS 11.5+** - Heart rate monitoring and data collection
- **Apple Watch Integration** - Seamless connectivity and background processing

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 18.5+ device
- Apple Watch (for full functionality)
- Supabase account (for backend services)

### Installation
1. Clone the repository
2. Open `PhysioRLHFApp-2.xcodeproj` in Xcode
3. Configure your Supabase credentials in `AppConfig.swift`
4. Build and run on your device

### Configuration
- Update `AppConfig.swift` with your Supabase URL and API key
- Configure HealthKit permissions in your device settings
- Ensure Apple Watch is paired and connected

## 📊 Data Flow

1. **Task Presentation** - User is presented with A/B options
2. **Physiological Monitoring** - Heart rate data is collected during reading phases
3. **User Choice** - User selects preferred option
4. **Data Analysis** - Physiological responses are analyzed
5. **Backend Storage** - Data is uploaded to Supabase with comprehensive metadata
6. **Neural Network Update** - Visual representation is updated with new connections

## 🎨 UI/UX Features

- **Glassmorphism Design** - Modern frosted glass effects
- **Gradient Animations** - Dynamic color transitions
- **Card-based Interface** - Intuitive task presentation
- **Real-time Animations** - Responsive and engaging interactions
- **Dark/Light Mode Support** - Adaptive theming

## 🔬 Research Applications

This application serves as a research platform for:
- **Physiological Computing** - Understanding human-AI interaction through biometrics
- **RLHF Optimization** - Improving AI training through physiological feedback
- **Human-Computer Interaction** - Exploring new interaction paradigms
- **AI Ethics** - Studying human preferences in AI behavior

## 📈 Future Enhancements

- [ ] **Multi-modal Data Collection** - EEG, GSR, and other biometrics
- [ ] **Advanced ML Models** - Real-time preference prediction
- [ ] **Social Features** - Community-driven AI training
- [ ] **Cross-platform Support** - Android and web versions
- [ ] **API Integration** - Third-party AI model training

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for more details.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Apple** - For HealthKit and WatchKit frameworks
- **Supabase** - For backend infrastructure
- **Research Community** - For RLHF methodology and insights

---

**NeuralTrain** - Where human physiology meets AI training 🧠⚡
