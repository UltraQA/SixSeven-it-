import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public enum SixSevenColors {
    public static var backgroundPrimary: Color { background }
    public static var backgroundSecondary: Color { surface }
    public static let contentPrimary = Color.primary
    public static let contentSecondary = Color.secondary
    public static let accentSix = Color.blue
    public static let accentSeven = Color.purple
    public static let accentRare = Color.orange
    public static let surfaceElevated: Color = {
#if os(iOS)
        Color(uiColor: .tertiarySystemGroupedBackground)
#elseif os(macOS)
        Color(nsColor: .textBackgroundColor)
#endif
    }()
    public static let separator = Color.primary.opacity(0.18)
    public static let destructive = Color.red

    public static var background: Color {
#if os(iOS)
        Color(uiColor: .systemGroupedBackground)
#elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
#endif
    }

    public static var surface: Color {
#if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
#elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
#endif
    }

    public static let content = Color.primary
    public static let secondaryContent = Color.secondary
    public static let accent = accentSix
    public static let rare = accentRare
}

public enum SixSevenTypography {
    public static let hero = Font.system(.largeTitle, design: .rounded).weight(.black)
    public static let display = Font.largeTitle.bold()
    public static let title = Font.title2.weight(.semibold)
    public static let body = Font.body
    public static let caption = Font.caption
}

public enum SixSevenRadius {
    public static let control: CGFloat = 8
    public static let card: CGFloat = 16
    public static let hero: CGFloat = 24
}

public enum SixSevenAccessibility {
    public static let questionInput = "sixseven.questionInput"
    public static let coin = "sixseven.coin"
    public static let flipButton = "sixseven.flipButton"
    public static let shareButton = "sixseven.shareButton"
    public static let statsButton = "sixseven.statsButton"
    public static let settingsButton = "sixseven.settingsButton"
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
