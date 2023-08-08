//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import UIKit
import Nuke
import XCTestDynamicOverlay

@main
struct MlemApp: App {
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false

    @StateObject var accountsTracker: SavedAccountTracker = .init()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                Window(selectedAccount: accountsTracker.defaultAccount)
                    .environmentObject(accountsTracker)
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
                        if let tempDirectory = tempDirectory {
                            for case let file as URL in tempDirectory {
                                try? FileManager.default.removeItem(at: file)
                            }
                        }
                        
                        // set app theme to user preference
                        let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
                        windowScene?.windows.first?.overrideUserInterfaceStyle = lightOrDarkMode
                        
                        let appearance = UITabBarAppearance()
                        appearance.backgroundEffect = UIBlurEffect.init(style: .systemThinMaterial)
                        UITabBar.appearance().standardAppearance = appearance
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                        
                        // check whether this device has a home button
                        if #available(iOS 11.0, *),
                            let bottomInset = windowScene?.windows[0].safeAreaInsets.bottom,
                            bottomInset > 0 {
                            homeButtonExists = false
                        } else {
                            homeButtonExists = true
                        }
                    }
            }
        }
        .onChange(of: lightOrDarkMode) { value in
            let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.overrideUserInterfaceStyle = value
        }
    }

    func setupAppShortcuts() {
        guard accountsTracker.savedAccounts.first != nil else { return }

        // Subscribed Feed
        let homeIcon = UIApplicationShortcutIcon(systemImageName: "house")
        let subscribedFeedItem = UIApplicationShortcutItem(
            type: FeedType.subscribed.rawValue,
            localizedTitle: "Subscribed",
            localizedSubtitle: nil,
            icon: homeIcon,
            userInfo: nil
        )

        // Local Feed
        let officeIcon = UIApplicationShortcutIcon(systemImageName: "building.2")
        let localFeedItem = UIApplicationShortcutItem(
            type: FeedType.local.rawValue,
            localizedTitle: "Local",
            localizedSubtitle: nil,
            icon: officeIcon,
            userInfo: nil
        )

        // All Feed
        let cloudIcon = UIApplicationShortcutIcon(systemImageName: "cloud")
        let allFeedItem = UIApplicationShortcutItem(
            type: FeedType.all.rawValue,
            localizedTitle: "All",
            localizedSubtitle: nil,
            icon: cloudIcon,
            userInfo: nil
        )

        UIApplication.shared.shortcutItems = [
            subscribedFeedItem,
            localFeedItem,
            allFeedItem
        ]
    }
}
