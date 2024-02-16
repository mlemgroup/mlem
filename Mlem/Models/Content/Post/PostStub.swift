//
//  PostStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

struct PostStub: PostStubProviding {
    var source: any APISource
    let actorId: URL
    
    init(source: any APISource, actorId: URL) {
        self.source = source
        self.actorId = actorId
    }
    
    static func == (lhs: PostStub, rhs: PostStub) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
