import Foundation

/// History card for one Verdict, kept in Verdict order. daykey matches that Verdict.
struct DecisionRecord: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var verdictID: UUID
    var rowID: UUID
    var rowName: String
    var daykey: Int
}
