//
//  AppDelegate.swift
//  Mlem
//
//  Created by tht7 on 02/07/2023.
//

import Foundation
import SwiftUI

// TODO: we need to do a bit of work to ensure we also switch tab when responding to these
// as currently it launches you into the app, but if the app was already running you're left
// on the tab/screen you were on - despite the shortcuts being designed to take you to the "Feeds" tab
var shortcutItemToProcess: UIApplicationShortcutItem?

@Observable
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
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
    
    // This function lets us do something when the user interacts with a notification
    // like log that they clicked it, or navigate to a specific screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        @AppStorage("notice_test") var notificationTest: Bool = false
        print("Got notification title: ", response.notification.request.content.title)
        notificationTest = true
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
