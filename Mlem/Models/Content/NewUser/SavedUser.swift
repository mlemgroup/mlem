//
//  NewSavedUser.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import SwiftUI

protocol SavedUserProviding: AuthenticatedAPISource { }

@Observable
final class SavedUserStub: SavedUserProviding {
    let instance: NewInstanceStub
    var caches: BaseCacheGroup { instance.caches }
    let accessToken: String
    
    @ObservationIgnored lazy var api: AuthenticatedAPIClient = {
        return .init(baseUrl: instance.url, token: accessToken)
    }()
    
    init(from account: SavedAccount) {
        var components = URLComponents(url: account.instanceLink, resolvingAgainstBaseURL: false)!
        components.path = ""
        self.instance = .create(url: components.url!)
        self.accessToken = account.accessToken
    }
}
