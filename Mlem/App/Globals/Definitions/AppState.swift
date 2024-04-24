//
//  AppState.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

@Observable
class AppState {
    var myUser: (any UserProviding)?

    var api: ApiClient
    var actorId: URL? { myUser?.actorId }
    
    func changeUser(to user: UserStub) {
        api = user.api
        myUser = user
    }
    
    func enterGuestMode(with api: ApiClient) {
        self.api = api
        myUser = nil
    }
    
    /// Initializer for a guest mode app state
    /// - Parameters:
    ///   - instance: instance to connect to
    init(api: ApiClient) {
        self.api = api
        self.myUser = nil
    }
    
    /// Initializer for an authenticated app state
    /// - Parameter user: user to connect with
    init(user: UserStub) {
        self.api = user.api
        self.myUser = user
    }
    
    var lemmyVersion: SiteVersion? { api.version ?? myUser?.cachedSiteVersion }
}
