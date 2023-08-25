//
//  AppDelegate.swift
//  Mlem
//
//  Created by tht7 on 02/07/2023.
//

import Foundation
import SwiftUI
import UIKit

var shortcutItemToProcess: UIApplicationShortcutItem?

class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    )
        -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }

        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self

        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        shortcutItemToProcess = shortcutItem
    }
}
