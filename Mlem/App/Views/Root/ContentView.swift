//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI
import SwiftUIIntrospect

struct ContentView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.accountsTracker) var accountsTracker
    
    @Environment(\.scenePhase) var scenePhase

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var appState: AppState { .main }
    
    @State private var isPresentingAccountSwitcher: Bool = false

    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }
    
    var body: some View {
        content
            .onReceive(timer) { _ in
                // print("Clearing caches...")
                appState.cleanCaches()
            }
            .sheet(isPresented: $isPresentingAccountSwitcher) {
                QuickSwitcherView()
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: scenePhase) {
                // when app moves into background, hide the account switcher. This prevents the app from reopening with the switcher enabled.
                if scenePhase != .active {
                    isPresentingAccountSwitcher = false
                }
            }
            .environment(appState)
    }
    
    var content: some View {
        CustomTabView(tabs: [
            CustomTabItem(title: "Feeds", systemImage: Icons.feedsFill) {
                FeedsView()
            },
            CustomTabItem(
                title: "Profile",
                systemImage: Icons.user,
                onLongPress: {
                    // TODO: haptics here
                    isPresentingAccountSwitcher = true
                },
                content: { ProfileView() }
            )
        ], onSwipeUp: {
            isPresentingAccountSwitcher = true
        })
        .ignoresSafeArea()
    }
    
    // MARK: Helpers
    
    /// Function that executes whenever the account changes to handle any state updates that need to happen
    func accountChanged() async {
        print("Account changed")
    }
}
