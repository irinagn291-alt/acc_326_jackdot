import XCTest
@testable import Tabulator

final class TabulatorTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: TabulatorApp.self), "TabulatorApp")
    }

    func test_reviewLaunchParsesScreenArgument() {
        XCTAssertEqual(
            ReviewLaunch.screen(from: ["Tabulator", "-ReviewScreen", "today"]),
            "today"
        )
        XCTAssertEqual(
            ReviewLaunch.screen(from: ["Tabulator", "-ReviewScreen", "log"]),
            "log"
        )
        XCTAssertEqual(
            ReviewLaunch.screen(from: ["Tabulator", "-ReviewScreen", "goals"]),
            "goals"
        )
        XCTAssertNil(ReviewLaunch.screen(from: ["Tabulator"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["Tabulator", "-ReviewScreen"]))
    }
}

final class AskDomainTests: XCTestCase {
    private let day = Date(timeIntervalSince1970: 1_700_000_000)

    func test_familyInvariant_seededUniformNeedsTwoPunchedRows() {
        var card = AskDocument.empty
        card.drawSeed = 5
        card.rows = [
            Row.named("Mara Quill", punched: true),
            Row.named("   ", punched: true),
            Row.named("Owen Pike", punched: true),
            Row.named("Lina Voss", punched: false),
        ]
        let candidates = card.punchedCandidates
        XCTAssertEqual(candidates.map(\.name), ["Mara Quill", "Owen Pike"])
        XCTAssertGreaterThanOrEqual(candidates.count, 2)
        let index = SeededDraw.index(seed: card.drawSeed, count: candidates.count)
        XCTAssertEqual(index, 5 % 2)
        guard case .filed(let verdict) = card.read(now: day) else {
            return XCTFail("Expected a filed verdict")
        }
        XCTAssertEqual(verdict.rowName, candidates[index].name)
        XCTAssertEqual(card.drawSeed, SeededDraw.advance(5))
        XCTAssertEqual(card.fold, .read)
    }

    func test_moduloDrawAdvancesOnlyWhenVerdictFiles() {
        var card = AskDocument.empty
        card.drawSeed = 7
        card.rows = [
            Row.named("Mara Quill", punched: true),
            Row.named("Owen Pike", punched: true),
            Row.named("Lina Voss", punched: true),
        ]
        let before = card.drawSeed
        let expected = card.rows[SeededDraw.index(seed: before, count: 3)].name
        guard case .filed(let verdict) = card.read(now: day) else {
            return XCTFail("Expected a filed verdict")
        }
        XCTAssertEqual(verdict.rowName, expected)
        XCTAssertEqual(card.drawSeed, SeededDraw.advance(before))
        XCTAssertEqual(
            SeededDraw.advance(before),
            before &* SeededDraw.multiplier &+ 1,
            "Seeded RNG advances only when a verdict files"
        )
        let stalled = card.drawSeed
        XCTAssertEqual(card.read(now: day), .refusedUntilPeel)
        XCTAssertEqual(card.drawSeed, stalled)
        XCTAssertEqual(card.verdicts.count, 1)
    }

    func test_tieModeIsEvenReadFromOpen() {
        var card = AskDocument.empty
        card.drawSeed = 0
        card.applyTie(left: "Mara Quill", right: "Owen Pike")
        XCTAssertEqual(card.fold, .open)
        XCTAssertEqual(card.rows.count, 2)
        XCTAssertTrue(card.rows.allSatisfy(\.hole.punched))
        XCTAssertTrue(card.readEnabled)
        guard case .filed(let first) = card.read(now: day) else {
            return XCTFail("Tie read should file")
        }
        XCTAssertEqual(first.rowName, "Mara Quill")
        var other = AskDocument.empty
        other.drawSeed = 1
        other.applyTie(left: "Mara Quill", right: "Owen Pike")
        guard case .filed(let second) = other.read(now: day) else {
            return XCTFail("Odd seed should file")
        }
        XCTAssertEqual(second.rowName, "Owen Pike")
    }

    func test_sparKeepsFoldAndSeed() {
        var card = AskDocument.empty
        card.drawSeed = 9
        card.addRow(name: "Mara Quill")
        _ = card.punch(rowID: card.rows[0].id, now: day)
        XCTAssertEqual(card.fold, .punched)
        guard case .spar(let mark) = card.read(now: day) else {
            return XCTFail("Expected spar")
        }
        XCTAssertEqual(mark.punchedCount, 1)
        XCTAssertEqual(card.fold, .punched)
        XCTAssertEqual(card.drawSeed, 9)
        XCTAssertTrue(card.verdicts.isEmpty)
        XCTAssertTrue(card.decisions.isEmpty)
    }

    func test_emptyPunchWritesBlank() {
        var card = AskDocument.empty
        let mark = card.punch(rowID: UUID(), now: day)
        XCTAssertNil(mark)
        XCTAssertEqual(card.blanks.count, 1)
        XCTAssertTrue(card.rows.isEmpty)
        XCTAssertEqual(card.fold, .open)
    }

