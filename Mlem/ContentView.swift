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
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var editorTracker: EditorTracker = .init()
    @StateObject var unreadTracker: UnreadTracker = .init()
    
    @State private var errorAlert: ErrorAlert?
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var tabNavigation: any FancyTabBarSelection = TabSelection._tabBarNavigation
    @State private var showLoading: Bool = false
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false
    
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false
    
    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }
    
    var body: some View {
        FancyTabBar(
            selection: $tabSelection,
            navigationSelection: $tabNavigation,
            dragUpGestureCallback: showAccountSwitcherDragCallback,
            tabItemKeys: [
                .feeds,
                .inbox,
                .profile,
                .search,
                .settings
            ],
            tabItems: [
                .feeds: .init(tag: .feeds, label: {
                    AnyView(
                        FancyTabBarLabel(
                            tag: TabSelection.feeds,
                            symbolConfiguration: .feed
                        )
                    )
                }),
                .inbox: .init(tag: .inbox, label: {
                    AnyView(
                        FancyTabBarLabel(
                            tag: TabSelection.inbox,
                            symbolConfiguration: .inbox,
                            badgeCount: showInboxUnreadBadge ? unreadTracker.total : 0
                        )
                    )
                }),
                .profile: .init(tag: .profile, label: {
                    AnyView(
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
                    )
                }),
                .search: .init(tag: .search, label: {
                    AnyView(
                        FancyTabBarLabel(
                            tag: TabSelection.search,
                            symbolConfiguration: .search
                        )
                    )
                }),
                .settings: .init(tag: .settings, label: {
                    AnyView(
                        FancyTabBarLabel(
                            tag: TabSelection.settings,
                            symbolConfiguration: .settings
                        )
                    )
                })
            ]
        ) {
            FeedRoot(showLoading: showLoading)
                .tag(TabSelection.feeds)
            
            // wrapping these two behind a check for an active user, as of now we'll always have one
            // but when guest mode arrives we'll either omit these entirely, or replace them with a
            // guest mode specific tab for sign in / change instance screen.
            if let account = appState.currentActiveAccount {
                InboxView()
                    .tag(TabSelection.inbox)
                
                ProfileView(userID: account.id)
                    .tag(TabSelection.profile)
            }
            
            SearchView()
                .tag(TabSelection.search)
            
            SettingsView()
                .tag(TabSelection.settings)
        }
        .task(id: appState.currentActiveAccount) {
            accountChanged()
        }
        .onReceive(errorHandler.$sessionExpired) { expired in
            if expired, let account = appState.currentActiveAccount {
                NotificationDisplayer.presentTokenRefreshFlow(for: account) { updatedAccount in
                    appState.setActiveAccount(updatedAccount)
                }
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
            AccountsPage()
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $editorTracker.editResponse) { editing in
            NavigationStack {
                ResponseEditorView(concreteEditorModel: editing)
            }
        }
        .sheet(item: $editorTracker.editPost) { editing in
            NavigationStack {
                PostComposerView(editModel: editing)
            }
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(editorTracker)
        .environmentObject(unreadTracker)
        .onChange(of: scenePhase) { phase in
            // when app moves into background, hide the account switcher. This prevents the app from reopening with the switcher enabled.
            if phase != .active {
                isPresentingAccountSwitcher = false
            }
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
        if !homeButtonExists {
            isPresentingAccountSwitcher = true
        }
    }
    
    var accountSwitchLongPress: some Gesture {
        LongPressGesture()
            .onEnded { _ in
                // disable long press in accessibility mode to prevent conflict with HUD
                if !accessibilityFont {
                    hapticManager.play(haptic: .rigidInfo, priority: .high)
                    isPresentingAccountSwitcher = true
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
