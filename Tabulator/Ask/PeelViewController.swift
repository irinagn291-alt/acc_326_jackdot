import UIKit

/// Peel surface for the review key. Peel drops a filed verdict and keeps the rows.
/// The punch card stays underneath this full-screen sheet.
final class PeelViewController: UIViewController {
    private let store: AskStore
    private var busy = false

    private let closeButton = UIButton(type: .system)
    private let word = UILabel()
    private let line = UILabel()
    private let plate = UIView()
    private let pickName = UILabel()
    private let dayLabel = UILabel()
    private let orderLabel = UILabel()
    private let waitLabel = UILabel()
    private let readButton = PressButton(type: .system)
    private let verb = PressButton(type: .system)
    private var holdingPick = true
    private let emptyRoot = UIView()
    private let errorRoot = UIView()

    init(store: AskStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("Peel is built in code")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Kit.bg
        configureChrome()
        installFullPage(
            emptyRoot,
            title: "No verdict",
            line: "Read the card to file a pick.",
            artName: "tab_EmptyList",
            action: "Read",
            selector: #selector(dismissTapped)
        )
        installFullPage(
            errorRoot,
            title: "Card failed",
            line: "Stored card could not be read.",
            artName: "tab_EmptyList",
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

        Kit.hairline(plate, radius: Radius.card)

        pickName.textColor = Kit.ink
        pickName.numberOfLines = 2
        pickName.lineBreakMode = .byTruncatingTail
        pickName.adjustsFontForContentSizeCategory = true

        dayLabel.textColor = Kit.muted
        dayLabel.numberOfLines = 1
        dayLabel.adjustsFontForContentSizeCategory = true

        orderLabel.textColor = Kit.ink
        orderLabel.numberOfLines = 2
        orderLabel.adjustsFontForContentSizeCategory = true

        waitLabel.textColor = Kit.muted
        waitLabel.numberOfLines = 3
        waitLabel.adjustsFontForContentSizeCategory = true
        waitLabel.text = "Read waits until Peel clears this pick."

        readButton.kind = .quiet
        readButton.setTitle("Read", for: .normal)
        readButton.accessibilityLabel = "Read waits for Peel"
        readButton.addTarget(self, action: #selector(readTapped), for: .touchUpInside)

        verb.kind = .read
        verb.setTitle("Peel", for: .normal)
        verb.accessibilityLabel = "Peel"
        verb.addTarget(self, action: #selector(verbTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [pickName, orderLabel, dayLabel, waitLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Space.x3
        stack.translatesAutoresizingMaskIntoConstraints = false
        plate.addSubview(stack)

        [closeButton, word, line, plate, readButton, verb].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

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
            plate.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            plate.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            plate.topAnchor.constraint(equalTo: line.bottomAnchor, constant: Space.x4),
            readButton.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            readButton.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            readButton.topAnchor.constraint(equalTo: plate.bottomAnchor, constant: Space.x4),
            readButton.heightAnchor.constraint(equalToConstant: Space.x12),
            verb.leadingAnchor.constraint(equalTo: word.leadingAnchor),
            verb.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            verb.topAnchor.constraint(equalTo: readButton.bottomAnchor, constant: Space.x3),
            verb.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Space.x4),
            verb.heightAnchor.constraint(equalToConstant: Space.x12),
            stack.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: Space.x4),
            stack.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -Space.x4),
            stack.topAnchor.constraint(equalTo: plate.topAnchor, constant: Space.x4),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: plate.bottomAnchor, constant: -Space.x4),
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
        pickName.font = TypeScale.font(.display, compatibleWith: traitCollection)
        dayLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
        orderLabel.font = TypeScale.font(.headline, compatibleWith: traitCollection)
        waitLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
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
        let vacant = card.decisions.isEmpty
        errorRoot.isHidden = !corrupt
        emptyRoot.isHidden = corrupt || !vacant
        let showCard = !corrupt && !vacant
        word.isHidden = !showCard
        line.isHidden = !showCard
        plate.isHidden = !showCard
        readButton.isHidden = !showCard
        verb.isHidden = !showCard

        let newest = card.decisions.last
        let filedName = newest?.rowName ?? "Blank"
        word.text = "Pick"
        pickName.text = filedName
        if holdingPick {
            line.text = filedName + " is the pick. Peel puts this pick back."
            waitLabel.text = "Read waits until Peel clears this pick."
            verb.setTitle("Peel", for: .normal)
            verb.accessibilityLabel = "Peel"
            verb.kind = .read
            verb.isEnabled = showCard && !busy
            readButton.isEnabled = false
            readButton.accessibilityLabel = "Read waits for Peel"
        } else {
            line.text = "Pick cleared. Read files the next pick."
            waitLabel.text = "Peel cleared this pick. Read is ready."
            verb.setTitle("Peel", for: .normal)
            verb.accessibilityLabel = "Peel"
            verb.kind = .quiet
            verb.isEnabled = false
            readButton.isEnabled = showCard && !busy
            readButton.kind = .read
            readButton.accessibilityLabel = "Read"
        }
        if let newest {
            dayLabel.text = DayFormat.string(daykey: newest.daykey)
            orderLabel.text = "Verdict " + CountFormat.string(card.decisions.count)
        } else {
            dayLabel.text = ""
            orderLabel.text = ""
        }
    }

    @objc private func verbTapped() {
        guard !busy, holdingPick else { return }
        busy = true
        verb.isEnabled = false
        if store.document.fold == .read {
            store.peel()
        }
        holdingPick = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        busy = false
        render()
    }

    @objc private func readTapped() {
        guard !busy, !holdingPick else { return }
        busy = true
        readButton.isEnabled = false
        let result = store.read()
        if case .filed = result {
            holdingPick = true
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
