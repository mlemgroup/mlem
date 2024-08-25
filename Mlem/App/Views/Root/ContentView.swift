//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import MlemMiddleware
import Nuke
import SwiftUI

struct ContentView: View {
    enum Tab: CaseIterable {
        case feeds, inbox, profile, search, settings
    }
    
    @Setting(\.interfaceStyle) var interfaceStyle
    @Setting(\.colorPalette) var colorPalette
    
    let cacheCleanTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let unreadCountTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    // globals
    var appState: AppState { .main }
    var palette: Palette { .main }
    var tabReselectTracker: TabReselectTracker { .main }
    var navigationModel: NavigationModel { .main }

    @State var avatarImage: UIImage?
    @State var selectedAvatarImage: UIImage?
  
    init() {
        HapticManager.main.preheat()
    }
    
    var body: some View {
        if appState.appRefreshToggle {
            content
                .task(id: appState.firstAccount.avatar) {
                    avatarImage = nil
                    selectedAvatarImage = nil
                    if let url = appState.firstAccount.avatar {
                        await loadAvatar(url: url)
                    }
                }
                .onReceive(cacheCleanTimer) { _ in
                    appState.cleanCaches()
                }
                .onReceive(unreadCountTimer) { _ in
                    print("Refreshing unread count...")
                    Task { @MainActor in
                        try await (appState.firstSession as? UserSession)?.unreadCount?.refresh()
                    }
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
                .onChange(of: interfaceStyle, initial: true) {
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.windows.first?.overrideUserInterfaceStyle = interfaceStyle
                }
                .environment(AppState.main)
        }
    }
    
    @ViewBuilder
    var content: some View {
        CustomTabView(selectedIndex: Binding(get: {
            Tab.allCases.firstIndex(of: appState.contentViewTab) ?? 0
        }, set: {
            appState.contentViewTab = Tab.allCases[$0]
        }), tabs: [
            CustomTabItem(
                title: "Feeds",
                image: UIImage(systemName: Icons.feeds),
                selectedImage: UIImage(systemName: Icons.feedsFill)
            ) {
                NavigationSplitRootView(sidebar: .subscriptionList, root: .feeds(appState.firstApi.willSendToken ? .subscribed : .all))
            },
            CustomTabItem(
                title: "Inbox",
                image: UIImage(systemName: Icons.inbox),
                selectedImage: UIImage(systemName: Icons.inboxFill),
                badge: (appState.firstSession as? UserSession)?.unreadCount?.badgeLabel
            ) {
                NavigationLayerView(layer: .init(root: .inbox, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(
                title: AppState.main.firstAccount.nickname,
                image: avatarImage ?? UIImage(systemName: Icons.personCircle),
                selectedImage: selectedAvatarImage ?? UIImage(systemName: Icons.personCircleFill),
                onLongPress: {
                    HapticManager.main.play(haptic: .rigidInfo, priority: .high)
                    NavigationModel.main.openSheet(.quickSwitcher)
                },
                content: {
                    NavigationLayerView(layer: .init(root: .profile, model: navigationModel), hasSheetModifiers: false)
                }
            ),
            CustomTabItem(
                title: "Search",
                image: UIImage(systemName: Icons.search),
                selectedImage: UIImage(systemName: Icons.searchActive)
            ) {
                NavigationLayerView(layer: .init(root: .search, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(
                title: "Settings",
                image: UIImage(systemName: Icons.settings)
            ) {
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
