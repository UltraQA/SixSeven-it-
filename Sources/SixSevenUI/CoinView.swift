import SwiftUI
import SixSevenCore

public struct CoinView: View {
    public let outcome: Outcome?
    public let isFlipping: Bool
    public let flipCount: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var coinDiameter: CGFloat = SixSevenCoinMetrics.diameter
    @ScaledMetric(relativeTo: .largeTitle) private var valueFontSize: CGFloat = 88

    public init(outcome: Outcome?, isFlipping: Bool, flipCount: Int = 0) {
        self.outcome = outcome
        self.isFlipping = isFlipping
        self.flipCount = flipCount
    }

    public var body: some View {
        ZStack {
            if !isFlipping, let imageAssetName {
                Image(imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: coinDiameter, height: coinDiameter)
                    .scaleEffect(1.42)
                    .shadow(
                        color: coinColor.opacity(0.35),
                        radius: SixSevenCoinMetrics.shadowRadius,
                        y: SixSevenCoinMetrics.shadowYOffset
                    )
                    .accessibilityHidden(true)
            } else {
                generatedCoin
            }
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

    private var generatedCoin: some View {
        ZStack {
            Circle()
                .fill(coinGradient)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.52), lineWidth: SixSevenCoinMetrics.borderWidth)
                        .padding(SixSevenSpacing.small)
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.22), lineWidth: SixSevenCoinMetrics.innerBorderWidth)
                        .padding(SixSevenSpacing.compact)
                }
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: coinDiameter * 0.2, height: coinDiameter * 0.2)
                        .blur(radius: 2)
                        .offset(x: coinDiameter * 0.22, y: coinDiameter * 0.16)
                }
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
                .shadow(color: .black.opacity(0.18), radius: 1, y: 2)
                .contentTransition(.numericText())
        }
    }

    private var imageAssetName: String? {
        switch outcome {
        case nil: "CoinIdle"
        case .six: "CoinSix"
        case .seven: "CoinSeven"
        case .sixtySeven: "CoinSixtySeven"
        }
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

    private var coinGradient: LinearGradient {
        LinearGradient(
            colors: [coinColor.opacity(0.82), coinColor, coinColor.opacity(0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var accessibilityValue: String {
        if isFlipping { return "Flipping" }
        guard let outcome else { return "Ready" }
        let outcomeValue = outcome == .sixtySeven ? "SIX SEVEN" : outcome.rawValue
        return "\(outcomeValue), flip \(flipCount)"
    }
}
