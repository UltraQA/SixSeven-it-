import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// The visual language for the MVP: warm editorial surfaces, high-contrast ink,
/// and three outcome colors that remain distinct in both appearances.
public enum SixSevenColors {
    public static let backgroundPrimary = adaptive(light: 0xF6F6F2, dark: 0x11110F)
    public static let backgroundSecondary = adaptive(light: 0xECECE6, dark: 0x1A1A17)
    public static let surfaceElevated = adaptive(light: 0xFFFFFF, dark: 0x24241F)
    public static let contentPrimary = adaptive(light: 0x171715, dark: 0xF5F4EE)
    public static let contentSecondary = adaptive(light: 0x666660, dark: 0xB9B8AF)
    public static let separator = adaptive(light: 0xD8D8D0, dark: 0x3A3A34)

    /// Outcome colors are intentionally not red/green: the result never implies
    /// a correct or incorrect decision, and the three outcomes stay color-blind friendly.
    public static let accentSix = adaptive(light: 0x155EEF, dark: 0x6D9BFF)
    public static let accentSeven = adaptive(light: 0x6E42D7, dark: 0xB59AFF)
    public static let accentRare = adaptive(light: 0xC87900, dark: 0xFFD166)

    public static let accent = accentSix
    public static let content = contentPrimary
    public static let rare = accentRare
    public static let destructive = Color.red

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
#if os(iOS)
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(hex: hex)
        })
#elseif os(macOS)
        Color(nsColor: NSColor(name: nil) { appearance in
            let hex = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(hex: hex)
        })
#else
        Color(red: Double((light >> 16) & 0xFF) / 255,
              green: Double((light >> 8) & 0xFF) / 255,
              blue: Double(light & 0xFF) / 255)
#endif
    }
}

public enum SixSevenTypography {
    public static let eyebrow = Font.system(.caption, design: .rounded).weight(.bold)
    public static let hero = Font.system(.largeTitle, design: .rounded).weight(.black)
    public static let display = Font.system(.title, design: .rounded).weight(.black)
    public static let title = Font.system(.title2, design: .rounded).weight(.bold)
    public static let body = Font.body
    public static let callout = Font.callout
    public static let caption = Font.caption
    public static let metric = Font.system(.title2, design: .rounded).weight(.bold)
}

public enum SixSevenSpacing {
    public static let hairline: CGFloat = 4
    public static let small: CGFloat = 8
    public static let compact: CGFloat = 12
    public static let standard: CGFloat = 16
    public static let large: CGFloat = 24
    public static let section: CGFloat = 32
    public static let hero: CGFloat = 48
}

public enum SixSevenRadius {
    public static let control: CGFloat = 16
    public static let card: CGFloat = 24
    public static let hero: CGFloat = 32
}

public enum SixSevenCoinMetrics {
    public static let diameter: CGFloat = 220
    public static let borderWidth: CGFloat = 4
    public static let innerBorderWidth: CGFloat = 2
    public static let shadowRadius: CGFloat = 20
    public static let shadowYOffset: CGFloat = 10
    public static let rareScale: CGFloat = 1.06
}

public enum SixSevenTiming {
    public static let flipAnimation: Duration = .milliseconds(650)
    public static let resultCooldown: Duration = .milliseconds(1_250)
}

public enum SixSevenQuestionMetrics {
    public static let maxLength = 80
}

public enum SixSevenSwipeMetrics {
    public static let minimumSurfaceHeight: CGFloat = 240
}

public struct SixSevenCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(SixSevenSpacing.standard)
            .background(SixSevenColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: SixSevenRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: SixSevenRadius.card, style: .continuous)
                    .stroke(SixSevenColors.separator.opacity(0.7), lineWidth: 1)
            }
    }
}

public struct SixSevenSecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SixSevenTypography.title)
            .foregroundStyle(SixSevenColors.contentPrimary)
            .frame(minHeight: 52)
            .padding(.horizontal, SixSevenSpacing.large)
            .background(SixSevenColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: SixSevenRadius.control, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: SixSevenRadius.control, style: .continuous)
                    .stroke(SixSevenColors.separator, lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

public enum SixSevenAccessibility {
    public static let questionInput = "sixseven.questionInput"
    public static let coin = "sixseven.coin"
    public static let shareButton = "sixseven.shareButton"
    public static let statsButton = "sixseven.statsButton"
    public static let settingsButton = "sixseven.settingsButton"
    public static let testToolsButton = "sixseven.testToolsButton"
    public static let resultSummary = "sixseven.resultSummary"
    public static let swipeSurface = "sixseven.swipeSurface"
}

#if os(iOS)
private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
#elseif os(macOS)
private extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            calibratedRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
#endif
