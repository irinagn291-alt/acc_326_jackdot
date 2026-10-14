import UIKit

/// One typed name and its hole. Punch hits the whole hole control.
final class RowCell: UITableViewCell {
    static let reuseID = "RowCell"

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var holeButton: UIButton!
    @IBOutlet private weak var plate: UIView!

    var onPunch: (() -> Void)?

    func bind(row: Row) {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        Kit.hairline(plate, radius: Radius.chip)
        nameLabel.textColor = Kit.ink
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        holeButton.layer.cornerRadius = Radius.chip
        holeButton.layer.borderWidth = Elevation.hairline
        holeButton.layer.borderColor = Kit.muted.cgColor
        nameLabel.text = row.name
        nameLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
        let punched = row.hole.punched
        holeButton.backgroundColor = punched ? Kit.accent : Kit.bg
        holeButton.setTitle(punched ? "In" : "Out", for: .normal)
        holeButton.setTitleColor(punched ? Kit.bg : Kit.ink, for: .normal)
        holeButton.titleLabel?.font = TypeScale.font(.micro, compatibleWith: traitCollection)
        let verb = punched ? "Unpunch" : "Punch"
        holeButton.accessibilityLabel = verb + " " + row.name
    }

    @IBAction func punchTapped() {
        onPunch?()
    }
}
