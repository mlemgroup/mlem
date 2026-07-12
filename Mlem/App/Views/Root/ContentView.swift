//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import Haptics
import MlemBackend
import MlemMiddleware
import Nuke
import QuickSwipes
import SwiftUI
import Theming

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Setting(\.appearance_palette) var colorPalette
    @Setting(\.tab_profile_labelType) var tabProfileLabelType
    @Setting(\.tab_profile_showAvatar) var tabProfileShowAvatar
    @Setting(\.tab_gestures_longPressAction) var tabLongPressAction
    @Setting(\.dev_developerMode) var developerMode
    @Setting(\.behavior_hapticLevel) var hapticLevel
    @Setting(\.behavior_enableQuickSwipes) var quickSwipesEnabled

    let cacheCleanTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let unreadCountTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    // globals
    var appState: AppState { .main }
    var tabReselectTracker: TabReselectTracker { .main }
    var navigationModel: NavigationModel { .main }
    var mediaTracker: MediaTracker { .main }

    var filtersTracker: FiltersTracker { .main }
    var errorsTracker: ErrorsTracker { .main }
    var backendClient: BackendClient { .main }
    var hapticManager: HapticManager { .main }
    
    @State var avatarImage: UIImage?
    @State var selectedAvatarImage: UIImage?
    
    @State var expandedPostHistoryTracker: ExpandedPostHistoryTracker = .init()
    @State var eventsTracker: EventsTracker = .init()
    
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
                    shareInfo: .init(
                        get: { navigationModel.shareInfo },
                        set: { navigationModel.shareInfo = $0 }
                    ),
                    translationConfiguration: .init(
                        get: { navigationModel.translationConfiguration },
                        set: { navigationModel.translationConfiguration = $0 }
                    ),
                    contentPickerTracker: navigationModel.contentPickerTracker
                )
                .accentColor(ThemedColor.themedAccent.resolve(with: colorPalette.palette)) // deprecated, but .tint colors menu buttons
                .palette(colorPalette.palette)
                .environment(tabReselectTracker)
                .environment(appState)
                .environment(filtersTracker)
                .environment(errorsTracker)
                .environment(expandedPostHistoryTracker)
                .environment(backendClient)
                .environment(eventsTracker)
                .environment(mediaTracker)
                .environment(ToastModel.main)
                .quickSwipesDisabled(!quickSwipesEnabled)
                .quickSwipeThresholds(primary: 60, secondary: 150, tertiary: 240)
                .quickSwipeMinimumDrag(20)
                .quickSwipeCornerRadius(Constants.main.standardSpacing)
                .quickSwipeIconSize(28)
                .task(id: BackendClient.main.environment) {
                    await MlemStats.main.loadInstances(forceRefresh: true)
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
                }
                .onChange(of: appState.firstAccount.shouldShowVersionWarning, initial: true) {
                    if appState.firstAccount.shouldShowVersionWarning, navigationModel.layers.isEmpty {
                        navigationModel.openSheet(.unsupportedVersion(appState.firstAccount))
                    }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        eventsTracker.refreshIfStale()
                    }
                }
                .hapticConfiguration(maximumHapticTier: hapticLevel, errorHandler: handleHapticError)
                .environment(AppState.main)
                .onOpenURL(perform: self.handleIncomingDeeplink)
                .environment(\.layoutDirection, .rightToLeft)
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
                badge: (appState.firstSession as? UserSession)?.unreadCount?.badgeLabel.map { String($0) }
            ) {
                NavigationLayerView(layer: .init(root: .inbox, model: navigationModel), hasSheetModifiers: false)
            },
            CustomTabItem(
                .profile,
                appState: appState,
                profileLabelType: tabProfileLabelType,
                imageOverride: avatarImage ?? UIImage(systemName: "person.crop.circle"),
                selectedImageOverride: selectedAvatarImage ?? UIImage(systemName: "person.crop.circle.fill"),
                onLongPress: {
                    hapticManager.play(haptic: .rigidInfo, tier: .high)
                    
                    switch tabLongPressAction {
                    case .openAccountSwitcher:
                        navigationModel.openSheet(.quickSwitcher)
                    case .switchToMostRecentAccount:
                        // If switch fails (no other accounts), fall back to account switcher.
                        if !appState.switchToMostRecentAccount() {
                            navigationModel.openSheet(.quickSwitcher)
                        }
                    }
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
        .withAccountSwitcherGesture(tabReselectTracker: tabReselectTracker, navigationModel: navigationModel)
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
