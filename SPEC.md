# Tabulator — Build Specification

> Portfolio app 153, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Read one pick from names you typed on the card.

| Field | Value |
| --- | --- |
| Product name | Tabulator |
| Bundle identifier | `com.tabulator.read` |
| Domain | https://tabulator-read.pro |
| Contact URL | https://tabulator-read.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `tab_` |
| User-Agent | `Tabulator/1.0 (iOS; +https://tabulator-read.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Tabulator -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A stuck chooser punches the rows still in play and reads the card so one option files as the pick.

### 2.1 User flow

1. On home, tap Read to draw among the three rows that are already punched on the seeded card.
2. Type a new option into the punch-card table.
3. Tap a row's hole to unpunch an option you refuse to win.
4. Tap Read again to file a Verdict from only the punched rows.
5. Open History as a sheet and scroll past filed Verdicts.
6. Tap Peel on Ask to retract the newest Verdict and read again.
7. Open Settings as a sheet to reset data or confirm the seeded generator.

### 2.2 Essential behaviour

- Punch-card table of option rows with toggle holes
- Seeded uniform draw among punched rows only
- SparMark when Read runs with fewer than two punched rows
- Peel retracts the newest Verdict without deleting rows
- History sheet listing DecisionRecords and Verdict order
- UserDefaults-backed Ask document with debounced save
- No camera, no catalog API, no weights, no wheel

---

## 3. Uniqueness assignment for Tabulator

| Axis | Assigned value |
| --- | --- |
| Architecture | **Hollerith ADT fold (Open | Punched | Read); the card is a fold over Rows; Punch toggles a Hole on a Row and writes a PunchMark; Read writes a Verdict by uniform choice among punched Rows and folds Open or Punched to Read when at least two Rows are punched; Read with fewer than two punched Rows writes a SparMark and keeps the fold; Read while Read is refused until Peel writes a PeelMark and folds Read to Punched; Punch on an empty Ask writes Blank; tie mode writes two Rows at even punch and allows Read from Open** |
| UI approach | **UIKit XIBs · material** |
| Naming convention | **Hollerith / tabulator lexicon** |
| File organization | **By hollerith role (Ask, Row, Hole, PunchMark, Verdict, SparMark, PeelMark, DecisionRecord)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **futuristic · punch-card · high-contrast** |
| Typography | **Impact** |
| Navigation pattern | **Card-locked chrome (the punch card never leaves; History and Settings arrive as sheets; punch and read fuse on Ask)** |
| AI art style | **Technical blueprint diagram · take tabulator** |
| Functional twist | **Punch-then-read (only punched rows enter the draw; Read with fewer than two punched rows is refused)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — random_picker

**Core** — A stuck chooser punches the rows still in play and reads the card so one option files as the pick.

**Audience** — People who need one honest pick from typed names and want to drop options without weights, a room wheel, or a scored matrix.

**User flow**

1. On home, tap Read to draw among the three rows that are already punched on the seeded card.
2. Type a new option into the punch-card table.
3. Tap a row's hole to unpunch an option you refuse to win.
4. Tap Read again to file a Verdict from only the punched rows.
5. Open History as a sheet and scroll past filed Verdicts.
6. Tap Peel on Ask to retract the newest Verdict and read again.
7. Open Settings as a sheet to reset data or confirm the seeded generator.

**Essential features**

- Punch-card table of option rows with toggle holes
- Seeded uniform draw among punched rows only
- SparMark when Read runs with fewer than two punched rows
- Peel retracts the newest Verdict without deleting rows
- History sheet listing DecisionRecords and Verdict order
- UserDefaults-backed Ask document with debounced save
- No camera, no catalog API, no weights, no wheel

**Twist** — Punch-then-read. Ask is the punch card. Punch toggles a Hole on a Row and writes a PunchMark. Read runs seeded uniform chance over Rows whose Hole is punched and writes a Verdict that files as the pick. Read with fewer than two punched Rows writes a SparMark and keeps the card. Read while the last Verdict is still filed is refused until Peel drops that Verdict. Punch never changes a filed Verdict. Tie mode seeds two Rows punched even and skips the punch step so the opening Read can file. Seed already lists three punched Rows so the first tap on home is Read. Home verb: punch-then-read, not gage-then-draw and not spin-the-wheel. History lists Verdicts. Settings names the seeded generator. No criteria grid and no mass sliders.

**Why this is not a repeat** — Achillea already owns gage-then-draw: freeze the full list, then massed chance. Tabulator's home verb is punch-then-read: the user defines the eligible subset with holes before any draw, with no GageMark and no weight rails. That is not Amerce's arena wheel or a weighted_decision matrix. Same family screens (Ask, History, Settings) but a different persisted fold and first-tap job.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: No tabs. Ask → options → optional weights → reveal.
- Invariant: Weighted roulette, weight ≥ 0.01, seeded RNG. Argument mode = forced 50/50, sliders skipped. Need ≥ 2 non-blank options.
- Never: Not Spinmob. Not Tradeoff.
- Desk `spoke_length`: L=√(r1²+r2²+off²−2 r1 r2 cos(2π·cross/n))−hole/2. Polar 32-spoke map is mandatory.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.
- Mini-ref `Polinka`: steal Typed options, one honest pick, haptics, history, empty feed. Never WKWebView contact. Do not turn the pick into a gambling board. New types and layout — do not reskin.

### 3.1 Architecture contract

Ask is a Hollerith fold whose cases are Open, Punched, and Read, and the card is that fold over Rows, each Row storing a typed name and a Hole. Punch toggles the Hole on one Row and appends a PunchMark, while Punch on an Ask that has no Rows writes Blank and adds nothing. Read from Open or Punched, when at least two Rows are punched and non-blank, selects one of those Rows by a seeded uniform draw, writes a Verdict, files that Verdict on a DecisionRecord, and folds the card to Read. Read with fewer than two punched non-blank Rows writes a SparMark and keeps the fold, and Read while the fold is already Read is refused until Peel appends a PeelMark and folds Read back to Punched without deleting Rows or filed history. Punch never rewrites a filed Verdict, tie mode writes two Rows already punched at even chance so Read is legal from Open, and the Simulator seed lists three punched Rows so the first home verb is Read.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Ask, History, and Settings are UIKit view controllers loaded from XIBs. TabulatorApp is a SwiftUI App that hosts AskViewController through UIViewControllerRepresentable so the lifecycle, Dynamic Type environment, and review-screen routing stay on the SwiftUI side while the punch card itself is the XIB. Ask.xib holds the row table, the name field, the hole buttons, and the Read and Peel controls. Each Row is a XIB cell. History.xib and Settings.xib are presented as sheets over the card. The material extra is one UIVisualEffectView behind the Ask plate only. Rows, sheets, and every other surface use the kit hairline plus flat fill, one radius language, and the filled capsule for Read. Read uses a button style with default, pressed, disabled, and a Spar status that is copy plus the mark, not a second accent. Reset uses a destructive style. Hole, Read, and Peel targets are at least 44 points with the hit on the whole control. Icon-only holes expose VoiceOver labels that say Punch or Unpunch plus the row name. Press scale is 0.97 over 140 to 180 milliseconds, and Reduce Motion keeps the fade and drops the scale. Core Graphics registration ticks are confined to the Ask plate.

### 3.3 Naming contract

Convention: Hollerith / tabulator lexicon.

Examples to follow: `AskFold`, `PunchMark`, `SeededDraw`, `DecisionRecord`

### 3.4 Dependency contract

Zero external dependencies. No Package.swift, no SPM product, no CocoaPods, no vendored source. Linked frameworks are UIKit for the XIBs, SwiftUI for the App host, Core Graphics for the Ask plate ticks, and Foundation for Codable, UserDefaults, NumberFormatter, and Calendar. AVFoundation and URLSession are the axis ceiling and stay unused: do not start a capture session and do not call /cgi/search.pl. No WebView, no analytics, no remote config.

### 3.5 Navigation contract

Card-locked chrome. The Ask punch card never leaves and is not inside a TabView. Punch and Read fuse on Ask. History and Settings arrive as sheets and dismiss back to the card. Peel stays on Ask. There is no third tab and no wheel or matrix destination. After onboarding, read ProcessInfo arguments once. -ReviewScreen today stays on Ask, -ReviewScreen log presents the History sheet, and -ReviewScreen goals presents the Settings sheet. Those three keys open three different surfaces. iPhone and iPad are portrait, and the card uses the full width.

### 3.6 Screen composition contract

Ask-root fused punch card (Ask holds the row table and punch/read controls; History and Settings are sheets). Onboarding is three pages the Simulator seed skips: what the card is, punch then Read, Peel and History. Continue or Next is full width at the bottom. Ask fills the device. One live card is the hero, the oversized Verdict or status word sits on the leading side, and the row table fills the remaining height edge to edge. The name field adds a Row. Each hole toggles punch. Read is the accent capsule. When a Verdict is filed, Read waits and Peel is the path. Spar copy sits on the card when a Read has fewer than two punched rows. An Ask with no Rows is a full-page empty state: EmptyHome, the headline Card is blank, the line Type two names, and a full-width Add a row. History is a sheet and a stack of DecisionRecord cards in Verdict order, with its own full-page empty state when nothing is filed. Settings is a sheet with rerun onboarding, a confirm that names the card and says rows and verdicts will be erased, the contact link https://tabulator-read.pro/contact-us, and a plain status line Seeded draw, uniform among punched rows.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By hollerith role (Ask, Row, Hole, PunchMark, Verdict, SparMark, PeelMark, DecisionRecord)**

```
Tabulator/
  Ask/AskFold.swift
