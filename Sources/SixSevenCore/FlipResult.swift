import Foundation

public struct FlipResult: Codable, Equatable, Sendable {
    public let outcome: Outcome
    public let question: String?
    public let date: Date

    public init(outcome: Outcome, question: String? = nil, date: Date = Date()) {
        self.outcome = outcome
        let trimmedQuestion = question?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.question = trimmedQuestion?.isEmpty == false ? trimmedQuestion : nil
        self.date = date
    }
}
