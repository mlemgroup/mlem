//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.markReadBatcher) var markReadBatcher
    
    @Environment(AppState.self) var appState
    
    @State private var errorAlert: ErrorAlert?
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var tabNavigation: any FancyTabBarSelection = TabSelection._tabBarNavigation
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false
    
    @AppStorage("profileTabLabel") var profileTabLabelMode: ProfileTabLabel = .nickname
    @AppStorage("showUserAvatarOnProfileTab") var showProfileTabAvatar: Bool = true

    @StateObject private var quickLookState: ImageDetailSheetState = .init()
    @StateObject var biometricUnlock = BiometricUnlock()

    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }
    
    var profileTabLabel: String {
        switch profileTabLabelMode {
        case .instance:
            return appState.myInstance?.url.host() ?? "Instance"
        case .nickname:
            return appState.myUser?.nickname ?? appState.myUser?.name ?? "Guest"
        case .anonymous:
            return "Profile"
        }
    }
        
    var profileTabAvatar: URL? {
        if showProfileTabAvatar, profileTabLabelMode != .anonymous {
            return appState.myUser?.avatarUrl
        }
        return nil
    }
    
    var body: some View {
        FancyTabBar(selection: $tabSelection, navigationSelection: $tabNavigation, dragUpGestureCallback: showAccountSwitcherDragCallback) {
            Group {
                FeedsView()
                    .fancyTabItem(tag: TabSelection.feeds) {
                        FancyTabBarLabel(
                            tag: TabSelection.feeds,
                            symbolConfiguration: .feed
                        )
                    }
                    
                ProfileView()
                    .fancyTabItem(tag: TabSelection.profile) {
                        FancyTabBarLabel(
                            tag: TabSelection.profile,
                            customText: profileTabLabel,
                            symbolConfiguration: .init(
                                symbol: FancyTabBarLabel.SymbolConfiguration.profile.symbol,
                                activeSymbol: FancyTabBarLabel.SymbolConfiguration.profile.activeSymbol,
                                remoteSymbolUrl: profileTabAvatar
                            )
                        )
                        .simultaneousGesture(accountSwitchLongPress)
                    }
                
                SettingsView()
                    .fancyTabItem(tag: TabSelection.settings) {
                        FancyTabBarLabel(
                            tag: TabSelection.settings,
                            symbolConfiguration: .settings
                        )
                    }
            }
        }
        .task(id: appState.actorId, priority: .background) {
            await accountChanged()
        }
        .alert(using: $errorAlert) { content in
            Alert(
                title: Text(content.title),
                message: Text(content.message),
                dismissButton: .default(
                    Text("OK"),
                    action: { errorAlert = nil }
                )
            )
        }
        .sheet(isPresented: $isPresentingAccountSwitcher) {
            if accountsTracker.savedAccounts.count == 1 {
                EmptyView()
                // AddSavedInstanceView(onboarding: false)
            } else {
                QuickSwitcherView()
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(item: $quickLookState.url) { url in
            NavigationStack {
                ImageDetailView(url: url)
            }
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(quickLookState)
        .onChange(of: scenePhase) {
            // when app moves into background, hide the account switcher. This prevents the app from reopening with the switcher enabled.
            if scenePhase != .active {
                isPresentingAccountSwitcher = false
            }
            // flush batcher(s) to avoid batches being lost on quit
            Task {
                await markReadBatcher.flush()
            }
        }
    }
    
    // MARK: Helpers
    
    /// Function that executes whenever the account changes to handle any state updates that need to happen
    func accountChanged() async {
        print("Account changed")
    }
    
    func showAccountSwitcherDragCallback() {
        isPresentingAccountSwitcher = true
    }
    
    var accountSwitchLongPress: some Gesture {
        LongPressGesture()
            .onEnded { _ in
                @AppStorage("allowQuickSwitcherLongPressGesture") var allowQuickSwitcherLongPressGesture: Bool = true
                
                // disable long press in accessibility mode to prevent conflict with HUD
                if !accessibilityFont {
                    if allowQuickSwitcherLongPressGesture {
                        hapticManager.play(haptic: .rigidInfo, priority: .high)
                        if accountsTracker.savedAccounts.count == 2 {
                            hapticManager.play(haptic: .rigidInfo, priority: .high)
                            for account in accountsTracker.savedAccounts where account.actorId != appState.apiSource?.actorId {
                                appState.apiSource = account
                                break
                            }
                        } else {
                            isPresentingAccountSwitcher = true
                        }
                    }
                }
            }
    }
}

// MARK: - URL Handling

extension ContentView {
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        let outcome = URLHandler.handle(url)
        
        switch outcome.action {
        case let .error(message):
            errorAlert = .init(
                title: "Unsupported link",
                message: message
            )
        default:
            break
        }
        
        return outcome.result
    }
}
