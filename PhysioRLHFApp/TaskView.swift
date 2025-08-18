import SwiftUI

struct TaskView: View {
    @State private var selectedOption: String? = nil
    @State private var startTime: Date? = nil
    @State private var endTime: Date? = nil
    @Environment(\.presentationMode) var presentationMode

    let options = ["Option A", "Option B", "Option C"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Q: Which option do you prefer?")
                .font(.title2)
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    HStack {
                        Text(option)
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            Spacer()
            Button(action: {
                endTime = Date()
                print("Task started at: \(startTime ?? Date()), ended at: \(endTime!)")
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Submit")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            startTime = Date()
        }
    }
}

#Preview {
    TaskView()
}
