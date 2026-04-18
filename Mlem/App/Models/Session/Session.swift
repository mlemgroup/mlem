//
//  Session.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

protocol Session: ActorIdentifiable, Hashable {
    associatedtype AccountType: Account
    
    var api: ApiClient { get }
    var account: AccountType { get }
    var instance: Instance? { get }
    
    func deactivate()
}

extension Session {
    var api: ApiClient { account.api }
    var actorId: ActorIdentifier { account.actorId }
}
