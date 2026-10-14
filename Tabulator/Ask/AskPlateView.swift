import UIKit

/// Registration ticks on the Ask plate only. Core Graphics stays on this one surface.
final class AskPlateView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        contentMode = .redraw
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
        contentMode = .redraw
        isAccessibilityElement = false
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setStrokeColor(Kit.muted.cgColor)
        context.setLineWidth(Elevation.hairline)
        let inset = Space.x3
        var cursor = inset
        while cursor < rect.width - inset {
            context.move(to: CGPoint(x: cursor, y: inset))
            context.addLine(to: CGPoint(x: cursor, y: inset + Space.x2))
            context.move(to: CGPoint(x: cursor, y: rect.height - inset - Space.x2))
            context.addLine(to: CGPoint(x: cursor, y: rect.height - inset))
            cursor += Space.x4
        }
        context.strokePath()
    }
}
