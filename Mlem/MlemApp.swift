//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import UIKit

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
                    
                    let appearance = UITabBarAppearance()
                    appearance.backgroundEffect = UIBlurEffect.init(style: .systemThinMaterial)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
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
