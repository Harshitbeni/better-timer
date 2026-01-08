//
//  TimerDetailView.swift
//  BetterTimer (iOS)
//
//  Detail view for a single timer with controls
//

import SwiftUI

struct TimerDetailView: View {
    let timerID: UUID
    @ObservedObject var timerController: TimerController
    @Environment(\.dismiss) private var dismiss

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
        ZStack {
            if let timer {
                VStack(spacing: 32) {
                    Spacer()

                    // Timer Title
                    Text(timer.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Progress Ring
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 20)
                            .frame(width: 280, height: 280)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(progressColor(for: timer.state), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)

                        VStack(spacing: 8) {
                            Text(formattedRemaining(timer.remainingSeconds))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .monospacedDigit()

                            Text(stateText(for: timer.state))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Controls
                    HStack(spacing: 24) {
                        Button {
                            timerController.reset(timerID: timer.id)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title2)
                                Text("Reset")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .tint(.primary)

                        Button {
                            toggleTimer(for: timer)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: timer.state == .running ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                Text(timer.state == .running ? "Pause" : "Start")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(timer.state == .running ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .tint(timer.state == .running ? .orange : .green)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)
                    Text("Timer Not Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Button("Go Back") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleTimer(for timer: TimerEntry) {
        if timer.state == .running {
            timerController.pause(timerID: timer.id)
        } else {
            timerController.start(timerID: timer.id)
        }
    }

    private func progressColor(for state: TimerState) -> Color {
        switch state {
        case .running:
            return .green
        case .paused:
            return .orange
        case .completed:
            return .blue
        case .idle:
            return .secondary
        }
    }

    private func stateText(for state: TimerState) -> String {
        switch state {
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        case .idle:
            return "Ready"
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
    let sample = TimerEntry(title: "Meditation", totalSeconds: 600, remainingSeconds: 380, state: .running)
    controller.setTimers([sample])
    return NavigationStack {
        TimerDetailView(timerID: sample.id, timerController: controller)
    }
}
