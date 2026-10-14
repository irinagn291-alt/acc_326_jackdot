import Foundation

/// One filed pick. daykey is YYYYMMDD from Calendar.current.startOfDay.
struct Verdict: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var rowID: UUID
    var rowName: String
    var daykey: Int
}