Ask/AskDocument.swift
Ask/AskViewController.swift
Ask/Ask.xib
Row/Row.swift
Row/Hole.swift
Row/RowCell.xib
Marks/PunchMark.swift
Marks/SparMark.swift
Marks/PeelMark.swift
Marks/Blank.swift
Verdict/Verdict.swift
Verdict/DecisionRecord.swift
Verdict/SeededDraw.swift
History/HistoryViewController.swift
History/History.xib
Settings/SettingsViewController.swift
Settings/Settings.xib
Store/AskStore.swift
DesignTokens.swift
Design/TypeScale.swift
App/TabulatorApp.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Ask
A first-class screen for **Ask**. Must render empty, populated and error states.

### 5.3 History
A first-class screen for **History**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **DecisionRecord** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **futuristic · punch-card · high-contrast**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#0F0F0F` | Screen background |
| `surface` | `#1F1F1F` | Cards, rows, sheets |
| `ink` | `#FAFAFA` | Primary text and icons |
| `accent` | `#EABC53` | Primary action, key figure, progress fill |
| `muted` | `#B2B2B2` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Tabulator/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Impact**

Impact is the display face for the type move: one oversized word, then silence. TypeScale has six steps behind one accessor. Display and title are Impact, used only for the Verdict name and the single status word Open, Punched, Read, Blank, or Spar. Load Impact with UIFont(name: "Impact") and Font.custom("Impact"). If that face is nil, those two steps fall back to the system heavy face so the word still renders. Do not bundle a font file. Headline, body, caption, and micro stay the system face. Body is 17 points for row names and sheet copy. Custom sizes use @ScaledMetric. At the largest Dynamic Type size the Verdict word stays one or two lines and the row height grows instead of clipping. Counts and dates go through NumberFormatter. Day storage stays an Int in YYYYMMDD form derived from Calendar.current.startOfDay. No second display family and no fixed size that locks a headline.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **20pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **UIKit XIBs · material**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **UIKit XIBs · material** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **futuristic** — steal rhythm and restraint, not their colours or logos.

