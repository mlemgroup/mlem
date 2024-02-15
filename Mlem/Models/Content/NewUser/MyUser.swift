//
//  MyUser.swift
//  Mlem
//
//  Created by Sjmarf on 13/02/2024.
//

import Dependencies
import Foundation
import SwiftUI

@Observable
class MyUser: User3Providing, MyUserProviding {
    @ObservationIgnored @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    typealias APIType = SiteResponse
    
    var source: any APISource { stub }
    var user2: User2 { user3.user2 }
    var user1: User1 { user3.user1 }
    
    let stub: MyUserStub
    let user3: User3
    
    let instance: Instance3
    
    init(source: MyUserStub, from response: SiteResponse) {
        self.stub = source
        
        guard let myUser = response.myUser else { fatalError() }
        
        if let existing = source.caches.user3.retrieveModel(id: myUser.localUserView.localUser.id) {
            self.user3 = existing
            existing.update(with: myUser)
        } else {
            self.user3 = .init(source: source, from: response)
        }
    }
    
    var id: Int { user3.id }
}
