import SwiftUI
import SixSevenCore

public struct StatsView: View {
    public let statistics: Statistics

    public init(statistics: Statistics) {
        self.statistics = statistics
    }

    public var body: some View {
        List {
            Section("Overview") {
                statRow("Total flips", value: statistics.totalFlips)
                statRow("Current same-outcome streak", value: statistics.currentStreak)
                statRow("Best same-outcome streak", value: statistics.bestStreak)
            }

            Section("Outcomes") {
                statRow("6", value: statistics.sixCount, color: SixSevenColors.accentSix)
                statRow("7", value: statistics.sevenCount, color: SixSevenColors.accentSeven)
                statRow("67", value: statistics.sixtySevenCount, color: SixSevenColors.accentRare)
                statRow("Current 67 streak", value: statistics.currentSixtySevenStreak)
                statRow("Best 67 streak", value: statistics.bestSixtySevenStreak)
            }
        }
        .scrollContentBackground(.hidden)
        .background(SixSevenColors.backgroundPrimary)
        .navigationTitle("Stats")
    }

    private func statRow(
        _ title: LocalizedStringKey,
        value: Int,
        color: Color? = nil
    ) -> some View {
        HStack {
            if let color {
                Text(title)
                    .font(SixSevenTypography.title)
                    .foregroundStyle(color)
                    .frame(width: 42, alignment: .leading)
            } else {
                Text(title)
                    .font(SixSevenTypography.body)
            }
            Spacer()
            Text(value, format: .number)
                .font(SixSevenTypography.metric)
                .foregroundStyle(SixSevenColors.contentPrimary)
                .monospacedDigit()
        }
        .listRowBackground(SixSevenColors.surfaceElevated)
        .accessibilityElement(children: .combine)
    }
}
