import Foundation

/// A typed name and its Hole. Identity is the stable id, never a list index.
struct Row: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var hole: Hole

    var isBlank: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var entersDraw: Bool {
        hole.punched && !isBlank
    }

    static func named(_ name: String, punched: Bool, id: UUID = UUID()) -> Row {
        Row(id: id, name: name, hole: Hole(punched: punched))
    }
}
