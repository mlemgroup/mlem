//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

struct ContentView: View {
    @AppStorage("colorPalette") var colorPalette: PaletteOption = .standard
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    // globals
    var appState: AppState { .main }
    
    @State var palette: Palette = .main
    
    @State var selectedTabIndex: Int = 0
    @State var tabReselectTracker: TabReselectTracker = .main
    
    var navigationModel: NavigationModel { .main }
    
    var body: some View {
        if appState.appRefreshToggle {
            content
                .onAppear {
                    HapticManager.main.initEngine()
                }
                .onReceive(timer) { _ in
                    appState.cleanCaches()
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
        }
    }

    var shouldDisplayToasts: Bool {
        navigationModel.layers.allSatisfy { !$0.canDisplayToasts }
    }
    
    var content: some View {
        CustomTabView(selectedIndex: $selectedTabIndex, tabs: [
            CustomTabItem(title: "Feeds", image: Icons.feeds, selectedImage: Icons.feedsFill) {
                NavigationSplitRootView(layer: .init(root: .feeds, model: navigationModel)) {
                    SubscriptionListView()
                }
            },
            CustomTabItem(title: "Inbox", image: Icons.inbox, selectedImage: Icons.inboxFill) {
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
