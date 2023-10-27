//
//  InboxTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-26.
//

import Foundation

class InboxTracker: ParentTracker<InboxItem> {
    func filterUser(id: Int) async {
        await filter { item in
            item.creatorId != id
        }
    }
}
