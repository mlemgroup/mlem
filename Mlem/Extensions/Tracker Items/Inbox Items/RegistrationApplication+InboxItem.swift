//
//  RegistrationApplication+InboxItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Foundation

extension RegistrationApplicationModel: InboxItem {
    var published: Date { application.published }
    
    var creatorId: Int { creator.userId }
    
    var banStatusCreatorId: Int { creator.userId }
    
    var creatorBannedFromInstance: Bool { false }
    
    var creatorBannedFromCommunity: Bool { false }
    
    var read: Bool { resolver != nil }
    
    var id: Int { application.id }
    
    func toAnyInboxItem() -> AnyInboxItem { .registrationApplication(self) }
    
    func setCreatorBannedFromCommunity(_ newBanned: Bool) {
        // noop
    }
    
    func setCreatorBannedFromInstance(_ newBanned: Bool) {
        // noop
    }
}
