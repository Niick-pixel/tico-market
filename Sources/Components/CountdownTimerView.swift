import SwiftUI

/// Large countdown used on the live auction screen.
struct CountdownTimerView: View {
    let endsAt: Date
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var remaining: TimeInterval { max(0, endsAt.timeIntervalSince(now)) }
    private var isEndingSoon: Bool { remaining < 300 }
    private var hasEnded: Bool { remaining <= 0 }

    var body: some View {
        VStack(spacing: 4) {
            Text(hasEnded ? "Subasta terminada" : formatted(remaining))
                .font(.title2.monospacedDigit().bold())
                .foregroundStyle(hasEnded ? Color.secondary : (isEndingSoon ? Color.red : Color.primary))
            if isEndingSoon && !hasEnded {
                Text("¡Termina pronto!")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }
        }
        .onReceive(timer) { now = $0 }
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Compact chip used on listing rows/cards.
struct CountdownChip: View {
    let endsAt: Date
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var remaining: TimeInterval { max(0, endsAt.timeIntervalSince(now)) }
    private var isEndingSoon: Bool { remaining < 300 && remaining > 0 }

    var body: some View {
        Text(remaining <= 0 ? "Terminada" : label(remaining))
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(isEndingSoon ? Color.white : Color.primary)
            .background(isEndingSoon ? Color.red : Color.clear, in: Capsule())
            .glassCard(cornerRadius: 12)
            .onReceive(timer) { now = $0 }
    }

    private func label(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        if totalMinutes >= 60 {
            return "\(totalMinutes / 60) h"
        } else if totalMinutes > 0 {
            return "\(totalMinutes) min"
        }
        return "<1 min"
    }
}
