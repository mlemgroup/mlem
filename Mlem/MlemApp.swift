//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

@main
struct MlemApp: App {
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified

    @StateObject var accountsTracker: SavedAccountTracker = .init()

    var body: some Scene {
        WindowGroup {
            Window()
                .environmentObject(accountsTracker)
                .onAppear {
                    URLCache.shared = AppConstants.urlCache
                    // set app theme to user preference
                    let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.windows.first?.overrideUserInterfaceStyle = lightOrDarkMode
                    
                    // correct the transparency bug for Tab bars
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithOpaqueBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    // correct the transparency bug for Navigation bars
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.configureWithOpaqueBackground()
                    UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
                }
        }
        .onChange(of: accountsTracker.savedAccounts) { _ in
            accountsTracker.saveToDisk()
        }
        .onChange(of: lightOrDarkMode, perform: { value in
            let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.overrideUserInterfaceStyle = value
        })
        
    }
}
