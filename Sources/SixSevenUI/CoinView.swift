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
                .fill(coinColor.gradient)
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: SixSevenCoinMetrics.borderWidth))
                .shadow(
                    color: coinColor.opacity(0.35),
                    radius: SixSevenCoinMetrics.shadowRadius,
                    y: SixSevenCoinMetrics.shadowYOffset
                )

            if outcome == .sixtySeven && !isFlipping {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.9))
                    .offset(y: -coinDiameter * 0.28)
                    .accessibilityHidden(true)
            }

            Text(displayValue)
                .font(.system(size: valueFontSize, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
        }
        .frame(width: coinDiameter, height: coinDiameter)
        .scaleEffect(outcome == .sixtySeven && !isFlipping ? SixSevenCoinMetrics.rareScale : 1)
        .rotation3DEffect(
            .degrees(isFlipping && !reduceMotion ? 720 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(
            reduceMotion ? .easeOut(duration: 0.2) : .easeInOut(duration: 0.65),
            value: isFlipping
        )
        .animation(
            reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.65),
            value: outcome
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

    private var coinColor: Color {
        switch outcome {
        case .six:
            SixSevenColors.accentSix
        case .seven:
            SixSevenColors.accentSeven
        case .sixtySeven:
            SixSevenColors.accentRare
        case nil:
            SixSevenColors.accent
        }
    }

    private var accessibilityValue: String {
        if isFlipping { return "Flipping" }
        guard let outcome else { return "Ready" }
        return outcome == .sixtySeven ? "SIX SEVEN" : outcome.rawValue
    }
}
