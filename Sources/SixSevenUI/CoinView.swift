import SwiftUI
import SixSevenCore

public struct CoinView: View {
    public let outcome: Outcome?
    public let isFlipping: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var coinDiameter: CGFloat = 220
    @ScaledMetric(relativeTo: .largeTitle) private var valueFontSize: CGFloat = 88

    public init(outcome: Outcome?, isFlipping: Bool) {
        self.outcome = outcome
        self.isFlipping = isFlipping
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(SixSevenColors.accent.gradient)
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 4))
                .shadow(color: .black.opacity(0.18), radius: 16, y: 8)

            Text(displayValue)
                .font(.system(size: valueFontSize, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
        }
        .frame(width: coinDiameter, height: coinDiameter)
        .rotation3DEffect(
            .degrees(isFlipping && !reduceMotion ? 720 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(
            reduceMotion ? .easeOut(duration: 0.2) : .easeInOut(duration: 0.65),
            value: isFlipping
        )
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(SixSevenAccessibility.coin)
        .accessibilityLabel("Coin result")
        .accessibilityValue(accessibilityValue)
    }

    private var displayValue: String {
        if isFlipping { return "?" }
        return outcome?.rawValue ?? "?"
    }

    private var accessibilityValue: String {
        if isFlipping { return "Flipping" }
        guard let outcome else { return "Ready" }
        return outcome == .sixtySeven ? "SIX SEVEN" : outcome.rawValue
    }
}
