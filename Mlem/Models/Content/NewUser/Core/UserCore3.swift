//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class UserCore3: CoreModel {
    typealias BaseEquivalent = User3
    static var cache: CoreContentCache<UserCore3> = .init()
    typealias APIType = GetPersonDetailsResponse
    
    var actorId: URL { core2.core1.actorId }
    
    let core2: UserCore2

    var instance: InstanceCore1?
    var moderatedCommunities: [CommunityCore1] = .init()
    
    init(from response: GetPersonDetailsResponse) {
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }

        self.core2 = .create(from: response.personView)
        self.update(with: response, cascade: false)
    }
    
    func update(with response: GetPersonDetailsResponse, cascade: Bool = true) {
        self.moderatedCommunities = response.moderates.map { CommunityCore1.create(from: $0.community) }
        if cascade {
            self.core2.update(with: response.personView)
        }
    }
}
