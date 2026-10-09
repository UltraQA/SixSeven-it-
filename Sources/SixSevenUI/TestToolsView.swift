import SwiftUI
import SixSevenCore

#if os(iOS)
import UIKit
#endif

public struct TestToolsMenu: View {
    @ObservedObject private var settingsViewModel: SettingsViewModel
    private let onForceOutcome: (Outcome) -> Void
    @State private var iconErrorMessage: String?

    public init(
        settingsViewModel: SettingsViewModel,
        onForceOutcome: @escaping (Outcome) -> Void
    ) {
        _settingsViewModel = ObservedObject(wrappedValue: settingsViewModel)
        self.onForceOutcome = onForceOutcome
    }

    public var body: some View {
        Menu {
            Section("App Icon") {
                Button {
                    setAppIcon(.primary)
                } label: {
                    iconMenuLabel("Variant 1", assetName: "AppIcon")
                }

                Button {
                    setAppIcon(.variant2)
                } label: {
                    iconMenuLabel("Variant 2", assetName: "AppIconVariant2")
                }
            }

            Section("Theme") {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button {
                        settingsViewModel.setTheme(theme)
                    } label: {
                        themeMenuLabel(theme)
                    }
                }
            }

            Section("Cheats") {
                ForEach(Outcome.allCases, id: \.self) { outcome in
                    Button(outcome.rawValue) {
                        onForceOutcome(outcome)
                    }
                }
            }
        } label: {
            Image(systemName: "hammer")
                .accessibilityLabel("Test tools")
        }
        .accessibilityIdentifier(SixSevenAccessibility.testToolsButton)
        .alert(
            "Test Tools",
            isPresented: Binding(
                get: { iconErrorMessage != nil },
                set: { if !$0 { iconErrorMessage = nil } }
            ),
            presenting: iconErrorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private func iconMenuLabel(_ title: String, assetName: String) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private func themeMenuLabel(_ theme: AppTheme) -> some View {
        Label {
            Text(theme.title)
        } icon: {
            Image(systemName: theme.systemImageName)
        }
    }

    private func setAppIcon(_ variant: AppIconVariant) {
#if os(iOS)
        guard UIApplication.shared.supportsAlternateIcons else {
            iconErrorMessage = "Alternate app icons are unavailable in this build."
            return
        }

        UIApplication.shared.setAlternateIconName(variant.alternateName) { error in
            guard let error else { return }
            let message = error.localizedDescription
            Task { @MainActor in
                iconErrorMessage = message
            }
        }
#else
        iconErrorMessage = "App icon switching is only available on iOS."
#endif
    }
}

private enum AppIconVariant {
    case primary
    case variant2

    var alternateName: String? {
        switch self {
        case .primary: nil
        case .variant2: "AppIconVariant2"
        }
    }
}

private extension AppTheme {
    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var systemImageName: String {
        switch self {
        case .system: "iphone"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}
