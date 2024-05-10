//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View {
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    // globals
    var appState: AppState { .main }
    @State private var colorProvider: PaletteProvider = .main
    
    @State var selectedTabIndex: Int = 0
    
    @State var navigationModel: NavigationModel = .init()
    
    var body: some View {
        content
            .tint(Color(uiColor: colorProvider.uiAccent))
            .onReceive(timer) { _ in
                appState.cleanCaches()
            }
            .environment(appState)
            .environment(colorProvider)
    }
    
    var content: some View {
        CustomTabView(selectedIndex: $selectedTabIndex, tabs: [
            CustomTabItem(title: "Feeds", image: Icons.feeds, selectedImage: Icons.feedsFill) {
                NavigationLayerView(layer: .init(root: .feeds, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(title: "Inbox", image: Icons.inbox, selectedImage: Icons.inboxFill) {
                NavigationLayerView(layer: .init(root: .inbox, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(
                title: "Profile",
                image: Icons.user,
                selectedImage: Icons.userFill,
                onLongPress: {
                    // TODO: haptics here
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
                NavigationLayerView(layer: .init(root: .settings, model: navigationModel), hasSheetModifiers: false)
            }
        ], onSwipeUp: {
            navigationModel.openSheet(.quickSwitcher)
        })
        .ignoresSafeArea()
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
    }
}
