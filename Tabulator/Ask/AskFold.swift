import Foundation

/// Fold cases of the punch card. Open has no live punch, Punched has holes
/// set and no filed pick waiting, Read holds the newest Verdict until Peel.
enum AskFold: String, Codable, Sendable, Equatable {
    case open
    case punched
    case read
}
