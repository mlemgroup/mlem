//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import Dependencies

struct ContentView: View {
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.personRepository) var personRepository
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    
    @StateObject var editorTracker: EditorTracker = .init()
    @StateObject var unreadTracker: UnreadTracker = .init()
    
    @State private var errorAlert: ErrorAlert?
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var showLoading: Bool = false
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false
    
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    var body: some View {
        FancyTabBar(selection: $tabSelection, dragUpGestureCallback: showAccountSwitcher) {
            Group {
                FeedRoot(showLoading: showLoading)
                    .fancyTabItem(tag: TabSelection.feeds) {
                        FancyTabBarLabel(tag: TabSelection.feeds,
                                         symbolName: "scroll",
                                         activeSymbolName: "scroll.fill")
                    }
                InboxView()
                    .fancyTabItem(tag: TabSelection.inbox) {
                        FancyTabBarLabel(tag: TabSelection.inbox,
                                         symbolName: "mail.stack",
                                         activeSymbolName: "mail.stack.fill",
                                         badgeCount: unreadTracker.total)
                    }
                
                ProfileView(userID: appState.currentActiveAccount.id)
                    .fancyTabItem(tag: TabSelection.profile) {
                        FancyTabBarLabel(tag: TabSelection.profile,
                                         customText: computeUsername(account: appState.currentActiveAccount),
                                         symbolName: "person.circle",
                                         activeSymbolName: "person.circle.fill")
                        .simultaneousGesture(accountSwitchLongPress)
                    }
                SearchView()
                    .fancyTabItem(tag: TabSelection.search) {
                        FancyTabBarLabel(tag: TabSelection.search,
                                         symbolName: "magnifyingglass",
                                         activeSymbolName: "text.magnifyingglass")
                    }
                
                SettingsView()
                    .fancyTabItem(tag: TabSelection.settings) {
                        FancyTabBarLabel(tag: TabSelection.settings,
                                         symbolName: "gear")
                    }
            }
        }
        // TODO: remove once all using `.errorHandler` as the `appState` will no longer receive these...
        .onChange(of: appState.contextualError) { errorHandler.handle($0) }
        .task(id: appState.currentActiveAccount) {
            print("account changed to \(appState.currentActiveAccount.username)")
            
            // get inbox count
            Task(priority: .background) {
                do {
                    let unreadCounts = try await personRepository.getUnreadCounts()
                    unreadTracker.update(with: unreadCounts)
                    // print(unreadCounts)
                } catch {
                    appState.contextualError = .init(underlyingError: error)
                }
            }
        }
        .onReceive(errorHandler.$sessionExpired) { expired in
            if expired {
                NotificationDisplayer.presentTokenRefreshFlow(for: appState.currentActiveAccount) { updatedAccount in
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
            AccountsPage(onboarding: false)
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $editorTracker.editResponse) { editing in
            ResponseEditorView(concreteEditorModel: editing)
        }
        .sheet(item: $editorTracker.editPost) { editing in
            PostComposerView(editModel: editing)
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(appState)
        .environmentObject(editorTracker)
        .environmentObject(unreadTracker)
    }
    
    // MARK: helpers
    func computeUsername(account: SavedAccount) -> String {
        return showUsernameInNavigationBar ? account.username : "Profile"
    }
    
    func showAccountSwitcher() {
        isPresentingAccountSwitcher = true
    }
    
    var accountSwitchLongPress: some Gesture {
        LongPressGesture()
            .onEnded { _ in
                // disable long press in accessibility mode to prevent conflict with HUD
                if !UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
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
