//
//  NotificationIndicatorView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

import MlemMiddleware
import SwiftUI

struct NotificationIndicatorView: View {
    let entity: any NotificationToggleProviding

    var body: some View {
        if let myPersonId = entity.api.myPerson?.id, entity.api.supports(.toggleNotifications, defaultValue: false) {
            content(myPersonId: myPersonId)
        }
    }

    @ViewBuilder
    func content(myPersonId: Int) -> some View {
        let notificationsEnabled = entity.notificationsEnabled.value ?? false
        let isOwnContent = entity.isOwnContent(myPersonId: myPersonId)
        Group {
            if notificationsEnabled, !isOwnContent {
                Image(icon: .lemmy.notification)
                    .symbolVariant(.fill)
            } else if !notificationsEnabled, isOwnContent {
                Image(icon: .lemmy.notification)
                    .symbolVariant(.slash.fill)
            }
        }
        .imageScale(.small)
        .foregroundStyle(.themedSecondary)
    }
}
