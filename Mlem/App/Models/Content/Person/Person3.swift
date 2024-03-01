//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person3: Person3Providing, ContentModel {
    typealias ApiType = ApiGetPersonDetailsResponse
    var person3: Person3 { self }
    
    var source: ApiClient

    let person2: Person2

    var instance: Instance1!
    var moderatedCommunities: [Community1] = .init()
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    init(source: ApiClient, from response: ApiGetPersonDetailsResponse) {
        self.source = source
        
        if let site = response.site {
            self.instance = .init(source: source, from: site)
        } else {
            self.instance = nil
        }
        
        self.person2 = source.caches.person2.createModel(api: source, for: response.personView)
        update(with: response)
    }
    
    init(source: ApiClient, from response: ApiGetSiteResponse) {
        self.source = source
        
        self.instance = .init(source: source, from: response.siteView.site)
        
        guard let myUser = response.myUser else { fatalError() }
        
        if let existing = source.caches.person2.retrieveModel(cacheId: myUser.localUserView.localUser.id) {
            self.person2 = existing
            existing.update(with: myUser.localUserView)
        } else {
            self.person2 = .init(source: source, from: myUser.localUserView)
        }
        
        update(with: myUser)
    }
    
    func update(with response: ApiGetPersonDetailsResponse) {
        moderatedCommunities = response.moderates.map { moderatorView in
            source.caches.community1.createModel(api: source, for: moderatorView.community)
        }
        person2.update(with: response.personView)
    }
    
    func update(with myUser: ApiMyUserInfo) {
        moderatedCommunities = myUser.moderates.map { moderatorView in
            source.caches.community1.createModel(api: source, for: moderatorView.community)
        }
        person2.update(with: myUser.localUserView)
    }
}
