//
//  ApiGetUnreadRegistrationApplicationCountResponse+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-15.
//

import Foundation

extension ApiGetUnreadRegistrationApplicationCountResponse: UnreadCount.DictionaryConvertible {
    var unreadCountDictionary: [InboxItemType: Int] {
        [.registrationApplication: registrationApplications]
    }
}