    func test_peelGateRestoresPunchedAndKeepsHistory() {
        var card = AskDocument.empty
        card.drawSeed = 2
        card.applyTie(left: "Mara Quill", right: "Owen Pike")
        guard case .filed(let verdict) = card.read(now: day) else {
            return XCTFail("Expected verdict")
        }
        let filedName = verdict.rowName
        XCTAssertEqual(card.read(now: day), .refusedUntilPeel)
        XCTAssertEqual(card.decisions.count, 1)
        let peel = card.peel(now: day)
        XCTAssertEqual(peel?.verdictID, verdict.id)
        XCTAssertEqual(card.fold, .punched)
        XCTAssertEqual(card.rows.count, 2)
        XCTAssertEqual(card.decisions.map(\.rowName), [filedName])
        XCTAssertEqual(card.verdicts.map(\.rowName), [filedName])
        guard case .filed = card.read(now: day) else {
            return XCTFail("Read after peel should file")
        }
        XCTAssertEqual(card.decisions.count, 2)
    }

    func test_punchDoesNotRewriteFiledVerdict() {
        var card = AskDocument.empty
        card.applyTie(left: "Mara Quill", right: "Owen Pike")
        guard case .filed(let verdict) = card.read(now: day) else {
            return XCTFail("Expected verdict")
        }
        _ = card.punch(rowID: card.rows[0].id, now: day)
        XCTAssertEqual(card.verdicts, [verdict])
        XCTAssertEqual(card.decisions.count, 1)
        XCTAssertEqual(card.fold, .read)
    }

    func test_foldPatternOpenPunchReadPeel() {
        var card = AskDocument.empty
        XCTAssertEqual(card.fold, .open)
        card.addRow(name: "Mara Quill")
        card.addRow(name: "Owen Pike")
        _ = card.punch(rowID: card.rows[0].id, now: day)
        XCTAssertEqual(card.fold, .punched)
        _ = card.punch(rowID: card.rows[1].id, now: day)
        XCTAssertEqual(card.punchMarks.count, 2)
        _ = card.read(now: day)
        XCTAssertEqual(card.fold, .read)
        XCTAssertEqual(card.decisions.count, card.verdicts.count)
        _ = card.peel(now: day)
        XCTAssertEqual(card.fold, .punched)
        XCTAssertFalse(card.rows.isEmpty)
    }

    func test_daykeyUsesStartOfDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let afternoon = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 18)))
        XCTAssertEqual(Daykey.make(afternoon, calendar: calendar), 20260927)
    }

    func test_unknownSchemaDoesNotDecode() throws {
        let json = try XCTUnwrap(#"{"schemaVersion":9}"#.data(using: .utf8))
        XCTAssertThrowsError(try JSONDecoder().decode(AskDocument.self, from: json))
    }
}

@MainActor
final class AskStoreTests: XCTestCase {
    private func suite() throws -> UserDefaults {
        let name = "tab.test.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    func test_roundTripReload() throws {
        let defaults = try suite()
        let store = AskStore(defaults: defaults, seedDemo: false)
        store.addRow(name: "Mara Quill")
        store.addRow(name: "Owen Pike")
        store.punch(rowID: store.document.rows[0].id)
        store.punch(rowID: store.document.rows[1].id)
        _ = store.read()
        store.peel()
        store.flush()

        let reloaded = AskStore(defaults: defaults, seedDemo: false)
        XCTAssertFalse(reloaded.recoveredFromCorruptStore)
        XCTAssertEqual(reloaded.document.rows.map(\.name), ["Mara Quill", "Owen Pike"])
        XCTAssertEqual(reloaded.document.decisions.count, 1)
        XCTAssertEqual(reloaded.document.fold, .punched)
        XCTAssertEqual(reloaded.document.schemaVersion, 1)
    }

    func test_corruptPayloadBecomesEmptyAsk() throws {
        let defaults = try suite()
        defaults.set(Data("not-json".utf8), forKey: AskStore.storageKey)
        let store = AskStore(defaults: defaults, seedDemo: false)
        XCTAssertTrue(store.recoveredFromCorruptStore)
        XCTAssertEqual(store.document, .empty)
        XCTAssertTrue(store.document.rows.isEmpty)
        store.acknowledgeStoreError()
        XCTAssertFalse(store.recoveredFromCorruptStore)
        let kept = defaults.data(forKey: AskStore.storageKey)
        XCTAssertNotNil(kept)
        XCTAssertNoThrow(try JSONDecoder().decode(AskDocument.self, from: kept ?? Data()))
        let reloaded = AskStore(defaults: defaults, seedDemo: false)
        XCTAssertFalse(reloaded.recoveredFromCorruptStore)
        XCTAssertTrue(reloaded.document.rows.isEmpty)
    }

    func test_resetAllDataClearsKey() throws {
        let defaults = try suite()
        let store = AskStore(defaults: defaults, seedDemo: false)
        store.addRow(name: "Mara Quill")
        store.flush()
        XCTAssertNotNil(defaults.data(forKey: AskStore.storageKey))
        store.resetAllData()
        XCTAssertNil(defaults.data(forKey: AskStore.storageKey))
        XCTAssertTrue(store.document.rows.isEmpty)
        let reloaded = AskStore(defaults: defaults, seedDemo: false)
        XCTAssertFalse(reloaded.recoveredFromCorruptStore)
        XCTAssertTrue(reloaded.document.rows.isEmpty)
    }

    func test_demoCardEnablesReadAndFilesHistory() {
        let card = AskStore.demoCard()
        XCTAssertTrue(card.onboardingComplete)
        XCTAssertEqual(card.rows.map(\.name), ["Mara Quill", "Owen Pike", "Lina Voss"])
        XCTAssertTrue(card.rows.allSatisfy(\.hole.punched))
        XCTAssertTrue(card.readEnabled)
        XCTAssertGreaterThanOrEqual(card.decisions.count, 3)
        XCTAssertEqual(card.fold, .punched)
    }
}
