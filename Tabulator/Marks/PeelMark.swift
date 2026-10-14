import Foundation

/// Written when Peel drops the waiting Verdict and folds Read back to Punched.
struct PeelMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var verdictID: UUID
    var daykey: Int
}
