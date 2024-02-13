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
    
    @Environment(NewAppState.self) var appState
    
    @StateObject var editorTracker: EditorTracker = .init()
    @StateObject var unreadTracker: UnreadTracker = .init()
    
    @State private var errorAlert: ErrorAlert?
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var tabNavigation: any FancyTabBarSelection = TabSelection._tabBarNavigation
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false
    @State private var tokenRefreshAccount: MyUserStub?
    
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false
    @AppStorage("allowTabBarSwipeUpGesture") var allowTabBarSwipeUpGesture: Bool = true
    @AppStorage("appLock") var appLock: AppLock = .disabled
    
    @AppStorage("profileTabLabel") var profileTabLabelMode: ProfileTabLabel = .nickname
    @AppStorage("showUserAvatarOnProfileTab") var showProfileTabAvatar: Bool = true

    @StateObject private var quickLookState: ImageDetailSheetState = .init()
    @StateObject var biometricUnlock = BiometricUnlock()

    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }

    var isAppLocked: Bool {
        appLock != .disabled && !biometricUnlock.isUnlocked
    }
    
    var profileTabLabel: String {
        switch profileTabLabelMode {
        case .instance:
            return appState.myInstance?.url.host() ?? "Instance"
        case .nickname:
            return appState.myUser?.nickname ?? appState.myUser?.username ?? "Guest"
        case .anonymous:
            return "Profile"
        }
    }
        
    var profileTabAvatar: URL? {
        if showProfileTabAvatar {
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
                
                InboxView()
                    .fancyTabItem(tag: TabSelection.inbox) {
                        FancyTabBarLabel(
                            tag: TabSelection.inbox,
                            symbolConfiguration: .inbox,
                            badgeCount: showInboxUnreadBadge ? unreadTracker.total : 0
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
        .task(id: appState.actorId, priority: .background) {
            await accountChanged()
        }
        .onReceive(errorHandler.$sessionExpired) { expired in
            if expired {
                tokenRefreshAccount = appState.myUser?.stub
            }
        }
        .sheet(item: $tokenRefreshAccount) {
            errorHandler.clearExpiredSession()
        } content: { user in
            TokenRefreshView(user: user)
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
        .sheet(item: $quickLookState.url) { url in
            NavigationStack {
                ImageDetailView(url: url)
            }
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(editorTracker)
        .environmentObject(unreadTracker)
        .environmentObject(quickLookState)
        .onChange(of: scenePhase) {
            // when app moves into background, hide the account switcher. This prevents the app from reopening with the switcher enabled.
            if scenePhase != .active {
                isPresentingAccountSwitcher = false
            }
            if scenePhase == .background || scenePhase == .inactive, appLock != .disabled {
                biometricUnlock.isUnlocked = false
            }
        }
        .fullScreenCover(isPresented: .constant(isAppLocked)) {
            AppLockView(biometricUnlock: biometricUnlock)
        }
    }
    
    // MARK: Helpers
    
    /// Function that executes whenever the account changes to handle any state updates that need to happen
    func accountChanged() async {
        do {
            let unreadCounts = try await personRepository.getUnreadCounts()
            unreadTracker.update(with: unreadCounts)
        } catch {
            errorHandler.handle(error)
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
