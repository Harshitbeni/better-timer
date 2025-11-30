#if canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct BetterTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BetterTimerAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.title)
                            .font(.headline)
                        Text(timeRemainingText(for: context.state.remainingSeconds))
                            .font(.title2.monospacedDigit())
                            .bold()
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    StatusPill(isRunning: context.state.isRunning)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: progressValue(for: context))
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                }
            } compactLeading: {
                Text(timeRemainingText(for: context.state.remainingSeconds))
                    .font(.caption2.monospacedDigit())
            } compactTrailing: {
                StatusSymbol(isRunning: context.state.isRunning)
            } minimal: {
                StatusSymbol(isRunning: context.state.isRunning)
            }
        }
    }

    private func timeRemainingText(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    private func progressValue(for context: ActivityViewContext<BetterTimerAttributes>) -> Double {
        let total = Double(context.attributes.totalSeconds)
        guard total > 0 else { return 0 }
        return 1 - (Double(context.state.remainingSeconds) / total)
    }
}

@available(iOS 16.1, *)
private struct LockScreenView: View {
    let context: ActivityViewContext<BetterTimerAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(context.attributes.title)
                    .font(.headline)
                Spacer()
                StatusPill(isRunning: context.state.isRunning)
            }

            HStack {
                Text("Remaining")
                Spacer()
                Text(timeRemainingText(for: context.state.remainingSeconds))
                    .font(.title2.monospacedDigit())
                    .bold()
            }

            ProgressView(value: progressValue(for: context))
                .progressViewStyle(.linear)
        }
        .padding()
    }

    private func timeRemainingText(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    private func progressValue(for context: ActivityViewContext<BetterTimerAttributes>) -> Double {
        let total = Double(context.attributes.totalSeconds)
        guard total > 0 else { return 0 }
        return 1 - (Double(context.state.remainingSeconds) / total)
    }
}

@available(iOS 16.1, *)
private struct StatusPill: View {
    let isRunning: Bool

    var body: some View {
        Text(isRunning ? "Running" : "Paused")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isRunning ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundColor(isRunning ? .green : .orange)
            .clipShape(Capsule())
    }
}

@available(iOS 16.1, *)
private struct StatusSymbol: View {
    let isRunning: Bool

    var body: some View {
        Image(systemName: isRunning ? "play.fill" : "pause.fill")
            .foregroundStyle(isRunning ? .green : .orange)
    }
}

@available(iOS 16.1, *)
struct BetterTimerLiveActivity_Previews: PreviewProvider {
    static var previews: some View {
        let attributes = BetterTimerAttributes(timerID: UUID(), title: "Focus Timer", totalSeconds: 1500)
        let state = BetterTimerActivityState(remainingSeconds: 1200, title: "Focus Timer", isRunning: true)

        return attributes
            .previewContext(state, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
    }
}
#endif
