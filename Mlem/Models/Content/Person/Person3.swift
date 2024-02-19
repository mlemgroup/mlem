//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person3: Person3Providing, NewContentModel {
    typealias APIType = APIGetPersonDetailsResponse
    var person3: Person3 { self }
    
    var source: any APISource

    let person2: Person2

    var instance: Instance1!
    var moderatedCommunities: [Community1] = .init()
    
    init(source: any APISource, from response: APIGetPersonDetailsResponse) {
        self.source = source
        
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        
        self.person2 = source.caches.person2.createModel(source: source, for: response.person_view)
        update(with: response)
    }
    
    init(source: any APISource, from response: APIGetSiteResponse) {
        self.source = source
        
        self.instance = .create(from: response.site_view.site)
        
        guard let myUser = response.my_user else { fatalError() }
        
        if let existing = source.caches.person2.retrieveModel(id: myUser.local_user_view.local_user.id) {
            self.person2 = existing
            existing.update(with: myUser.local_user_view)
        } else {
            self.person2 = .init(source: source, from: myUser.local_user_view)
        }
        
        update(with: myUser)
    }
    
    func update(with response: APIGetPersonDetailsResponse) {
        moderatedCommunities = response.moderates.map { moderatorView in
            source.caches.community1.createModel(source: source, for: moderatorView.community)
        }
        person2.update(with: response.person_view)
    }
    
    func update(with myUser: APIMyUserInfo) {
        moderatedCommunities = myUser.moderates.map { moderatorView in
            source.caches.community1.createModel(source: source, for: moderatorView.community)
        }
        person2.update(with: myUser.local_user_view)
    }
}
