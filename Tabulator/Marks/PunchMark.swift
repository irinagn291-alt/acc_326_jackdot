import Foundation

/// Trail entry written when Punch toggles a Hole. It does not rewrite a Verdict.
struct PunchMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var rowID: UUID
    var punched: Bool
    var daykey: Int
}
