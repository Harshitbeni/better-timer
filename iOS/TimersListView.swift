//
//  TimersListView.swift
//  BetterTimer (iOS)
//
//  Main list view showing all timers
//

import SwiftUI

struct TimersListView: View {
    @ObservedObject var timerController: TimerController
    @State private var isPresentingAddTimer = false

    private var activeTimers: [TimerEntry] {
        timerController.timers.filter { $0.state != .completed }
    }

    private var completedTimers: [TimerEntry] {
        timerController.timers.filter { $0.state == .completed }
    }

    var body: some View {
        NavigationStack {
            List {
                if timerController.timers.isEmpty {
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "timer")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        Text("No Timers Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap the + button to create your first timer")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    if !activeTimers.isEmpty {
                        Section("Active") {
                            ForEach(activeTimers) { timer in
                                NavigationLink {
                                    TimerDetailView(timerID: timer.id, timerController: timerController)
                                } label: {
                                    TimerRowView(timer: timer)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteTimer(timer)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    if !completedTimers.isEmpty {
                        Section("Completed") {
                            ForEach(completedTimers) { timer in
                                NavigationLink {
                                    TimerDetailView(timerID: timer.id, timerController: timerController)
                                } label: {
                                    TimerRowView(timer: timer)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteTimer(timer)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
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
                }
            }
            .sheet(isPresented: $isPresentingAddTimer) {
                AddTimerView(timerController: timerController)
            }
        }
    }

    private func deleteTimer(_ timer: TimerEntry) {
        var updatedTimers = timerController.timers
        updatedTimers.removeAll { $0.id == timer.id }
        timerController.setTimers(updatedTimers)
    }
}

struct TimerRowView: View {
    let timer: TimerEntry

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(timer.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(formattedRemaining(timer.remainingSeconds))
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Spacer()

            timerStateIcon
                .font(.title2)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var timerStateIcon: some View {
        switch timer.state {
        case .running:
            Image(systemName: "play.circle.fill")
                .foregroundStyle(.green)
        case .paused:
            Image(systemName: "pause.circle.fill")
                .foregroundStyle(.orange)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.blue)
        case .idle:
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
        }
    }

    private func formattedRemaining(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    let controller = TimerController()
    controller.setTimers([
        TimerEntry(title: "Steep Tea", totalSeconds: 240, remainingSeconds: 120, state: .running),
        TimerEntry(title: "Laundry", totalSeconds: 1800, remainingSeconds: 600, state: .paused),
        TimerEntry(title: "Workout", totalSeconds: 3600, remainingSeconds: 1800, state: .idle),
        TimerEntry(title: "Meditation", totalSeconds: 300, remainingSeconds: 0, state: .completed)
    ])
    return TimersListView(timerController: controller)
}
