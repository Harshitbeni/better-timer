import SwiftUI

struct AddTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var timerController: TimerController

    @State private var title: String = ""
    @State private var minutes: Int = 1

    private var totalSeconds: Int {
        max(minutes, 0) * 60
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    Stepper(value: $minutes, in: 0...240) {
                        HStack {
                            Text("Length")
                            Spacer()
                            Text("\(minutes) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Timer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel new timer")
                    .accessibilityHint("Closes without saving")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        timerController.addTimer(title: title.isEmpty ? "Untitled" : title,
                                                 totalSeconds: totalSeconds)
                        dismiss()
                    }
                    .disabled(totalSeconds <= 0)
                    .accessibilityLabel("Add timer")
                    .accessibilityHint("Saves the timer and starts from idle")
                }
            }
        }
    }
}

#Preview {
    AddTimerView(timerController: TimerController())
}
