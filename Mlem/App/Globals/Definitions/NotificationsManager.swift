//
//  NotificationsManager.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-06-25.
//

import UserNotifications

/// Class to group notification-related logic, though all methods on this are static
public class NotificationsManager {
    /// Requests required permissions to display notifications. Should be run at launch; running multiple times will not cause the popup to appear more than once.Ï
    static func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
            if let error {
                handleError(error)
            }
        }
    }
}
