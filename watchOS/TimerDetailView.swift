import SwiftUI

struct TimerDetailView: View {
    let timerID: UUID
    @ObservedObject var timerController: TimerController

    private var timer: TimerEntry? {
        timerController.timers.first(where: { $0.id == timerID })
    }

    private var progress: Double {
        guard let timer else { return 0 }
        let remaining = Double(timer.remainingSeconds)
        let total = Double(timer.totalSeconds)
        guard total > 0 else { return 0 }
        return 1 - (remaining / total)
    }

    var body: some View {
        VStack(spacing: 12) {
            if let timer {
                Text(timer.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                VStack(spacing: 6) {
                    Text(formattedRemaining(timer.remainingSeconds))
                        .font(.system(.title, design: .rounded))
                        .monospacedDigit()
                    ProgressView(value: progress)
                }

                HStack {
                    Button(timer.state == .running ? "Pause" : "Start") {
                        toggleTimer(for: timer)
                    }
                    .tint(timer.state == .running ? .yellow : .green)

                    Button("Reset") {
                        timerController.reset(timerID: timer.id)
                    }
                    .tint(.red)
                }
                .buttonStyle(.bordered)
            } else {
                Text("Timer not found")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Details")
    }

    private func toggleTimer(for timer: TimerEntry) {
        if timer.state == .running {
            timerController.pause(timerID: timer.id)
        } else {
            timerController.start(timerID: timer.id)
        }
    }

    private func formattedRemaining(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let controller = TimerController()
    let sample = TimerEntry(title: "Sample", totalSeconds: 300, remainingSeconds: 180, state: .running)
    controller.setTimers([sample])
    return NavigationStack {
        TimerDetailView(timerID: sample.id, timerController: controller)
    }
}
