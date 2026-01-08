//
//  AddTimerView.swift
//  BetterTimer (iOS)
//
//  View for creating new timers
//

import SwiftUI

struct AddTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var timerController: TimerController

    @State private var title: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    @State private var seconds: Int = 0

    private var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    private var isValid: Bool {
        totalSeconds > 0 && totalSeconds <= Config.maxTimerDuration
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Timer Name") {
                    TextField("e.g., Steep Tea, Workout, etc.", text: $title)
                }

                Section("Duration") {
                    HStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<25) { hour in
                                Text("\(hour)").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Text(":")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Text(":")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Picker("Seconds", selection: $seconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .labelsHidden()
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Total Duration")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(formattedDuration(totalSeconds))
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        }

                        if !isValid && totalSeconds > 0 {
                            Text("Maximum duration is 24 hours")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section {
                    Button {
                        let timerTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        timerController.addTimer(
                            title: timerTitle.isEmpty ? "Untitled Timer" : timerTitle,
                            totalSeconds: totalSeconds
                        )
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Create Timer")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("New Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formattedDuration(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 {
            components.append("\(minutes)m")
        }
        if seconds > 0 || components.isEmpty {
            components.append("\(seconds)s")
        }

        return components.joined(separator: " ")
    }
}

#Preview {
    AddTimerView(timerController: TimerController())
}
