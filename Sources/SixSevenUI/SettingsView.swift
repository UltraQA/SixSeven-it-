import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        Form {
            Section("Controls") {
                Toggle(
                    "Sound Effects",
                    isOn: Binding(
                        get: { viewModel.settings.soundEffectsEnabled },
                        set: { viewModel.setSoundEffectsEnabled($0) }
                    )
                )

                Toggle(
                    "Motion Control",
                    isOn: Binding(
                        get: { viewModel.settings.motionControlEnabled },
                        set: { viewModel.setMotionControlEnabled($0) }
                    )
                )
            }

            Section {
                Text("Motion Control uses device shake to start a flip when supported.")
                    .font(SixSevenTypography.caption)
                    .foregroundStyle(SixSevenColors.contentSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(SixSevenColors.backgroundPrimary)
        .navigationTitle("Settings")
    }
}
