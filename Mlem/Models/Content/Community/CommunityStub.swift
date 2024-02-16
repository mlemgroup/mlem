//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

struct CommunityStub: CommunityStubProviding, Hashable {
    var source: any APISource
    let actorId: URL
    
    init(source: any APISource, actorId: URL) {
        self.source = source
        self.actorId = actorId
    }
    
    static func == (lhs: CommunityStub, rhs: CommunityStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
