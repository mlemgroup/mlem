//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

struct ContentView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.accountsTracker) var accountsTracker
    
    @Environment(\.scenePhase) var scenePhase

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var tabNavigation: any FancyTabBarSelection = TabSelection._tabBarNavigation
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false

    var accessibilityFont: Bool { UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory }
    
    var appState: AppState { AppState.main }
        
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
                appState.safeApi.cleanCaches()
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
//                if !accessibilityFont {
//                    if allowQuickSwitcherLongPressGesture {
//                        if accountsTracker.savedAccounts.count == 2 {
//                            for account in accountsTracker.savedAccounts where account.actorId != appState.actorId {
//                                // TODO: ???????
//                                appState.api = account.api
//                                break
//                            }
//                        } else {
//                            isPresentingAccountSwitcher = true
//                        }
//                    }
//                }
            }
    }
}
