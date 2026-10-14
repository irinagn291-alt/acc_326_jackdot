import UIKit

/// Settings sheet: rerun the intro, erase the card, and the contact link.
/// The status line names the seeded generator.
final class SettingsViewController: SheetMotionController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var contactButton: PressButton!
    @IBOutlet private weak var retryButton: PressButton!
    @IBOutlet private weak var resetButton: PressButton!
    @IBOutlet private weak var rerunButton: PressButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var erasePlate: UIView!
    @IBOutlet private weak var emptyRoot: UIView!
    @IBOutlet private weak var errorRoot: UIView!

    private let store: AskStore
    private let contactURL = URL(string: "https://tabulator-read.pro/contact-us")!

    init(store: AskStore) {
        self.store = store
        super.init(nibName: "Settings", bundle: .main)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("Settings loads from Settings.xib")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Kit.bg
        titleLabel.text = "Card settings"
        titleLabel.textColor = Kit.ink
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = TypeScale.font(.display, compatibleWith: traitCollection)
        statusLabel.textColor = Kit.ink
        statusLabel.numberOfLines = 4
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
        rerunButton.kind = .quiet
        contactButton.kind = .quiet
        contactButton.setTitle("Contact\nSupport", for: .normal)
        contactButton.accessibilityLabel = "Contact support"
        retryButton.kind = .quiet
        retryButton.setTitle("Retry", for: .normal)
        resetButton.kind = .destructive
        Kit.hairline(erasePlate, radius: Radius.card)
        styleLabels(in: erasePlate)
        Kit.hairline(emptyRoot, radius: Radius.card)
        Kit.hairline(errorRoot, radius: Radius.card)
        styleLabels(in: emptyRoot)
        styleLabels(in: errorRoot)
        var closeConfig = UIButton.Configuration.plain()
        closeConfig.title = "Close"
        closeConfig.image = UIImage(systemName: "xmark")
        closeConfig.imagePadding = Space.x2
        closeConfig.baseForegroundColor = Kit.ink
        closeConfig.background.backgroundColor = Kit.surface
        closeConfig.background.cornerRadius = Radius.chip
        closeConfig.background.strokeColor = Kit.muted
        closeConfig.background.strokeWidth = Elevation.hairline
        closeConfig.contentInsets = NSDirectionalEdgeInsets(
            top: Space.x2, leading: Space.x3, bottom: Space.x2, trailing: Space.x3
        )
        closeButton.configuration = closeConfig
        closeButton.accessibilityLabel = "Close"
        render()
        track()
    }

    private func styleLabels(in root: UIView) {
        for case let label as UILabel in root.subviews {
            label.textColor = label === root.subviews.first ? Kit.ink : Kit.muted
            label.font = TypeScale.font(label === root.subviews.first ? .headline : .body, compatibleWith: traitCollection)
            label.adjustsFontForContentSizeCategory = true
        }
    }

    private func track() {
        withObservationTracking {
            _ = store.document.rows.count
            _ = store.document.decisions.count
            _ = store.recoveredFromCorruptStore
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.render()
                self?.track()
            }
        }
    }

    private func render() {
        let card = store.document
        let corrupt = store.recoveredFromCorruptStore
        let vacant = card.rows.isEmpty && card.decisions.isEmpty
        errorRoot.isHidden = !corrupt
        emptyRoot.isHidden = corrupt || !vacant
        let rows = CountFormat.string(card.rows.count)
        let verdicts = CountFormat.string(card.decisions.count)
        statusLabel.text = "Seeded draw. Rows " + rows + ". Verdicts " + verdicts + "."
    }

    @IBAction func closeTapped() {
        dismiss(animated: true)
    }

    @IBAction func rerunTapped() {
        store.setOnboardingComplete(false)
        dismiss(animated: true)
    }

    @IBAction func contactTapped() {
        UIApplication.shared.open(contactURL)
    }

    @IBAction func retryTapped() {
        store.acknowledgeStoreError()
        render()
    }

    @IBAction func resetTapped() {
        let alert = UIAlertController(
            title: "Erase card",
            message: "Rows and verdicts will be erased.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Erase card", style: .destructive) { [weak self] _ in
            self?.store.resetAllData()
            self?.render()
        })
        present(alert, animated: true)
    }
}
