//
//  NewApiClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension ApiClient {
    func getSite() async throws -> Instance3 {
        let request = GetSiteRequest()
        let response = try await perform(request)
        let model = caches.instance3.getModel(api: self, from: response)
        myInstance = model
        return model
    }
    
    func getMyUser(userStub: UserStub?) async throws -> (user: User?, site: Instance3) {
        let request = GetSiteRequest()
        let response = try await perform(request)
        let site = caches.instance3.getModel(api: self, from: response)
        
        var user: User? = caches.user
        
        if let userStub, let myUser = response.myUser {
            user = .init(
                api: self,
                stub: userStub,
                person3: caches.person3.getModel(api: self, from: myUser),
                instance: site
            )
        }
        myUser = user
        myInstance = site
        return (user: user, site: site)
    }
}
