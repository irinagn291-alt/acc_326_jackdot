import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #0F0F0F
    static let bg = Color(red: 0.058824, green: 0.058824, blue: 0.058824)
    static let bgHex = "#0F0F0F"
    /// #1F1F1F
    static let surface = Color(red: 0.121569, green: 0.121569, blue: 0.121569)
    static let surfaceHex = "#1F1F1F"
    /// #FAFAFA
    static let ink = Color(red: 0.980392, green: 0.980392, blue: 0.980392)
    static let inkHex = "#FAFAFA"
    /// #EABC53
    static let accent = Color(red: 0.917647, green: 0.737255, blue: 0.325490)
    static let accentHex = "#EABC53"
    /// #B2B2B2
    static let muted = Color(red: 0.698039, green: 0.698039, blue: 0.698039)
    static let mutedHex = "#B2B2B2"
    static let fontFamily = "Impact"
}
