import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public enum SixSevenColors {
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
    public static let accent = Color.indigo
    public static let rare = Color.orange
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
    public static let small: CGFloat = 8
    public static let standard: CGFloat = 16
    public static let large: CGFloat = 24
    public static let hero: CGFloat = 48
}
