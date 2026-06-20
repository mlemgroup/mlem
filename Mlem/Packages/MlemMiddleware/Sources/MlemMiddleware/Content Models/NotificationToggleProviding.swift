//
//  NotificationToggleProviding.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

import Foundation

public protocol NotificationToggleProviding: OwnershipProviding {
    var notificationsEnabled: ExpectedValue<Bool> { get }

    func updateNotificationsEnabled(_ newValue: Bool)
}

public extension NotificationToggleProviding {
    func toggleNotifications() {
        if let value = notificationsEnabled.value_ {
            updateNotificationsEnabled(!value)
        }
    }
}
