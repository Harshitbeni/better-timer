import SwiftUI

@main
struct BetterTimerMacApp: App {
    @StateObject private var timerController = TimerController()
    @State private var showingNewTimerSheet = false

    var body: some Scene {
        MenuBarExtra("BetterTimer", systemImage: "timer") {
            menuContent
        }
        .menuBarExtraStyle(.menu)
        .sheet(isPresented: $showingNewTimerSheet) {
            NewTimerSheet { title, seconds in
                timerController.addTimer(title: title, totalSeconds: seconds)
            }
        }
    }

    @ViewBuilder
    private var menuContent: some View {
        if timerController.timers.isEmpty {
            Text("No timers yet")
                .padding(.vertical, 4)
        } else {
            ForEach(timerController.timers) { timer in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(timer.title)
                            .font(.headline)
                        Text(formattedRemaining(timer))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        toggleStartPause(for: timer)
                    } label: {
                        Label(timer.state == .running ? "Pause" : "Start", systemImage: timer.state == .running ? "pause.fill" : "play.fill")
                    }

                    Button {
                        timerController.reset(timerID: timer.id)
                    } label: {
                        Label("Reset", systemImage: "gobackward")
                    }
                }
                .padding(.vertical, 2)
            }
        }

        Divider()

        Button {
            showingNewTimerSheet = true
        } label: {
            Label("+ New Timer", systemImage: "plus")
        }
    }

    private func toggleStartPause(for timer: TimerEntry) {
        if timer.state == .running {
            timerController.pause(timerID: timer.id)
        } else {
            timerController.start(timerID: timer.id)
        }
    }

    private func formattedRemaining(_ timer: TimerEntry) -> String {
        let remaining = timer.remainingSeconds
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d remaining", minutes, seconds)
    }
}

private struct NewTimerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var durationText: String = ""

    var onCreate: (String, Int) -> Void

    private var durationValue: Int? {
        Int(durationText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create a New Timer")
                .font(.title2)

            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
            TextField("Duration (seconds)", text: $durationText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button("Create") {
                    if let seconds = durationValue, !title.trimmingCharacters(in: .whitespaces).isEmpty {
                        onCreate(title, seconds)
                        dismiss()
                    }
                }
                .disabled(durationValue == nil || title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 320)
    }
}
