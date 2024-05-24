//
//  ActiveAccount.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

protocol ActiveAccount: ActorIdentifiable, Hashable {
    associatedtype AccountType: Account
    
    var api: ApiClient { get }
    var account: AccountType { get }
    var instance: Instance3? { get }
    
    func deactivate()
}

extension ActiveAccount {
    var api: ApiClient { account.api }
    var actorId: URL { account.actorId }
    var host: String? { actorId.host() }
}
