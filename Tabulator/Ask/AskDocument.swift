import Foundation

/// Root record under tab.ask.v1. The card is this fold over Rows.
/// Punch, Read, and Peel live here so the UI never owns the rules.
struct AskDocument: Codable, Sendable, Equatable {
    static let currentSchema = 1

    var schemaVersion: Int
    var fold: AskFold
    var rows: [Row]
    var punchMarks: [PunchMark]
    var sparMarks: [SparMark]
    var peelMarks: [PeelMark]
    var blanks: [Blank]
    var verdicts: [Verdict]
    var decisions: [DecisionRecord]
    var drawSeed: UInt64
    var onboardingComplete: Bool

    static let empty = AskDocument(
        schemaVersion: currentSchema,
        fold: .open,
        rows: [],
        punchMarks: [],
        sparMarks: [],
        peelMarks: [],
        blanks: [],
        verdicts: [],
        decisions: [],
        drawSeed: 0x5A17,
        onboardingComplete: false
    )

    var punchedCandidates: [Row] {
        rows.filter(\.entersDraw)
    }

    var readEnabled: Bool {
        fold != .read && punchedCandidates.count >= 2
    }

    enum ReadResult: Sendable, Equatable {
        case filed(Verdict)
        case spar(SparMark)
        case refusedUntilPeel
    }

    mutating func addRow(name: String) {
        rows.append(Row.named(name, punched: false))
    }

    /// Toggles a Hole and appends a PunchMark. An empty card writes Blank only.
    @discardableResult
    mutating func punch(rowID: UUID, now: Date = Date()) -> PunchMark? {
        guard !rows.isEmpty else {
            blanks.append(Blank(id: UUID(), daykey: Daykey.make(now)))
            return nil
        }
        guard let index = rows.firstIndex(where: { $0.id == rowID }) else {
            return nil
        }
        rows[index].hole.punched.toggle()
        let mark = PunchMark(
            id: UUID(),
            rowID: rowID,
            punched: rows[index].hole.punched,
            daykey: Daykey.make(now)
        )
        punchMarks.append(mark)
        if fold != .read {
            fold = punchedCandidates.isEmpty && !rows.contains(where: { $0.hole.punched }) ? .open : .punched
        }
        return mark
    }

    /// Two already-punched Rows, even chance, Read legal from Open. No weights.
    mutating func applyTie(left: String, right: String) {
        rows = [
            Row.named(left, punched: true),
            Row.named(right, punched: true),
        ]
        fold = .open
    }

    mutating func read(now: Date = Date()) -> ReadResult {
        if fold == .read {
            return .refusedUntilPeel
        }
        let candidates = punchedCandidates
        guard candidates.count >= 2 else {
            let mark = SparMark(id: UUID(), daykey: Daykey.make(now), punchedCount: candidates.count)
            sparMarks.append(mark)
            return .spar(mark)
        }
        let picked = candidates[SeededDraw.index(seed: drawSeed, count: candidates.count)]
        drawSeed = SeededDraw.advance(drawSeed)
        let verdict = Verdict(
            id: UUID(),
            rowID: picked.id,
            rowName: picked.name,
            daykey: Daykey.make(now)
        )
        verdicts.append(verdict)
        decisions.append(
            DecisionRecord(
                id: UUID(),
                verdictID: verdict.id,
                rowID: picked.id,
                rowName: picked.name,
                daykey: verdict.daykey
            )
        )
        fold = .read
        return .filed(verdict)
    }

    /// Drops the waiting Verdict from the fold only. Rows and history stay.
    @discardableResult
    mutating func peel(now: Date = Date()) -> PeelMark? {
        guard fold == .read, let verdict = verdicts.last else {
            return nil
        }
        let mark = PeelMark(id: UUID(), verdictID: verdict.id, daykey: Daykey.make(now))
        peelMarks.append(mark)
        fold = .punched
        return mark
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case fold
        case rows
        case punchMarks
        case sparMarks
        case peelMarks
        case blanks
        case verdicts
        case decisions
        case drawSeed
        case onboardingComplete
    }

    init(
        schemaVersion: Int,
        fold: AskFold,
        rows: [Row],
        punchMarks: [PunchMark],
        sparMarks: [SparMark],
        peelMarks: [PeelMark],
        blanks: [Blank],
        verdicts: [Verdict],
        decisions: [DecisionRecord],
        drawSeed: UInt64,
        onboardingComplete: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.fold = fold
        self.rows = rows
        self.punchMarks = punchMarks
        self.sparMarks = sparMarks
        self.peelMarks = peelMarks
        self.blanks = blanks
        self.verdicts = verdicts
        self.decisions = decisions
        self.drawSeed = drawSeed
        self.onboardingComplete = onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            fold = try container.decode(AskFold.self, forKey: .fold)
            rows = try container.decode([Row].self, forKey: .rows)
            punchMarks = try container.decode([PunchMark].self, forKey: .punchMarks)
            sparMarks = try container.decode([SparMark].self, forKey: .sparMarks)
            peelMarks = try container.decode([PeelMark].self, forKey: .peelMarks)
            blanks = try container.decode([Blank].self, forKey: .blanks)
            verdicts = try container.decode([Verdict].self, forKey: .verdicts)
            decisions = try container.decode([DecisionRecord].self, forKey: .decisions)
            drawSeed = try container.decode(UInt64.self, forKey: .drawSeed)
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown Ask schema \(version)."
            )
        }
    }
}
