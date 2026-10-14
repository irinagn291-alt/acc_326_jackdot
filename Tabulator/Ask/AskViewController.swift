import UIKit

/// Ask is the punch card that never leaves. Punch and Read fuse here.
/// History and Settings arrive as sheets. The plate is the only custom draw.
final class AskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet private weak var plateView: AskPlateView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var sparLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var peelButton: PressButton!
    @IBOutlet private weak var readButton: PressButton!
    @IBOutlet private weak var historyButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var tieButton: UIButton!
    @IBOutlet private weak var emptyRoot: UIView!
    @IBOutlet private weak var emptyTitle: UILabel!
    @IBOutlet private weak var emptyLine: UILabel!
    @IBOutlet private weak var emptyAddButton: PressButton!
    @IBOutlet private weak var errorRoot: UIView!
    @IBOutlet private weak var errorTitle: UILabel!
    @IBOutlet private weak var errorLine: UILabel!
    @IBOutlet private weak var errorRetry: PressButton!

    private let store: AskStore
    private var launchKey: String?
    private var didLaunch = false
    private var lastSpar = false
    private var reading = false

    init(store: AskStore, launchKey: String?) {
        self.store = store
        self.launchKey = launchKey
        super.init(nibName: "Ask", bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("Ask loads from Ask.xib")
    }

    func consumeLaunch(_ key: String?) {
        guard launchKey == nil, let key else { return }
        launchKey = key
        if isViewLoaded, view.window != nil {
            presentLaunchIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Kit.bg
        Kit.hairline(plateView, radius: Radius.card)
        plateView.backgroundColor = Kit.surface
        statusLabel.textColor = Kit.ink
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.numberOfLines = 2
        hintLabel.textColor = Kit.muted
        hintLabel.numberOfLines = 3
        hintLabel.adjustsFontForContentSizeCategory = true
        sparLabel.textColor = Kit.ink
        sparLabel.numberOfLines = 2
        sparLabel.adjustsFontForContentSizeCategory = true
        nameField.textColor = Kit.ink
        nameField.backgroundColor = Kit.bg
        nameField.layer.cornerRadius = Radius.chip
        nameField.layer.borderWidth = Elevation.hairline
        nameField.layer.borderColor = Kit.muted.cgColor
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Space.x3, height: Space.hit))
        nameField.leftViewMode = .always
        nameField.delegate = self
        nameField.returnKeyType = .done
        nameField.autocorrectionType = .no
        nameField.placeholder = "Type a name"
        nameField.accessibilityLabel = "Row name"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Space.x12 + Space.x6
        tableView.register(UINib(nibName: "RowCell", bundle: .main), forCellReuseIdentifier: RowCell.reuseID)
        readButton.kind = .read
        peelButton.kind = .peel
        emptyAddButton.kind = .read
        errorRetry.kind = .read
        styleChrome(historyButton)
        styleChrome(settingsButton)
        styleChrome(tieButton)
        emptyRoot.backgroundColor = Kit.bg
        errorRoot.backgroundColor = Kit.bg
        emptyTitle.textColor = Kit.ink
        emptyLine.textColor = Kit.muted
        errorTitle.textColor = Kit.ink
        errorLine.textColor = Kit.muted
        emptyTitle.numberOfLines = 2
        emptyTitle.adjustsFontForContentSizeCategory = true
        emptyLine.numberOfLines = 3
        emptyLine.adjustsFontForContentSizeCategory = true
        errorTitle.numberOfLines = 2
        errorTitle.adjustsFontForContentSizeCategory = true
        errorLine.numberOfLines = 4
        errorLine.adjustsFontForContentSizeCategory = true
        emptyTitle.text = "Card is blank"
        emptyLine.text = "Type two names."
        errorTitle.text = "Card failed"
        errorLine.text = "Stored card could not be read."
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        applyFonts()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.applyFonts()
            self.plateView.layer.borderColor = Kit.muted.cgColor
            self.nameField.layer.borderColor = Kit.muted.cgColor
        }
        render()
        track()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentLaunchIfNeeded()
    }

    private func applyFonts() {
        statusLabel.font = TypeScale.font(.display, compatibleWith: traitCollection)
        hintLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
        sparLabel.font = TypeScale.font(.caption, compatibleWith: traitCollection)
        nameField.font = TypeScale.font(.body, compatibleWith: traitCollection)
        emptyTitle.font = TypeScale.font(.display, compatibleWith: traitCollection)
        emptyLine.font = TypeScale.font(.body, compatibleWith: traitCollection)
        errorTitle.font = TypeScale.font(.display, compatibleWith: traitCollection)
        errorLine.font = TypeScale.font(.body, compatibleWith: traitCollection)
        historyButton.titleLabel?.font = TypeScale.font(.caption, compatibleWith: traitCollection)
        settingsButton.titleLabel?.font = TypeScale.font(.caption, compatibleWith: traitCollection)
        tieButton.titleLabel?.font = TypeScale.font(.caption, compatibleWith: traitCollection)
    }

    private func styleChrome(_ button: UIButton) {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = Kit.ink
        config.background.backgroundColor = Kit.bg
        config.background.cornerRadius = Radius.chip
        config.background.strokeColor = Kit.muted
        config.background.strokeWidth = Elevation.hairline
        config.contentInsets = NSDirectionalEdgeInsets(top: Space.x2, leading: Space.x3, bottom: Space.x2, trailing: Space.x3)
        config.title = button.currentTitle
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak button] incoming in
            var outgoing = incoming
            outgoing.font = TypeScale.font(.caption, compatibleWith: button?.traitCollection ?? .current)
            return outgoing
        }
        button.configuration = config
    }

    private func track() {
        withObservationTracking {
            _ = store.document
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
        errorRoot.isHidden = !corrupt
        let showEmpty = !corrupt && card.rows.isEmpty
        emptyRoot.isHidden = !showEmpty
        plateView.isHidden = corrupt || showEmpty
        blurView.isHidden = corrupt || showEmpty

        let waiting = card.fold == .read
        if waiting, let name = card.verdicts.last?.rowName {
            statusLabel.text = name
        } else if card.rows.isEmpty {
            statusLabel.text = "Blank"
        } else {
            switch card.fold {
            case .open: statusLabel.text = "Open"
            case .punched: statusLabel.text = "Punched"
            case .read: statusLabel.text = "Read"
            }
        }
        hintLabel.text = waiting
            ? "Verdict filed. Peel to read again."
            : "Punch rows, then Read."
        if lastSpar {
            sparLabel.text = "Spar. Punch two rows."
        } else {
            sparLabel.text = "Punched " + CountFormat.string(card.punchedCandidates.count)
        }
        let readTitle = lastSpar ? "Spar" : "Read"
        readButton.setSpar(lastSpar, title: readTitle)
        readButton.kind = waiting ? .quiet : .read
        peelButton.kind = waiting ? .read : .peel
        readButton.isEnabled = !waiting && !reading
        peelButton.isEnabled = waiting
        peelButton.accessibilityLabel = "Peel"
        readButton.accessibilityLabel = waiting ? "Read waits for Peel" : "Read"
        tableView.reloadData()
    }

    private func presentLaunchIfNeeded() {
        guard !didLaunch, let key = launchKey else { return }
        didLaunch = true
        switch key {
        case "log":
            present(HistoryViewController(store: store), animated: true)
        case "goals":
            present(SettingsViewController(store: store), animated: true)
        case "tie":
            present(TieViewController(store: store), animated: true)
        case "read":
            present(ReadViewController(store: store), animated: true)
        case "peel":
            present(PeelViewController(store: store), animated: true)
        default:
            break
        }
    }

    @IBAction func historyTapped() {
        nameField.resignFirstResponder()
        present(HistoryViewController(store: store), animated: true)
    }

    @IBAction func settingsTapped() {
        nameField.resignFirstResponder()
        present(SettingsViewController(store: store), animated: true)
    }

    @IBAction func tieTapped() {
        nameField.resignFirstResponder()
        present(TieViewController(store: store), animated: true)
    }

    @IBAction func readTapped() {
        guard !reading else { return }
        reading = true
        readButton.isEnabled = false
        let result = store.read()
        reading = false
        switch result {
        case .filed:
            lastSpar = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .spar:
            lastSpar = true
        case .refusedUntilPeel:
            lastSpar = false
        }
        render()
    }

    @IBAction func peelTapped() {
        store.peel()
        lastSpar = false
        render()
    }

    @IBAction func emptyAddTapped() {
        let alert = UIAlertController(title: "Add a row", message: "Type a name.", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Type a name"
            field.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add a row", style: .default) { [weak self] _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            self?.store.addRow(name: name)
            self?.lastSpar = false
            self?.render()
        })
        present(alert, animated: true)
    }

    @IBAction func errorRetryTapped() {
        store.acknowledgeStoreError()
        render()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.document.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RowCell.reuseID, for: indexPath) as! RowCell
        let row = store.document.rows[indexPath.row]
        cell.bind(row: row)
        cell.onPunch = { [weak self] in
            self?.store.punch(rowID: row.id)
            self?.lastSpar = false
        }
        return cell
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitName()
        return true
    }

    private func commitName() {
        let raw = nameField.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addRow(name: trimmed)
        nameField.text = ""
        lastSpar = false
        render()
    }
}
