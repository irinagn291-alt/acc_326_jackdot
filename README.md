# Tabulator

Tabulator is a stuck chooser for people who need one honest pick from typed names. The home screen is a punch card. You punch the rows still in play, then Read files one of them. There are no weights, no wheel, and no scored matrix.

## Architecture

The card is a Hollerith fold: Open, Punched, or Read, held over Rows. Each Row stores a typed name and a Hole. Punch toggles that Hole and appends a PunchMark. Punch on an empty Ask writes Blank and adds nothing. Read, from Open or Punched, draws one punched non-blank Row with a seeded uniform index (seed modulo count), files a Verdict on a DecisionRecord, and folds the card to Read. The seed advances only when a Verdict files. Read with fewer than two punched rows writes a SparMark and keeps the fold. Read while the fold is already Read is refused until Peel appends a PeelMark and folds Read back to Punched. Rows and filed history stay. This fold fits the product because the eligible set is the punched holes, and the filed pick is a state of the card, not a separate spinner.

The punch card is a UIKit XIB. SwiftUI hosts it so Dynamic Type, scene lifecycle, and review-screen routing stay on the app side. History and Settings are sheets. A single UIVisualEffectView sits behind the Ask plate. Core Graphics registration ticks are drawn only on that plate.

## Punch-then-read

Only punched rows enter the draw. Tie mode writes two rows already punched at even chance so Read is legal from Open, with no sliders. The Simulator seed lists three punched rows, so the first tap on home is Read. Peel retracts the newest Verdict without deleting rows. History lists DecisionRecords in Verdict order. Settings names the generator: Seeded draw, uniform among punched rows.

## How this differs

Achillea freezes the full list, then draws with mass. Tabulator defines the eligible subset with holes before any draw. It is not an arena wheel and not a weighted matrix.

## Art

Style: technical blueprint diagram of a tabulator, orthographic and machined, with registration ticks and hairline rules engraved on solid masses. Strong contrast between subject and field, quiet center, no letters, no numerals, no logos. Subjects are solid opaque parts with a filled center.

Image sets are named and left empty for the asset pass. Prompts:

- tab_AppIcon: A single solid tabulator punch die, orthographic, filling the canvas edge to edge, subject kept inside the middle 80 percent. Engraved ticks on the solid mass. No text, no numerals, no rounded mask, no alpha, no drop shadow.
- tab_Splash: Vertical blueprint of a tabulator press, fills the canvas, with a calm uncluttered center band so a wordmark can sit on it. No text, no numerals, no logo.
- tab_Onboarding1: A solid closed punch card standing upright, opaque metal or ceramic, engraved column rules on the face.
- tab_Onboarding2: A solid punch stylus mid-press into a thick card, opaque metal, the verb frozen mid-gesture.
- tab_Onboarding3: A solid stack of three filed verdict plates, staggered so each plate stays visible, opaque metal.
- tab_EmptyHome: A solid closed card case waiting to be used, metal or ceramic, fully opaque, calm, engraved ticks on the lid.
- tab_EmptyList: A solid empty filing tray with no plates in it, opaque metal, calm, thick walls and a solid base.
- tab_CardBackdrop: An abstract blueprint field of hairline rules and registration crosses, low detail, filling the canvas edge to edge so type stays readable. No text, no numerals, no competing subject.
- tab_ControlFace: The face of one round punch button, a solid metal disc with an engraved ring and a filled center.
- tab_TwistHero: A solid card block with two filled bores and one raised chosen column, opaque metal, the punch-then-read emblem.
- tab_SuccessMark: A solid filled confirmation slug of thick metal, occupying the middle of the canvas.
- tab_HeaderDecor: A wide solid machined ruler band with registration notches along one edge, opaque, no letters and no numerals.

## Build

```bash
cd apps/Tabulator
xcodegen generate
xcodebuild build-for-testing -scheme Tabulator -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```
