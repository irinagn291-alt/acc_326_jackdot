import UIKit

/// Filled capsule for Read, and the destructive twin for reset.
/// Spar is copy on the same accent, not a second color.
final class PressButton: UIButton {
    enum Role {
        case read
        case peel
        case destructive
        case quiet
    }

    var kind: Role = .read {
        didSet { applyKind() }
    }

    private var sparCopy = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        common()
    }

    private func common() {
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        layer.cornerCurve = .continuous
        clipsToBounds = true
        applyKind()
    }

    func setSpar(_ spar: Bool, title: String) {
        sparCopy = spar
        setTitle(title, for: .normal)
        applyKind()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        switch kind {
        case .read, .destructive:
            layer.cornerRadius = bounds.height / 2
        case .peel, .quiet:
            layer.cornerRadius = Radius.chip
        }
    }

    override var isHighlighted: Bool {
        didSet { animatePress() }
    }

    override var isEnabled: Bool {
        didSet { applyKind() }
    }

    private func applyKind() {
        let traits = traitCollection
        titleLabel?.font = TypeScale.font(.headline, compatibleWith: traits)
        switch kind {
        case .read:
            backgroundColor = isEnabled ? Kit.accent : Kit.surface
            setTitleColor(isEnabled ? Kit.bg : Kit.muted, for: .normal)
            layer.borderWidth = isEnabled ? 0 : Elevation.hairline
            layer.borderColor = Kit.muted.cgColor
        case .destructive:
            backgroundColor = Kit.surface
            setTitleColor(Kit.ink, for: .normal)
            layer.borderWidth = Elevation.hairline
            layer.borderColor = Kit.ink.cgColor
        case .peel, .quiet:
            backgroundColor = Kit.surface
            setTitleColor(Kit.ink, for: .normal)
            layer.borderWidth = Elevation.hairline
            layer.borderColor = Kit.muted.cgColor
        }
        alpha = isEnabled ? 1 : 0.55
        setNeedsLayout()
    }

    private func animatePress() {
        let reduced = UIAccessibility.isReduceMotionEnabled
        let scale: CGFloat = (isHighlighted && !reduced) ? Motion.pressScale : 1
        let fade: CGFloat = isHighlighted ? 0.82 : 1
        UIView.animate(withDuration: Motion.pressDuration, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.alpha = self.isEnabled ? fade : 0.55
        }
    }
}
