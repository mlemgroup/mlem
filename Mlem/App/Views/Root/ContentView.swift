//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import MlemMiddleware
import SwiftUI

struct ContentView: View {
    enum Tab: CaseIterable {
        case feeds, inbox, profile, search, settings
    }
    
    @AppStorage("colorPalette") var colorPalette: PaletteOption = .standard
    
    let cacheCleanTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let unreadCountTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    // globals
    var appState: AppState { .main }
    
    @State var palette: Palette = .main
    @State var tabReselectTracker: TabReselectTracker = .main
    
    @State var badgeUpdater: BadgeUpdater = .init()
    
    var navigationModel: NavigationModel { .main }
  
    init() {
        HapticManager.main.preheat()
    }
    
    var body: some View {
        if appState.appRefreshToggle {
            content
                .onReceive(cacheCleanTimer) { _ in
                    appState.cleanCaches()
                }
                .onReceive(unreadCountTimer) { _ in
                    print("Refreshing unread count...")
                    Task { @MainActor in
                        try await (appState.firstSession as? UserSession)?.unreadCount?.refresh()
                    }
                }
                .onChange(of: (appState.firstSession as? UserSession)?.unreadCount?.badgeLabel) { _, newValue in
                    badgeUpdater.wrappedValue = newValue
                }
                .sheet(isPresented: Binding(
                    get: { !(navigationModel.layers.first?.isFullScreenCover ?? true) },
                    set: { if !$0 { navigationModel.layers.removeAll() } }
                )) {
                    NavigationLayerView(layer: navigationModel.layers[0], hasSheetModifiers: true)
                }
                .fullScreenCover(isPresented: Binding(
                    get: { navigationModel.layers.first?.isFullScreenCover ?? false },
                    set: { if !$0 { navigationModel.layers.removeAll() } }
                )) {
                    NavigationLayerView(layer: navigationModel.layers[0], hasSheetModifiers: true)
                }
                .tint(palette.accent)
                .environment(palette)
                .environment(tabReselectTracker)
                .environment(appState)
                .task {
                    do {
                        try await MlemStats.main.loadInstances()
                    } catch {
                        handleError(error)
                    }
                }
        }
    }

    var shouldDisplayToasts: Bool {
        navigationModel.layers.allSatisfy { !$0.canDisplayToasts }
    }
    
    var content: some View {
        CustomTabView(selectedIndex: Binding(get: {
            Tab.allCases.firstIndex(of: appState.contentViewTab) ?? 0
        }, set: {
            appState.contentViewTab = Tab.allCases[$0]
        }), tabs: [
            CustomTabItem(title: "Feeds", image: Icons.feeds, selectedImage: Icons.feedsFill) {
                NavigationSplitRootView(sidebar: .subscriptionList, root: .feeds)
            },
            CustomTabItem(
                title: "Inbox",
                image: Icons.inbox,
                selectedImage: Icons.inboxFill,
                badge: badgeUpdater
            ) {
                NavigationLayerView(layer: .init(root: .inbox, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(
                title: "Profile",
                image: Icons.user,
                selectedImage: Icons.userFill,
                onLongPress: {
                    HapticManager.main.play(haptic: .rigidInfo, priority: .high)
                    navigationModel.openSheet(.quickSwitcher)
                },
                content: {
                    NavigationLayerView(layer: .init(root: .profile, model: navigationModel), hasSheetModifiers: false)
                }
            ),
            CustomTabItem(title: "Search", image: Icons.search, selectedImage: Icons.searchActive) {
                NavigationLayerView(layer: .init(root: .search, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(title: "Settings", image: Icons.settings) {
                NavigationLayerView(layer: .init(root: .settings(), model: navigationModel), hasSheetModifiers: false)
            }
        ], onSwipeUp: {
            navigationModel.openSheet(.quickSwitcher)
        })
        .overlay(alignment: .bottom) {
            ToastOverlayView(
                shouldDisplayNewToasts: shouldDisplayToasts,
                location: .bottom
            )
            .padding(.bottom, 100)
        }
        .ignoresSafeArea()
        .overlay(alignment: .top) {
            ToastOverlayView(
                shouldDisplayNewToasts: shouldDisplayToasts,
                location: .top
            )
        }
    }
}
