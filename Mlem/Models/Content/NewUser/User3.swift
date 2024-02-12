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
        
        self.user2 = source.caches.user3.createModel(sourceInstance: source, for: response.personView)
        self.update(with: response)
    }
    
    func update(with response: GetPersonDetailsResponse) {
        self.moderatedCommunities = response.moderates.map { moderatorView in
            source.caches.community1.createModel(sourceInstance: source, for: moderatorView.community)
        }
        self.user2.update(with: response.personView)
    }
}
