//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import MlemMiddleware
import Nuke
import SwiftUI
import Theming

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("status.firstAppearance") var firstAppearance: Bool = true
    
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Setting(\.colorPalette) var colorPalette
    @Setting(\.tabProfileLabelType) var tabProfileLabelType
    @Setting(\.tabProfileShowAvatar) var tabProfileShowAvatar
    
    let cacheCleanTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let unreadCountTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    // globals
    var appState: AppState { .main }
    var tabReselectTracker: TabReselectTracker { .main }
    var navigationModel: NavigationModel { .main }
    var filtersTracker: FiltersTracker { .main }
    var errorsTracker: ErrorsTracker { .main }

    @State var avatarImage: UIImage?
    @State var selectedAvatarImage: UIImage?
    
    var body: some View {
        if appState.appRefreshToggle {
            content
                .task(id: avatarRefreshHash) {
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
                    Task { @MainActor in
                        try await (appState.firstSession as? UserSession)?.unreadCount?.refresh()
                    }
                }
                .navigationSheetModifiers(
                    nextLayer: navigationModel.layers.first,
                    isTopSheet: navigationModel.layers.isEmpty,
                    shareInfo: .init(get: { navigationModel.shareInfo }, set: { navigationModel.shareInfo = $0 }),
                    contentPickerTracker: navigationModel.contentPickerTracker
                )
                .tint(.themedAccent)
                .palette(colorPalette.palette)
                .environment(tabReselectTracker)
                .environment(appState)
                .environment(filtersTracker)
                .environment(errorsTracker)
                .task {
                    do {
                        try await MlemStats.main.loadInstances()
                    } catch {
                        handleError(error)
                    }
                }
                .onAppear {
                    if firstAppearance, persistenceRepository.systemSettingsExists(.v1) {
                        firstAppearance = false
                        Settings.main.restore(from: .v1)
                    }
                }
                .onChange(of: appState.firstPerson) {
                    // Observe AppState.main.firstPerson to update FiltersTracker as needed
                    // TODO: when Observation adds continous observation monitoring, move this into FiltersTracker
                    filtersTracker.moderatedCommunityActorIds = appState.firstPerson?.moderatedCommunityActorIds ?? .init()
                }
                .onChange(of: scenePhase, initial: false) {
                    if AppState.main.firstAccount is UserAccount, scenePhase != .active {
                        Task {
                            do {
                                try await AppState.main.firstApi.flushPostReadQueue()
                            } catch {
                                handleError(error)
                            }
                        }
                    }
                    if scenePhase == .active {
                        // When the app moves into the background, the haptic engine stops.
                        // This ensures the engine is started before a haptic is played to avoid a short lag while the engine starts
                        HapticManager.main.startEngine()
                    }
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
            CustomTabItem(.feeds, appState: appState, profileLabelType: tabProfileLabelType) {
                NavigationSplitRootView(sidebar: .subscriptionList, root: .feeds())
            },
            CustomTabItem(
                .inbox,
                appState: appState,
                profileLabelType: tabProfileLabelType,
                badge: (appState.firstSession as? UserSession)?.unreadCount?.badgeLabel
            ) {
                NavigationLayerView(layer: .init(root: .inbox, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(
                .profile,
                appState: appState,
                profileLabelType: tabProfileLabelType,
                imageOverride: avatarImage ?? UIImage(systemName: Icons.personCircle),
                selectedImageOverride: selectedAvatarImage ?? UIImage(systemName: Icons.personCircleFill),
                onLongPress: {
                    HapticManager.main.play(haptic: .rigidInfo, priority: .high)
                    NavigationModel.main.openSheet(.quickSwitcher)
                },
                content: {
                    NavigationLayerView(layer: .init(root: .profile, model: navigationModel), hasSheetModifiers: false)
                }
            ),
            CustomTabItem(.search, appState: appState, profileLabelType: tabProfileLabelType) {
                NavigationLayerView(layer: .init(root: .search, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(.settings, appState: appState, profileLabelType: tabProfileLabelType) {
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