Mood: **Forward-looking design with tech-inspired typography, modern layouts, and a sleek, innovation-driven aesthetic.**.

Home rhythm (`punch-card`, comfortable): A card you stamp. History is a stack of cards.

High-end agency: huge type, air, one accent, hairline depth. Layout `punch-card`, density comfortable. Kit 20/12, hairline+fill, filled capsule. Palette recipe `high-contrast`. Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Oversized single word, then silence. Reference type feel: agency.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults plus Codable. One root, AskDocument, encodes to JSON under the single key tab.ask.v1. It holds the fold case, Rows and Holes, the PunchMark, SparMark, PeelMark, and Blank trail, Verdicts, DecisionRecords, the UInt64 draw seed, and schemaVersion. Each Verdict and DecisionRecord stores a daykey Int in YYYYMMDD form from Calendar.current.startOfDay. AskStore is the only type that reads or writes UserDefaults. It keeps the document in memory, debounces a save by about 400 milliseconds after each mark, and flushes when the scene leaves the active state so a force-quit does not drop a Verdict. A decode failure becomes an empty Ask and does not crash. resetAllData() clears the key and is confirmed from Settings. Simulator seed runs once behind tab.demo.v1, marks onboarding complete, writes three punched Rows with real names so Read is enabled, and files several DecisionRecords so History is a used stack. The seed never runs on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Tabulator/1.0 (iOS; +https://tabulator-read.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Punch-then-read (only punched rows enter the draw; Read with fewer than two punched rows is refused)

Punch-then-read is the verb on Ask: the user punches Holes to choose which Rows may win, then Read files one pick. The draw is seeded and uniform, index equals the UInt64 seed modulo the count of punched non-blank Rows, then the seed becomes seed times 6364136223846793005 plus 1 in wrapping UInt64 arithmetic, and the seed advances only when a Verdict files. Tie mode is the even case: it writes two Rows already punched, skips Punch, and allows Read from Open, with no weight field and no sliders. Read with fewer than two punched non-blank Rows writes a SparMark and keeps the card, and Read while the newest Verdict is still filed is refused until Peel drops that Verdict. Punch does not change a filed Verdict, History lists DecisionRecords in Verdict order, and Settings names the seeded generator as Seeded draw. The unit test covers the modulo draw, the two-row tie, the Spar refusal, and the Peel gate, and the home frame is the punch card with Read enabled.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Technical blueprint diagram · take tabulator**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
Technical blueprint diagram of a tabulator, orthographic and machined, with registration ticks and hairline rules engraved on solid masses. Strong contrast between subject and field, quiet center, no letters, no numerals, no logos. Subjects are solid opaque parts with a filled center. Not a hollow wire frame and not a glass box. No palette colors named here. The app palette is already fixed.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `tab_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `tab_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `tab_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `tab_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `tab_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `tab_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `tab_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `tab_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `tab_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `tab_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `tab_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Punch-then-read (only punched rows enter the draw; Read with fewer than two punched rows is refused)' feature screen. |
| 11 | `tab_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `tab_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`tab_AppIcon`** — 1024x1024

```
A single solid tabulator punch die, orthographic, filling the canvas edge to edge, subject kept inside the middle 80 percent. Engraved ticks on the solid mass. No text, no numerals, no rounded mask, no alpha, no drop shadow.
```

**`tab_Splash`** — 1290x2796

```
Vertical blueprint of a tabulator press, fills the canvas, with a calm uncluttered center band so a wordmark can sit on it. No text, no numerals, no logo.
```

**`tab_Onboarding1`** — 1024x1536

```
A solid closed punch card standing upright, opaque metal or ceramic, engraved column rules on the face, one glance at the product. Solid center, not a hollow frame.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_Onboarding2`** — 1024x1536

```
A solid punch stylus mid-press into a thick card, opaque metal, the verb frozen mid-gesture. Solid center, not an outline.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_Onboarding3`** — 1024x1536

```
A solid stack of three filed verdict plates, staggered so each plate stays visible, opaque metal, accumulated records. Solid masses, not wire cards.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_EmptyHome`** — 1024x1024

```
A solid closed card case waiting to be used, metal or ceramic, fully opaque, calm, engraved ticks on the lid. Not glass, not a wire frame, not a hollow box.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_EmptyList`** — 1024x1024

```
A solid empty filing tray with no plates in it, opaque metal, calm, thick walls and a solid base. Not a hollow outline.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_CardBackdrop`** — 1200x800

```
An abstract blueprint field of hairline rules and registration crosses, low detail, filling the canvas edge to edge so type stays readable. No text, no numerals, no competing subject.
```

**`tab_ControlFace`** — 512x512

```
The face of one round punch button, a solid metal disc with an engraved ring and a filled center. Not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_TwistHero`** — 1024x1024

```
A solid card block with two filled bores and one raised chosen column, opaque metal, the punch-then-read emblem. Solid center, not a line drawing of a wheel.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_SuccessMark`** — 512x512

```
A solid filled confirmation slug of thick metal, occupying the middle of the canvas. Not a thin outline and not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tab_HeaderDecor`** — 1200x600

```
A wide solid machined ruler band with registration notches along one edge, opaque, no letters and no numerals.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`tab.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `TabulatorTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Tabulator/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Tabulator -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Hollerith ADT fold (Open | Punched | Read); the card is a fold over Rows; Punch toggles a Hole on a Row and writes a PunchMark; Read writes a Verdict by uniform choice among punched Rows and folds Open or Punched to Read when at least two Rows are punched; Read with fewer than two punched Rows writes a SparMark and keeps the fold; Read while Read is refused until Peel writes a PeelMark and folds Read to Punched; Punch on an empty Ask writes Blank; tie mode writes two Rows at even punch and allows Read from Open** with no leakage across layers.
- [ ] UI approach matches **UIKit XIBs · material**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Card-locked chrome (the punch card never leaves; History and Settings arrive as sheets; punch and read fuse on Ask)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Impact** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Tabulator
xcodegen generate
xcodebuild build-for-testing -scheme Tabulator -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.tabulator.read/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Tabulator -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.tabulator.read/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Tabulator -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.tabulator.read/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
