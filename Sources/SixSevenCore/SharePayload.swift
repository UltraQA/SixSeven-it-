public enum SharePayload {
    public static func text(for result: FlipResult) -> String {
        let question = result.question.map { "\"\($0)\" → " } ?? ""
        let outcome = result.outcome == .sixtySeven ? "67" : result.outcome.rawValue
        return "I asked SixSeven it!: \(question)\(outcome). Can't decide? Sixseven it."
    }
}
