//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import Nuke
import SwiftUI
import XCTestDynamicOverlay

@main
struct MlemApp: App {
    @Dependency(\.accountsTracker) var accountsTracker
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                Window(flow: initialFlow)
                    .onAppear {
                        var imageConfig = ImagePipeline.Configuration.withDataCache(name: "main", sizeLimit: AppConstants.cacheSize)
                        imageConfig.dataLoadingQueue = OperationQueue(maxConcurrentCount: 8)
                        imageConfig.imageDecodingQueue = OperationQueue(maxConcurrentCount: 8) // Let's use those CORES
                        imageConfig.imageDecompressingQueue = OperationQueue(maxConcurrentCount: 8)
                        
                        // I'm leaving that here for mormaer, once I get a handle on rate limites that's where we put em!
                        // imageConfig.isRateLimiterEnabled
                        ImagePipeline.shared = ImagePipeline(configuration: imageConfig)
                        
                        URLCache.shared = AppConstants.urlCache
                        
                        setupAppShortcuts()
                        
                        // clear out tmp directory
                        let tempDirectory = FileManager.default.enumerator(atPath: FileManager.default.temporaryDirectory.absoluteString
                        )
                        if let tempDirectory {
                            for case let file as URL in tempDirectory {
                                try? FileManager.default.removeItem(at: file)
                            }
                        }
                        
                        // set app theme to user preference
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                        windowScene?.windows.first?.overrideUserInterfaceStyle = lightOrDarkMode
                        
                        let appearance = UITabBarAppearance()
                        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
                        UITabBar.appearance().standardAppearance = appearance
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                        
                        // check whether this device has a home button
                        // note: this only works in iOS 11+; since we're incompatible with anything under 16, that shouldn't be a problem
                        if let bottomInset = windowScene?.windows[0].safeAreaInsets.bottom, bottomInset > 0 {
                            homeButtonExists = false
                        } else {
                            homeButtonExists = true
                        }
                    }
            }
        }
        .onChange(of: lightOrDarkMode) { value in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.overrideUserInterfaceStyle = value
        }
    }

    private func setupAppShortcuts() {
        guard accountsTracker.savedAccounts.first != nil else { return }
        
        UIApplication.shared.shortcutItems = FeedType.allShortcutFeedCases.map { feedType in
            let icon = UIApplicationShortcutIcon(systemImageName: feedType.iconName)
            return UIApplicationShortcutItem(
                type: feedType.toShortcutString,
                localizedTitle: feedType.label,
                localizedSubtitle: nil,
                icon: icon,
                userInfo: nil
            )
        }
    }
    
    /// A variable describing the initial flow the application should run after start-up
    private var initialFlow: AppFlow {
        guard let account = accountsTracker.defaultAccount else {
            return .onboarding
        }
        
        return .account(account)
    }
}
