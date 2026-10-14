import UIKit

/// History is a sheet of DecisionRecords in Verdict order. The card stays under it.
final class HistoryViewController: SheetMotionController, UITableViewDataSource {
    private let store: AskStore
    private let table = UITableView(frame: .zero, style: .plain)
    private let empty = UIView()
    private let error = UIView()
    private let closeButton = UIButton(type: .system)

    init(store: AskStore) {
        self.store = store
        super.init(nibName: "History", bundle: .main)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("History loads from History.xib")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Kit.bg
        if let host = view.viewWithTag(11) as? UITableView {
            host.removeFromSuperview()
        }
        layoutChrome()
        render()
        track()
    }

    private func layoutChrome() {
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
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.register(DecisionCell.self, forCellReuseIdentifier: DecisionCell.reuseID)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = Space.x12 + Space.x8
        view.addSubview(table)

        installFullPage(empty, title: "No verdicts", line: "Read the card to file a pick.", art: "tab_EmptyList", action: "Read", selector: #selector(closeTapped))
        installFullPage(error, title: "History failed", line: "Stored verdicts could not be read.", art: "tab_EmptyList", action: "Retry", selector: #selector(retryTapped))

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: Space.x2),
            closeButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            closeButton.heightAnchor.constraint(equalToConstant: Space.hit),
            table.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Space.x2),
            table.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Space.x4),
            table.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            table.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            empty.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Space.x2),
            empty.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            error.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            error.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            error.topAnchor.constraint(equalTo: safe.topAnchor),
            error.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
        ])
    }

    private func installFullPage(_ root: UIView, title: String, line: String, art: String, action: String? = nil, selector: Selector? = nil) {
        root.translatesAutoresizingMaskIntoConstraints = false
        root.backgroundColor = Kit.bg
        root.isHidden = true
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = Kit.ink
        titleLabel.numberOfLines = 2
        titleLabel.font = TypeScale.font(.display, compatibleWith: traitCollection)
        titleLabel.adjustsFontForContentSizeCategory = true
        let lineLabel = UILabel()
        lineLabel.text = line
        lineLabel.textColor = Kit.muted
        lineLabel.numberOfLines = 3
        lineLabel.font = TypeScale.font(.body, compatibleWith: traitCollection)
        lineLabel.adjustsFontForContentSizeCategory = true
        let image = UIImageView(image: UIImage(named: art))
        image.contentMode = .scaleAspectFit
        image.isAccessibilityElement = false
        image.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [image, titleLabel, lineLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Space.x3
        stack.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(stack)
        view.addSubview(root)
        var constraints = [
            image.heightAnchor.constraint(equalToConstant: Space.x12 * 2 + Space.x8),
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: Space.x4),
            stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -Space.x4),
            stack.topAnchor.constraint(equalTo: root.topAnchor, constant: Space.x12),
        ]
        if let action {
            let button = PressButton(type: .system)
            button.kind = .read
            button.setTitle(action, for: .normal)
            button.addTarget(self, action: selector ?? #selector(retryTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(button)
            constraints += [
                button.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: Space.x4),
                button.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -Space.x4),
                button.bottomAnchor.constraint(equalTo: root.safeAreaLayoutGuide.bottomAnchor, constant: -Space.x4),
                button.heightAnchor.constraint(equalToConstant: Space.x12),
            ]
        }
        NSLayoutConstraint.activate(constraints)
        view.bringSubviewToFront(closeButton)
    }

    private func track() {
        withObservationTracking {
            _ = store.document.decisions
            _ = store.recoveredFromCorruptStore
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.render()
                self?.track()
            }
        }
    }

    private func render() {
        let corrupt = store.recoveredFromCorruptStore
        let emptyDecisions = store.document.decisions.isEmpty
        error.isHidden = !corrupt
        empty.isHidden = corrupt || !emptyDecisions
        table.isHidden = corrupt || emptyDecisions
        closeButton.isHidden = corrupt
        table.reloadData()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func retryTapped() {
        store.acknowledgeStoreError()
        render()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.document.decisions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DecisionCell.reuseID, for: indexPath) as! DecisionCell
        let record = store.document.decisions[indexPath.row]
        let order = CountFormat.string(indexPath.row + 1)
        cell.bind(name: record.rowName, order: order, day: DayFormat.string(daykey: record.daykey))
        return cell
    }
}

/// One filed verdict card in the history stack.
private final class DecisionCell: UITableViewCell {
    static let reuseID = "DecisionCell"
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let plate = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        Kit.hairline(plate, radius: Radius.card)
        plate.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = Kit.ink
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontForContentSizeCategory = true
        metaLabel.textColor = Kit.muted
        metaLabel.numberOfLines = 2
        metaLabel.adjustsFontForContentSizeCategory = true
        let stack = UIStackView(arrangedSubviews: [nameLabel, metaLabel])
        stack.axis = .vertical
        stack.spacing = Space.x1
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(plate)
        plate.addSubview(stack)
        NSLayoutConstraint.activate([
            plate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            plate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            plate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Space.x2),
            plate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Space.x2),
            stack.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: Space.x4),
            stack.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -Space.x4),
            stack.topAnchor.constraint(equalTo: plate.topAnchor, constant: Space.x4),
            stack.bottomAnchor.constraint(equalTo: plate.bottomAnchor, constant: -Space.x4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("DecisionCell is built in code")
    }

    func bind(name: String, order: String, day: String) {
        nameLabel.font = TypeScale.font(.title, compatibleWith: traitCollection)
        metaLabel.font = TypeScale.font(.caption, compatibleWith: traitCollection)
        nameLabel.text = name
        metaLabel.text = "Verdict " + order + ". " + day
    }
}
