//
//  UserStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

struct PersonStub: PersonStubProviding {
    var source: any ApiSource
    let actorId: URL
    
    static func == (lhs: PersonStub, rhs: PersonStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
