import Foundation

/// Uniform index among punched non-blank Rows. Seed advances only when a Verdict files.
enum SeededDraw {
    /// LCG step: seed * 6364136223846793005 + 1, wrapping UInt64.
    static let multiplier: UInt64 = 6_364_136_223_846_793_005

    static func index(seed: UInt64, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return Int(seed % UInt64(count))
    }

    static func advance(_ seed: UInt64) -> UInt64 {
        seed &* multiplier &+ 1
    }
}
