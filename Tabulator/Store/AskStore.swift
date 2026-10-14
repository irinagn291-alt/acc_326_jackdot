import Foundation
import Observation

/// Sole reader and writer of UserDefaults for the Ask. Memory is the source of truth.
/// A save is debounced, then flushed when the scene leaves the active state.
@MainActor
@Observable
final class AskStore {
    static let storageKey = "tab.ask.v1"
    static let demoKey = "tab.demo.v1"
    static let debounceNanoseconds: UInt64 = 400_000_000

    private(set) var document: AskDocument
    /// Set when stored JSON cannot be decoded. The card starts empty instead of crashing.
    private(set) var recoveredFromCorruptStore: Bool

    private let defaults: UserDefaults
    private var saveTask: Task<Void, Never>?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard, seedDemo: Bool = true) {
        self.defaults = defaults
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        self.encoder = encoder
        let loaded = Self.load(defaults: defaults, decoder: decoder)
        document = loaded.document
        recoveredFromCorruptStore = loaded.corrupt
        if seedDemo {
            seedSimulatorIfNeeded()
        }
    }

    func addRow(name: String) {
        document.addRow(name: name)
        scheduleSave()
    }

    func punch(rowID: UUID, now: Date = Date()) {
        document.punch(rowID: rowID, now: now)
        scheduleSave()
    }

    func applyTie(left: String, right: String) {
        document.applyTie(left: left, right: right)
        scheduleSave()
    }

    @discardableResult
    func read(now: Date = Date()) -> AskDocument.ReadResult {
        let result = document.read(now: now)
        scheduleSave()
        return result
    }

    func peel(now: Date = Date()) {
        document.peel(now: now)
        scheduleSave()
    }

    func setOnboardingComplete(_ complete: Bool) {
        document.onboardingComplete = complete
        scheduleSave()
    }

    func acknowledgeStoreError() {
        saveTask?.cancel()
        saveTask = nil
        recoveredFromCorruptStore = false
        writeNow()
    }

    /// Clears tab.ask.v1 immediately. Used by tests and confirmed from Settings.
    func resetAllData() {
        saveTask?.cancel()
        saveTask = nil
        document = .empty
        recoveredFromCorruptStore = false
        defaults.removeObject(forKey: Self.storageKey)
    }

    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.debounceNanoseconds)
            guard let self, !Task.isCancelled else { return }
            self.writeNow()
        }
    }

    /// Force the in-memory card to disk-backed defaults. Call when scenePhase leaves .active.
    func flush() {
        saveTask?.cancel()
        saveTask = nil
        writeNow()
    }

    func seedSimulatorIfNeeded() {
        #if targetEnvironment(simulator)
        guard defaults.bool(forKey: Self.demoKey) == false else { return }
        document = Self.demoCard()
        recoveredFromCorruptStore = false
        defaults.set(true, forKey: Self.demoKey)
        writeNow()
        #endif
    }

    private func writeNow() {
        guard let data = try? encoder.encode(document) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    private static func load(defaults: UserDefaults, decoder: JSONDecoder) -> (document: AskDocument, corrupt: Bool) {
        guard let data = defaults.data(forKey: storageKey) else {
            return (.empty, false)
        }
        do {
            return (try decoder.decode(AskDocument.self, from: data), false)
        } catch {
            return (.empty, true)
        }
    }

    /// Three punched rows, Read legal, several filed decisions, onboarding done.
    static func demoCard(now: Date = Date()) -> AskDocument {
        var card = AskDocument.empty
        card.onboardingComplete = true
        card.rows = [
            Row.named("Mara Quill", punched: true),
            Row.named("Owen Pike", punched: true),
            Row.named("Lina Voss", punched: true),
        ]
        card.fold = .punched
        _ = card.read(now: now)
        _ = card.peel(now: now)
        _ = card.read(now: now)
        _ = card.peel(now: now)
        _ = card.read(now: now)
        _ = card.peel(now: now)
        return card
    }
}
