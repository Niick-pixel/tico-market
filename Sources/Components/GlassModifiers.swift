import SwiftUI

/// Card background used across the app.
///
/// This currently renders `.ultraThinMaterial` rather than the real iOS 26
/// `.glassEffect()` API: `#available` only gates *runtime* behavior, but the
/// `glassEffect` symbol itself doesn't exist in SDKs older than Xcode 26, so
/// referencing it fails to *compile* on any older toolchain (including the
/// Xcode 16.4 that GitHub's macOS CI runners currently ship). Once building
/// with Xcode 26 is available (locally or in CI), swap the body below for
/// `content.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))`.
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content.background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

struct PrimaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(Color.orange, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension ButtonStyle where Self == PrimaryGlassButtonStyle {
    static var primaryGlass: PrimaryGlassButtonStyle { PrimaryGlassButtonStyle() }
}
