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
    
    // TODO: pass in user and instance to this view. Everything below here has User? and Instance
    
    @State var appState: AppState

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    /// Create an authenticated content view
    /// - Parameter user: user to create content view for
    init(user: UserStub) {
        self._appState = .init(initialValue: AppState(user: user))
    }
    
    /// Create a guest content view
    /// - Parameter user: user to create content view for
    init(api: ApiClient) {
        self._appState = .init(initialValue: .init(api: api))
    }
    
    // tabs
    @State private var tabSelection: Int = 0
    @State private var hasSetupTabBar: Bool = false
    
    @State private var isPresentingAccountSwitcher: Bool = false

    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }
        
    var profileTabAvatar: URL? { appState.myUser?.avatarUrl }
    
    var profileTabLabel: String { "Profile" }
    
    var body: some View {
        content
//            .task(id: appState.actorId) {
//                do {
//                    appState.myInstance = try await appState.myInstance.stub.upgrade()
//                } catch {
//                    errorHandler.handle(error)
//                }
//            }
            .onReceive(timer) { _ in
                // print("Clearing caches...")
                appState.api.cleanCaches()
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
                onLongPress: openAccountSwitcher
            ) {
                ProfileView()
            }
        ], onSwipeUp: openAccountSwitcher)
        .onChange(of: tabSelection) {
            print("TAB", tabSelection)
        }
    }
    
    // MARK: Helpers
    
    /// Function that executes whenever the account changes to handle any state updates that need to happen
    func accountChanged() async {
        print("Account changed")
    }
    
    func openAccountSwitcher() {
        isPresentingAccountSwitcher = true
    }
}
