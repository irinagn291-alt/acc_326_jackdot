import Foundation

/// Written when Read finds fewer than two punched non-blank Rows. The fold stays.
struct SparMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: Int
    var punchedCount: Int
}
