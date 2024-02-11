//
//  AuthenticatedUser.swift
//  Mlem
//
//  Created by Sjmarf on 11/02/2024.
//

import SwiftUI

@Observable
class AuthenticatedUser: AuthenticatedUserProviding {
    // Wrapped layers
    let stub: AuthenticatedUserStub
    let core3: UserCore3
    
    // Forwarded properties from AuthenticatedUserStub
    var caches: BaseCacheGroup { stub.caches }
    var instance: NewInstanceStub { stub.instance }
    var api: AuthenticatedAPIClient { stub.api }
    
    // Forwarded properties from UserCore3
    
    init(stub: AuthenticatedUserStub, user: UserCore3) {
        self.stub = stub
        self.core3 = user
    }
}
