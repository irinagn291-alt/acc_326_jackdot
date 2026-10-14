import Foundation

/// One bore on a Row. Punched holes are the only candidates a Read may draw.
struct Hole: Codable, Sendable, Equatable {
    var punched: Bool

    static let open = Hole(punched: false)
    static let closed = Hole(punched: true)
}
