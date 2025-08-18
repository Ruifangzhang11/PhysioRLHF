import SwiftUI

struct ContentView: View {
    @State private var heartRate: Int = 0
    @State private var isConnected: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 标题
                Text("❤️ Physio-RLHF")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
                
                // 心率显示
                VStack(spacing: 10) {
                    Text("\(heartRate)")
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                    Text("BPM")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // 连接状态
                HStack {
                    Image(systemName: isConnected ? "applewatch.watchface" : "applewatch")
                        .foregroundColor(isConnected ? .green : .red)
                    Text(isConnected ? "Watch Connected" : "Watch Not Connected")
                        .foregroundColor(isConnected ? .green : .red)
                }
                .padding()
                
                // 控制按钮
                VStack(spacing: 15) {
                    Button("Start Monitoring") {
                        // 模拟开始监测
                        startMonitoring()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Stop Monitoring") {
                        // 模拟停止监测
                        stopMonitoring()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Physio-RLHF")
        }
    }
    
    private func startMonitoring() {
        // 模拟心率数据
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            heartRate = Int.random(in: 60...100)
        }
        isConnected = true
    }
    
    private func stopMonitoring() {
        heartRate = 0
        isConnected = false
    }
}

#Preview {
    ContentView()
}
