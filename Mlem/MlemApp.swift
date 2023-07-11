//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import UIKit
import SDWebImage
import SDWebImageSwiftUI

@main
struct MlemApp: App {
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified

    @StateObject var accountsTracker: SavedAccountTracker = .init()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Window()
                .environmentObject(accountsTracker)
                .onAppear {
                    SDImageCodersManager.shared.addCoder(SDImageGIFCoder.shared)
                    
                    // Add multiple caches
                    let cache = SDImageCache(namespace: "tiny")
                    cache.config.maxMemoryCost = UInt(AppConstants.cacheSize)
                    cache.config.maxDiskSize = UInt(AppConstants.cacheSize)
                    SDImageCachesManager.shared.addCache(cache)
                    SDImageCachesManager.shared.storeOperationPolicy = .concurrent
                    SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
                    SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
                    
                    URLCache.shared = AppConstants.urlCache
                    
                    setupAppShortcuts()
                    
                    // set app theme to user preference
                    let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.windows.first?.overrideUserInterfaceStyle = lightOrDarkMode
                    
                    let appearance = UITabBarAppearance()
                    appearance.backgroundEffect = UIBlurEffect.init(style: .systemThinMaterial)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
        }
        .onChange(of: accountsTracker.savedAccounts) { _ in
            accountsTracker.saveToDisk()
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
