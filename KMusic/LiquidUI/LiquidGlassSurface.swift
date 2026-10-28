import SwiftUI

public struct LiquidGlassModifier<S: Shape>: ViewModifier {
    public let shape: S
    public let tint: Color?
    public let isInteractive: Bool

    @Environment(\.colorScheme) private var colorScheme

    public init(shape: S, tint: Color? = nil, isInteractive: Bool = false) {
        self.shape = shape
        self.tint = tint
        self.isInteractive = isInteractive
    }

    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Ultra thin material for dynamic blurred refraction
                    shape
                        .fill(.ultraThinMaterial)

                    // Subtle tint if present
                    if let tint {
                        shape
                            .fill(tint.opacity(colorScheme == .dark ? 0.22 : 0.14))
                    } else {
                        shape
                            .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.25))
                    }

                    // Top specular highlight gradient
                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.25 : 0.45),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            }
            .overlay {
                // Glass border rim
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.35 : 0.65),
                                Color.white.opacity(colorScheme == .dark ? 0.08 : 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            }
    }
}

public extension View {
    func liquidGlass<S: Shape>(shape: S, tint: Color? = nil, isInteractive: Bool = false) -> some View {
        modifier(LiquidGlassModifier(shape: shape, tint: tint, isInteractive: isInteractive))
    }
}
