import Foundation

/// Written when Punch runs on an Ask that has no Rows. Nothing is added.
struct Blank: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: Int
}
