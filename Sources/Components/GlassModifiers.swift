import SwiftUI

/// Wraps content in iOS 26 Liquid Glass where available, falling back to
/// `.ultraThinMaterial` on iOS 17–25 so the app still looks intentional there.
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content.background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

struct PrimaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .font(.headline)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .glassEffect(.regular.tint(.orange).interactive(), in: .rect(cornerRadius: 14))
                .opacity(configuration.isPressed ? 0.8 : 1)
        } else {
            configuration.label
                .font(.headline)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(Color.orange, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }
}

extension ButtonStyle where Self == PrimaryGlassButtonStyle {
    static var primaryGlass: PrimaryGlassButtonStyle { PrimaryGlassButtonStyle() }
}
