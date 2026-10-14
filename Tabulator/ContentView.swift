import SwiftUI

/// SwiftUI host. The punch card is AskViewController. Review keys route once
/// after the intro is done: today stays on Ask, log opens History, goals opens Settings.
struct ContentView: View {
    @Environment(AskStore.self) private var store
    @State private var didRoute = false
    @State private var launchKey: String?

    var body: some View {
        Group {
            if store.document.onboardingComplete {
                AskScreen(launchKey: launchKey)
            } else {
                CardIntroView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.bg.ignoresSafeArea())
        .onAppear {
            routeIfReady()
        }
        .onChange(of: store.document.onboardingComplete) { _, done in
            if done {
                routeIfReady()
            }
        }
    }

    private func routeIfReady() {
        guard store.document.onboardingComplete, !didRoute else { return }
        didRoute = true
        launchKey = ReviewLaunch.screen
    }
}

struct AskScreen: UIViewControllerRepresentable {
    @Environment(AskStore.self) private var store
    var launchKey: String?

    func makeUIViewController(context: Context) -> AskViewController {
        AskViewController(store: store, launchKey: launchKey)
    }

    func updateUIViewController(_ controller: AskViewController, context: Context) {
        controller.consumeLaunch(launchKey)
    }
}

#Preview {
    ContentView()
        .environment(AskStore(seedDemo: false))
}
