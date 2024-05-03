//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var appState: AppState { .main }
    
    @State var selectedTabIndex: Int = 0
    let navigationModels: [NavigationModel] = [.feeds, .inbox, .profile, .search, .settings].map(NavigationModel.init)
    var activeNavigationModel: NavigationModel {
        if 0 ... 5 ~= selectedTabIndex {
            return navigationModels[selectedTabIndex]
        }
        assertionFailure()
        return navigationModels[0]
    }
    
    var body: some View {
        content
            .onReceive(timer) { _ in
                appState.cleanCaches()
            }
            .environment(appState)
    }
    
    var content: some View {
        CustomTabView(selectedIndex: $selectedTabIndex, tabs: [
            CustomTabItem(title: "Feeds", systemImage: Icons.feedsFill) {
                NavigationRootView(navigationModel: navigationModels[0])
            },
            CustomTabItem(title: "Inbox", systemImage: Icons.inboxFill) {
                NavigationRootView(navigationModel: navigationModels[1])
            },
            CustomTabItem(
                title: "Profile",
                systemImage: Icons.userFill,
                onLongPress: {
                    // TODO: haptics here
                    activeNavigationModel.openSheet(.quickSwitcher)
                },
                content: {
                    NavigationRootView(navigationModel: navigationModels[2])
                }
            ),
            CustomTabItem(title: "Search", systemImage: Icons.search) {
                NavigationRootView(navigationModel: navigationModels[3])
            },
            CustomTabItem(title: "Settings", systemImage: Icons.settings) {
                NavigationRootView(navigationModel: navigationModels[4])
            }
        ], onSwipeUp: {
            activeNavigationModel.openSheet(.quickSwitcher)
        })
        .ignoresSafeArea()
    }
}
