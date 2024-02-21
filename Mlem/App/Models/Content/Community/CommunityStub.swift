//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

struct CommunityStub: CommunityStubProviding, Hashable {
    var source: any ApiSource
    let actorId: URL
    
    static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
