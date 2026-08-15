import SwiftUI

struct StatusBadge: View {
    let text: String
    var color: Color = .orange

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(color, in: Capsule())
    }
}
