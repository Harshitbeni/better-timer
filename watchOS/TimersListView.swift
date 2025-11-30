import SwiftUI

struct TimersListView: View {
    @ObservedObject var timerController: TimerController

    private var nextTimer: TimerEntry? {
        timerController.timers
            .filter { $0.state != .completed }
            .sorted { $0.remainingSeconds < $1.remainingSeconds }
            .first
    }

    var body: some View {
        NavigationStack {
            List {
                if timerController.timers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No timers yet")
                            .font(.headline)
                        Text("Add timers on your other devices to see them here.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                } else {
                    Section("Timers") {
                        ForEach(timerController.timers) { timer in
                            NavigationLink {
                                TimerDetailView(timerID: timer.id, timerController: timerController)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(timer.title)
                                            .font(.headline)
                                        Text(formattedRemaining(timer.remainingSeconds))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if timer.state == .running {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundStyle(.green)
                                    } else if timer.state == .paused {
                                        Image(systemName: "pause.circle")
                                            .foregroundStyle(.yellow)
                                    } else if timer.state == .completed {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Complication placeholder") {
                    if let nextTimer {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next timer")
                                .font(.headline)
                            Text("\(nextTimer.title) – \(formattedRemaining(nextTimer.remainingSeconds))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Complications will show your next timer here.")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Timers")
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
    controller.setTimers([
        TimerEntry(title: "Steep tea", totalSeconds: 240, remainingSeconds: 120, state: .running),
        TimerEntry(title: "Laundry", totalSeconds: 1800, remainingSeconds: 600, state: .paused),
        TimerEntry(title: "Stretch", totalSeconds: 300, remainingSeconds: 0, state: .completed)
    ])
    return TimersListView(timerController: controller)
}
