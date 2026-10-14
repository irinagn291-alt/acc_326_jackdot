import UIKit

/// Read surface for the review key. The punch card stays underneath.
/// Read files one punched row. Fewer than two punched rows writes Spar.
final class ReadViewController: UIViewController {
    private let store: AskStore
    private var busy = false

    private let closeButton = UIButton(type: .system)
    private let word = UILabel()
    private let line = UILabel()
    private let strip = UIView()
    private let stripLabel = UILabel()
    private let plate = UIView()
    private let art = UIImageView()
    private let leadName = UILabel()
    private let restNames = UILabel()
    private let verb = PressButton(type: .system)
    private let emptyRoot = UIView()
    private let errorRoot = UIView()

    init(store: AskStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("Read is built in code")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Kit.bg
        configureChrome()
        installFullPage(
            emptyRoot,
            title: "Card is blank",
            line: "Type two names.",
            artName: "tab_EmptyHome",
            action: "Add a row",
            selector: #selector(dismissTapped)
        )
        installFullPage(
            errorRoot,
            title: "Card failed",
            line: "Stored card could not be read.",
            artName: "tab_EmptyHome",
            action: "Retry",
            selector: #selector(retryTapped)
        )
        applyFonts()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.applyFonts()
        }
        render()
        track()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let reduced = UIAccessibility.isReduceMotionEnabled
        view.alpha = 0
        if !reduced {
            view.transform = CGAffineTransform(scaleX: Motion.sheetScale, y: Motion.sheetScale)
        }
        UIView.animate(withDuration: Motion.sheetDuration, delay: 0, options: [.curveEaseOut]) {
            self.view.alpha = 1
            self.view.transform = .identity
        }
    }

    private func configureChrome() {
        var config = UIButton.Configuration.plain()
        config.title = "Close"
        config.image = UIImage(systemName: "xmark")
        config.imagePadding = Space.x2
        config.baseForegroundColor = Kit.ink
        config.background.backgroundColor = Kit.surface
        config.background.cornerRadius = Radius.chip
        config.background.strokeColor = Kit.muted
        config.background.strokeWidth = Elevation.hairline
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Space.x2, leading: Space.x3, bottom: Space.x2, trailing: Space.x3
        )
        closeButton.configuration = config
        closeButton.accessibilityLabel = "Close"
        closeButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        word.textColor = Kit.ink
        word.numberOfLines = 2
        word.lineBreakMode = .byTruncatingTail
        word.adjustsFontForContentSizeCategory = true

        line.textColor = Kit.muted
        line.numberOfLines = 3
        line.adjustsFontForContentSizeCategory = true

        Kit.hairline(strip, radius: Radius.chip)
        stripLabel.textColor = Kit.ink
        stripLabel.numberOfLines = 2
        stripLabel.adjustsFontForContentSizeCategory = true

        Kit.hairline(plate, radius: Radius.card)
        art.image = UIImage(named: "tab_TwistHero")
        art.contentMode = .scaleAspectFit
        art.backgroundColor = .clear
        art.isAccessibilityElement = false

        leadName.textColor = Kit.ink
        leadName.numberOfLines = 2
        leadName.lineBreakMode = .byTruncatingTail
        leadName.adjustsFontForContentSizeCategory = true
        leadName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        restNames.textColor = Kit.muted
        restNames.numberOfLines = 4
        restNames.lineBreakMode = .byTruncatingTail
        restNames.adjustsFontForContentSizeCategory = true

        verb.kind = .read
        verb.addTarget(self, action: #selector(readTapped), for: .touchUpInside)
        verb.accessibilityLabel = "Read"

        let names = UIStackView(arrangedSubviews: [leadName, restNames])
        names.axis = .vertical
        names.spacing = Space.x2
        names.alignment = .fill

        let hero = UIStackView(arrangedSubviews: [art, names])
        hero.axis = .horizontal
        hero.alignment = .top
        hero.spacing = Space.x3

        let plateStack = UIStackView(arrangedSubviews: [hero])
        plateStack.axis = .vertical
        plateStack.translatesAutoresizingMaskIntoConstraints = false
        plate.addSubview(plateStack)

        let chrome = [closeButton, word, line, strip, plate, verb]
        chrome.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        strip.addSubview(stripLabel)
        stripLabel.translatesAutoresizingMaskIntoConstraints = false

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: Space.x2),
            closeButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Space.hit),
            word.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Space.x4),
            word.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -Space.x2),
            word.topAnchor.constraint(equalTo: closeButton.topAnchor),
            line.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            line.topAnchor.constraint(equalTo: word.bottomAnchor, constant: Space.x2),
            strip.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            strip.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            strip.topAnchor.constraint(equalTo: line.bottomAnchor, constant: Space.x4),
            stripLabel.leadingAnchor.constraint(equalTo: strip.leadingAnchor, constant: Space.x3),
            stripLabel.trailingAnchor.constraint(equalTo: strip.trailingAnchor, constant: -Space.x3),
            stripLabel.topAnchor.constraint(equalTo: strip.topAnchor, constant: Space.x3),
            stripLabel.bottomAnchor.constraint(equalTo: strip.bottomAnchor, constant: -Space.x3),
            plate.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            plate.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            plate.topAnchor.constraint(equalTo: strip.bottomAnchor, constant: Space.x4),
            verb.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            verb.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            verb.topAnchor.constraint(equalTo: plate.bottomAnchor, constant: Space.x4),
            verb.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Space.x4),
            verb.heightAnchor.constraint(equalToConstant: Space.x12),
            art.widthAnchor.constraint(equalToConstant: Space.x12 * 3),
            art.heightAnchor.constraint(equalToConstant: Space.x12 * 3),
            plateStack.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: Space.x3),
            plateStack.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -Space.x3),
            plateStack.topAnchor.constraint(equalTo: plate.topAnchor, constant: Space.x4),
            plateStack.bottomAnchor.constraint(lessThanOrEqualTo: plate.bottomAnchor, constant: -Space.x4),
        ])
    }

    private func installFullPage(
        _ root: UIView,
        title: String,
        line: String,
        artName: String,
        action: String,
        selector: Selector
    ) {
        root.translatesAutoresizingMaskIntoConstraints = false
        root.backgroundColor = Kit.bg
        root.isHidden = true
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = Kit.ink
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = TypeScale.font(.display, compatibleWith: traitCollection)
        let lineLabel = UILabel()
        lineLabel.text = line
        lineLabel.textColor = Kit.muted
        lineLabel.numberOfLines = 3
        lineLabel.adjustsFontForContentSizeCategory = true
        lineLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
        let image = UIImageView(image: UIImage(named: artName))
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .clear
        image.isAccessibilityElement = false
        let button = PressButton(type: .system)
        button.kind = .read
        button.setTitle(action, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.accessibilityLabel = action
        [image, titleLabel, lineLabel, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview($0)
        }
        view.addSubview(root)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            root.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Space.x2),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Space.x4),
            image.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            image.topAnchor.constraint(equalTo: root.topAnchor, constant: Space.x4),
            image.heightAnchor.constraint(equalToConstant: Space.x12 * 4),
            titleLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: Space.x4),
            lineLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            lineLabel.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            lineLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Space.x2),
            button.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Space.x4),
            button.heightAnchor.constraint(equalToConstant: Space.x12),
        ])
    }

    private func applyFonts() {
        word.font = TypeScale.font(.display, compatibleWith: traitCollection)
        line.font = TypeScale.font(.body, compatibleWith: traitCollection)
        stripLabel.font = TypeScale.font(.caption, compatibleWith: traitCollection)
        leadName.font = TypeScale.font(.title, compatibleWith: traitCollection)
        restNames.font = TypeScale.font(.body, compatibleWith: traitCollection)
        closeButton.titleLabel?.font = TypeScale.font(.headline, compatibleWith: traitCollection)
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
        let blank = card.rows.isEmpty
        errorRoot.isHidden = !corrupt
        emptyRoot.isHidden = corrupt || !blank
        let showCard = !corrupt && !blank
        word.isHidden = !showCard
        line.isHidden = !showCard
        strip.isHidden = !showCard
        plate.isHidden = !showCard
        verb.isHidden = !showCard

        let waiting = card.fold == .read
        if waiting, let name = card.verdicts.last?.rowName, !name.isEmpty {
            word.text = name
        } else if card.rows.isEmpty {
            word.text = "Blank"
        } else {
            switch card.fold {
            case .open: word.text = "Open"
            case .punched: word.text = "Read"
            case .read: word.text = "Read"
            }
        }
        if waiting {
            line.text = "Verdict filed. Peel to read again."
        } else if card.punchedCandidates.count < 2 {
            line.text = "Spar. Punch two rows."
        } else {
            line.text = "Punch rows, then Read."
        }
        let rows = CountFormat.string(card.rows.count)
        let punched = CountFormat.string(card.punchedCandidates.count)
        let verdicts = CountFormat.string(card.decisions.count)
        stripLabel.text = "Rows " + rows + ". Punched " + punched + ". Verdicts " + verdicts + "."
        let names = card.punchedCandidates.map(\.name)
        leadName.text = names.first ?? "Blank"
        if names.count > 1 {
            restNames.text = names.dropFirst().joined(separator: ". ")
        } else {
            restNames.text = "Punch a second row."
        }
        verb.setTitle("Read", for: .normal)
        verb.isEnabled = showCard && !waiting && !busy
        verb.accessibilityLabel = waiting ? "Read waits for Peel" : "Read"
    }

    @objc private func readTapped() {
        guard !busy else { return }
        busy = true
        verb.isEnabled = false
        let result = store.read()
        if case .filed = result {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        busy = false
        render()
    }

    @objc private func retryTapped() {
        store.acknowledgeStoreError()
        render()
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}
