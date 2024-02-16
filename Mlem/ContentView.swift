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
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.markReadBatcher) var markReadBatcher
    
    @Environment(\.setAppFlow) private var setFlow
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var editorTracker: EditorTracker = .init()
    @StateObject var unreadTracker: UnreadTracker = .init()
    
    @State private var errorAlert: ErrorAlert?
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var tabNavigation: any FancyTabBarSelection = TabSelection._tabBarNavigation
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false
    @State private var tokenRefreshAccount: SavedAccount?
    
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false
    @AppStorage("allowTabBarSwipeUpGesture") var allowTabBarSwipeUpGesture: Bool = true
    @AppStorage("appLock") var appLock: AppLock = .disabled

    @StateObject private var quickLookState: ImageDetailSheetState = .init()
    @StateObject var biometricUnlock = BiometricUnlock()

    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }

    var isAppLocked: Bool {
        appLock != .disabled && !biometricUnlock.isUnlocked
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
                
                // wrapping these two behind a check for an active user, as of now we'll always have one
                // but when guest mode arrives we'll either omit these entirely, or replace them with a
                // guest mode specific tab for sign in / change instance screen.
                if appState.currentActiveAccount != nil {
                    InboxView()
                        .fancyTabItem(tag: TabSelection.inbox) {
                            FancyTabBarLabel(
                                tag: TabSelection.inbox,
                                symbolConfiguration: .inbox,
                                badgeCount: showInboxUnreadBadge ? unreadTracker.total : 0
                            )
                        }
                }
                    
                ProfileView()
                    .fancyTabItem(tag: TabSelection.profile) {
                        FancyTabBarLabel(
                            tag: TabSelection.profile,
                            customText: appState.tabDisplayName,
                            symbolConfiguration: .init(
                                symbol: FancyTabBarLabel.SymbolConfiguration.profile.symbol,
                                activeSymbol: FancyTabBarLabel.SymbolConfiguration.profile.activeSymbol,
                                remoteSymbolUrl: appState.profileTabRemoteSymbolUrl
                            )
                        )
                        .simultaneousGesture(accountSwitchLongPress)
                    }
                
                SearchRoot()
                    .fancyTabItem(tag: TabSelection.search) {
                        FancyTabBarLabel(
                            tag: TabSelection.search,
                            symbolConfiguration: .search
                        )
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
        .task(id: appState.currentActiveAccount) {
            accountChanged()
        }
        .onReceive(errorHandler.$sessionExpired) { expired in
            if expired {
                tokenRefreshAccount = appState.currentActiveAccount
            }
        }
        .sheet(item: $tokenRefreshAccount) {
            errorHandler.clearExpiredSession()
        } content: { account in
            TokenRefreshView(account: account) { updatedAccount in
                appState.setActiveAccount(updatedAccount)
            }
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
                AddSavedInstanceView(onboarding: false)
            } else {
                QuickSwitcherView()
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(item: $editorTracker.editResponse) { editing in
            NavigationStack {
                ResponseEditorView(concreteEditorModel: editing)
            }
            .presentationDetents([.medium, .large], selection: .constant(.large))
            ._presentationBackgroundInteraction(enabledUpThrough: .medium)
        }
        .sheet(item: $editorTracker.editPost) { editing in
            NavigationStack {
                PostComposerView(editModel: editing)
            }
            .presentationDetents([.medium, .large], selection: .constant(.large))
            .presentationDragIndicator(.hidden)
            ._presentationBackgroundInteraction(enabledUpThrough: .medium)
        }
        .sheet(item: $editorTracker.banUser) { editing in
            NavigationStack {
                BanUserView(editModel: editing)
            }
            .presentationDetents([.medium, .large], selection: .constant(.large))
            .presentationDragIndicator(.hidden)
            ._presentationBackgroundInteraction(enabledUpThrough: .medium)
        }
        .sheet(item: $quickLookState.url) { url in
            NavigationStack {
                ImageDetailView(url: url)
            }
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(editorTracker)
        .environmentObject(unreadTracker)
        .environmentObject(quickLookState)
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                // prevents the app from reopening with the switcher enabled.
                isPresentingAccountSwitcher = false
                
                // flush batcher(s) to avoid batches being lost on quit
                Task {
                    await markReadBatcher.flush()
                }
                
                // activate biometric lock
                if appLock != .disabled {
                    biometricUnlock.isUnlocked = false
                }
            }
        }
        .fullScreenCover(isPresented: .constant(isAppLocked)) {
            AppLockView(biometricUnlock: biometricUnlock)
        }
    }
    
    // MARK: Helpers
    
    /// Function that executes whenever the account changes to handle any state updates that need to happen
    func accountChanged() {
        // refresh unread count
        Task(priority: .background) {
            do {
                let unreadCounts = try await personRepository.getUnreadCounts()
                unreadTracker.update(with: unreadCounts)
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    func showAccountSwitcherDragCallback() {
        if !homeButtonExists, allowTabBarSwipeUpGesture, accountsTracker.savedAccounts.count > 1 {
            isPresentingAccountSwitcher = true
        }
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
                            for account in accountsTracker.savedAccounts where account != appState.currentActiveAccount {
                                setFlow(.account(account))
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
