//
//  AppDelegate.swift
//  Mlem
//
//  Created by tht7 on 02/07/2023.
//

import Foundation
import SwiftUI
import UIKit

// TODO: we need to do a bit of work to ensure we also switch tab when responding to these
// as currently it launches you into the app, but if the app was already running you're left
// on the tab/screen you were on - despite the shortcuts being design to take you to the feeds
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
