import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🧠 Physio-RLHF Task")
                    .font(.largeTitle)
                    .bold()
                NavigationLink(destination: TaskView()) {
                    Text("Start Task")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
