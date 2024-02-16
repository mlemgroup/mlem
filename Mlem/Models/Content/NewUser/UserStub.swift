//
//  UserStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Dependencies
import SwiftUI

struct UserStub: UserStubProviding, Hashable {
    var source: any APISource
    let actorId: URL
    
    init(source: any APISource, actorId: URL) {
        self.source = source
        self.actorId = actorId
    }
    
    static func == (lhs: UserStub, rhs: UserStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
}

