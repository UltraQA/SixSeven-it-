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
                statRow("Current streak", value: statistics.currentStreak)
                statRow("Best streak", value: statistics.bestStreak)
            }

            Section("Outcomes") {
                statRow("6", value: statistics.sixCount)
                statRow("7", value: statistics.sevenCount)
                statRow("67", value: statistics.sixtySevenCount)
                statRow("Current 67 streak", value: statistics.currentSixtySevenStreak)
                statRow("Best 67 streak", value: statistics.bestSixtySevenStreak)
            }
        }
        .navigationTitle("Stats")
    }

    private func statRow(_ title: LocalizedStringKey, value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value, format: .number)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}
