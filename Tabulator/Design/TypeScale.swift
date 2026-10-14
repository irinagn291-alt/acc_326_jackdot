import UIKit

/// Six type steps. Display and title are Impact for the Verdict word and the
/// fold status. Body and below stay the system face.
enum TypeScale {
    enum Step {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func font(_ step: Step, compatibleWith traits: UITraitCollection) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle(step))
        let base = baseFont(step)
        return metrics.scaledFont(for: base, compatibleWith: traits)
    }

    static func textStyle(_ step: Step) -> UIFont.TextStyle {
        switch step {
        case .display: .largeTitle
        case .title: .title1
        case .headline: .headline
        case .body: .body
        case .caption: .footnote
        case .micro: .caption2
        }
    }

    private static func baseFont(_ step: Step) -> UIFont {
        switch step {
        case .display:
            return impact(size: Space.x8 + Space.x4) ?? heavy(size: Space.x8 + Space.x4)
        case .title:
            return impact(size: Space.x6 + Space.x1) ?? heavy(size: Space.x6 + Space.x1)
        case .headline:
            return .systemFont(ofSize: Space.x4 + Space.x2, weight: .semibold)
        case .body:
            return .systemFont(ofSize: Space.x4 + Space.unit, weight: .regular)
        case .caption:
            return .systemFont(ofSize: Space.x3 + Space.unit, weight: .regular)
        case .micro:
            return .systemFont(ofSize: Space.x2 + Space.unit, weight: .medium)
        }
    }

    private static func impact(size: CGFloat) -> UIFont? {
        UIFont(name: DesignTokens.fontFamily, size: size)
    }

    private static func heavy(size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .heavy)
    }
}

/// One spacing unit. Every inset is a multiple of it.
enum Space {
    static let unit: CGFloat = 4
    static var x1: CGFloat { unit }
    static var x2: CGFloat { unit * 2 }
    static var x3: CGFloat { unit * 3 }
    static var x4: CGFloat { unit * 4 }
    static var x5: CGFloat { unit * 5 }
    static var x6: CGFloat { unit * 6 }
    static var x8: CGFloat { unit * 8 }
    static var x10: CGFloat { unit * 10 }
    static var x12: CGFloat { unit * 12 }
    static var hit: CGFloat { unit * 11 }
}

/// Card 20 and chip 12. The only radii in the app.
enum Radius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

/// Hairline plus flat fill. No second elevation.
enum Elevation {
    static let hairline: CGFloat = 1
}

/// Press and sheet motion. Reduce Motion drops scale and keeps the fade.
enum Motion {
    static let pressScale: CGFloat = 0.97
    static let pressDuration: TimeInterval = 0.16
    static let sheetScale: CGFloat = 0.96
    static let sheetDuration: TimeInterval = 0.22
}

enum Kit {
    static var bg: UIColor { UIColor(DesignTokens.bg) }
    static var surface: UIColor { UIColor(DesignTokens.surface) }
    static var ink: UIColor { UIColor(DesignTokens.ink) }
    static var accent: UIColor { UIColor(DesignTokens.accent) }
    static var muted: UIColor { UIColor(DesignTokens.muted) }

    @MainActor
    static func hairline(_ view: UIView, radius: CGFloat) {
        view.backgroundColor = surface
        view.layer.cornerRadius = radius
        view.layer.borderWidth = Elevation.hairline
        view.layer.borderColor = muted.cgColor
        view.layer.masksToBounds = true
    }
}

enum CountFormat {
    static func string(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

enum DayFormat {
    static func string(daykey: Int) -> String {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let calendar = Calendar.current
        let date = calendar.date(from: parts).map { calendar.startOfDay(for: $0) } ?? calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
