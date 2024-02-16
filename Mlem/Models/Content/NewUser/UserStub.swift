//
//  UserStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

struct UserStub: UserStubProviding {
    var source: any APISource
    let actorId: URL
    
    init(source: any APISource, actorId: URL) {
        self.source = source
        self.actorId = actorId
    }
    
    static func == (lhs: UserStub, rhs: UserStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
}

