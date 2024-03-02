//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

struct CommunityStub: CommunityStubProviding, Hashable {
    var api: ApiClient
    let actorId: URL
    
    static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
