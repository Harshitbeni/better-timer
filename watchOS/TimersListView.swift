import SwiftUI

struct TimersListView: View {
    @ObservedObject var timerController: TimerController
    @State private var isPresentingAddTimer = false

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
                        Text("Add timers on your watch to get started.")
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
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(timer.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)

                                        Text(formattedRemaining(timer.remainingSeconds))
                                            .font(.title2)
                                            .monospacedDigit()
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }

                                    Spacer()

                                    if timer.state == .running {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundStyle(.tint)
                                    } else if timer.state == .paused {
                                        Image(systemName: "pause.circle")
                                            .foregroundStyle(.tint)
                                    } else if timer.state == .completed {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundStyle(.tint)
                                    }
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("\(timer.title), \(formattedRemaining(timer.remainingSeconds)) remaining")
                                .accessibilityHint("Opens timer details")
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddTimer = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add timer")
                    .accessibilityHint("Create a new countdown")
                }
            }
            .sheet(isPresented: $isPresentingAddTimer) {
                AddTimerView(timerController: timerController)
                    .presentationDetents([.medium])
            }
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
