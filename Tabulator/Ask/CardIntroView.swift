import SwiftUI

/// Three pages: what the card is, punch then Read, Peel and History.
/// Skip and Continue both mark the intro done.
struct CardIntroView: View {
    @Environment(AskStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [(title: String, line: String, art: String)] = [
        ("The card", "The card holds the rows still in play.", "tab_Onboarding1"),
        ("Punch, then Read", "Punch a hole so the row can win. Read files one pick.", "tab_Onboarding2"),
        ("Peel", "Peel drops the newest verdict. History keeps the file.", "tab_Onboarding3"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            Image(pages[page].art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: Space.x12 * 4)
                .clipped()
                .accessibilityHidden(true)
            Text(pages[page].title)
                .font(TypeScaleFont.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            Text(pages[page].line)
                .font(TypeScaleFont.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Space.x4)
            Button("Skip") {
                finish()
            }
            .buttonStyle(QuietVerbStyle())
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                advance()
            }
            .buttonStyle(CapsuleVerbStyle())
        }
        .padding(Space.x4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(DesignTokens.bg.ignoresSafeArea())
        .animation(reduceMotion ? .easeOut(duration: Motion.sheetDuration) : .easeOut(duration: Motion.sheetDuration), value: page)
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            finish()
        }
    }

    private func finish() {
        store.setOnboardingComplete(true)
    }
}

enum TypeScaleFont {
    static let display = Font.custom(DesignTokens.fontFamily, size: Space.x8 + Space.x4, relativeTo: .largeTitle)
    static let body = Font.body
}

struct CapsuleVerbStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(DesignTokens.bg)
            .frame(maxWidth: .infinity, minHeight: Space.hit)
            .background(DesignTokens.accent, in: Capsule())
            .scaleEffect(configuration.isPressed && !reduceMotion ? Motion.pressScale : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: Motion.pressDuration), value: configuration.isPressed)
    }
}

struct QuietVerbStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(DesignTokens.ink)
            .frame(maxWidth: .infinity, minHeight: Space.hit)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .stroke(DesignTokens.muted, lineWidth: Elevation.hairline)
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
