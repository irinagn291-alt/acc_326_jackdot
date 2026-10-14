import UIKit

/// Tie mode screen. Two rows already punched, even chance, Read legal from Open.
final class TieViewController: SheetMotionController, UITextFieldDelegate {
    private let store: AskStore
    private let leftField = UITextField()
    private let rightField = UITextField()
    private let fileButton = PressButton(type: .system)
    private let hero = UILabel()

    init(store: AskStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("Tie is built in code")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Kit.bg
        hero.text = "Tie"
        hero.textColor = Kit.ink
        hero.numberOfLines = 2
        hero.font = TypeScale.font(.display, compatibleWith: traitCollection)
        hero.adjustsFontForContentSizeCategory = true
        let line = UILabel()
        line.text = "Two names, even chance. Read files one of them."
        line.textColor = Kit.muted
        line.numberOfLines = 3
        line.font = TypeScale.font(.body, compatibleWith: traitCollection)
        line.adjustsFontForContentSizeCategory = true
        configure(leftField, placeholder: "Left name")
        configure(rightField, placeholder: "Right name")
        fileButton.kind = .read
        fileButton.setTitle("File the tie", for: .normal)
        fileButton.addTarget(self, action: #selector(fileTapped), for: .touchUpInside)
        let close = UIButton(type: .system)
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
        close.configuration = closeConfig
        close.accessibilityLabel = "Close"
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        let art = UIImageView(image: UIImage(named: "tab_TwistHero"))
        art.contentMode = .scaleAspectFit
        art.isAccessibilityElement = false
        art.translatesAutoresizingMaskIntoConstraints = false
        [hero, line, art, leftField, rightField, fileButton, close].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: safe.topAnchor, constant: Space.x2),
            close.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            close.heightAnchor.constraint(equalToConstant: Space.hit),
            hero.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Space.x4),
            hero.trailingAnchor.constraint(equalTo: close.leadingAnchor, constant: -Space.x2),
            hero.topAnchor.constraint(equalTo: safe.topAnchor, constant: Space.x2),
            line.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Space.x4),
            line.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: Space.x2),
            art.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            art.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            art.topAnchor.constraint(equalTo: line.bottomAnchor, constant: Space.x4),
            art.heightAnchor.constraint(equalToConstant: Space.x12 * 3),
            leftField.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            leftField.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            leftField.topAnchor.constraint(equalTo: art.bottomAnchor, constant: Space.x4),
            leftField.heightAnchor.constraint(equalToConstant: Space.hit),
            rightField.leadingAnchor.constraint(equalTo: leftField.leadingAnchor),
            rightField.trailingAnchor.constraint(equalTo: leftField.trailingAnchor),
            rightField.topAnchor.constraint(equalTo: leftField.bottomAnchor, constant: Space.x3),
            rightField.heightAnchor.constraint(equalToConstant: Space.hit),
            fileButton.leadingAnchor.constraint(equalTo: leftField.leadingAnchor),
            fileButton.trailingAnchor.constraint(equalTo: leftField.trailingAnchor),
            fileButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Space.x4),
            fileButton.heightAnchor.constraint(equalToConstant: Space.x12),
        ])
    }

    private func configure(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.textColor = Kit.ink
        field.font = TypeScale.font(.body, compatibleWith: traitCollection)
        field.backgroundColor = Kit.surface
        field.layer.cornerRadius = Radius.chip
        field.layer.borderWidth = Elevation.hairline
        field.layer.borderColor = Kit.muted.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Space.x3, height: Space.hit))
        field.leftViewMode = .always
        field.delegate = self
        field.returnKeyType = .done
        field.autocorrectionType = .no
        field.accessibilityLabel = placeholder
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func fileTapped() {
        let left = (leftField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let right = (rightField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !left.isEmpty, !right.isEmpty else {
            hero.text = "Spar"
            return
        }
        store.applyTie(left: left, right: right)
        dismiss(animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
