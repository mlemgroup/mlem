//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class User3: User3Providing, NewContentModel {
    typealias APIType = GetPersonDetailsResponse
    var user3: User3 { self }
    var user1: User1 { user2.user1 }
    
    var source: any APISource

    let user2: User2

    var instance: Instance1!
    var moderatedCommunities: [Community1] = .init()
    
    init(source: any APISource, from response: GetPersonDetailsResponse) {
        self.source = source
        
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        
        self.user2 = source.caches.user2.createModel(source: source, for: response.personView)
        self.update(with: response)
    }
    
    init(source: any APISource, from response: SiteResponse) {
        self.source = source
        
        self.instance = .create(from: response.siteView.site)
        
        guard let myUser = response.myUser else { fatalError() }
        
        if let existing = source.caches.user2.retrieveModel(id: myUser.localUserView.localUser.id) {
            self.user2 = existing
            existing.update(with: myUser.localUserView)
        } else {
            self.user2 = .init(source: source, from: myUser.localUserView)
        }
        
        self.update(with: myUser)
    }
    
    func update(with response: GetPersonDetailsResponse) {
        self.moderatedCommunities = response.moderates.map { moderatorView in
            source.caches.community1.createModel(source: source, for: moderatorView.community)
        }
        self.user2.update(with: response.personView)
    }
    
    func update(with myUser: APIMyUserInfo) {
        self.moderatedCommunities = myUser.moderates.map { moderatorView in
            source.caches.community1.createModel(source: source, for: moderatorView.community)
        }
        self.user2.update(with: myUser.localUserView)
    }
}
