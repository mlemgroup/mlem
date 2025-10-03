//
//  Notification+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

extension InboxNotification: CacheIdentifiable {
    public var cacheId: Int { id }
}
