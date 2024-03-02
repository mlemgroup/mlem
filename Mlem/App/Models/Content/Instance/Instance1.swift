//
//  InstanceTier1.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance1: Instance1Providing, ContentModel {
    typealias ApiType = ApiSite
    
    var api: ApiClient
    var instance1: Instance1 { self }
    
    let id: Int
    let creationDate: Date
    let publicKey: String
    
    var displayName: String = ""
    var description: String?
    var avatar: URL?
    var banner: URL?
    var lastRefreshDate: Date = .distantPast
    
    // Instance and ApiClient share equatability properties--two instances are different iff they are different servers and being connected to using a different user. This makes intuitive sense given that instance is the source of things like post feeds, which can vary depending on the calling user (even instance-generics like All and Local will produce varying responses for different calling users, e.g., return an upvoted or neutral post)
    var cacheId: Int { api.cacheId }
    var actorId: URL { api.actorId }
    
    init(
        api: ApiClient,
        id: Int,
        creationDate: Date,
        publicKey: String,
        displayName: String = "",
        description: String? = nil,
        avatar: URL? = nil,
        banner: URL? = nil,
        lastRefreshDate: Date = .distantPast
    ) {
        self.api = api
        self.id = id
        self.creationDate = creationDate
        self.publicKey = publicKey
        self.displayName = displayName
        self.description = description
        self.avatar = avatar
        self.banner = banner
        self.lastRefreshDate = lastRefreshDate
    }
    
    func update(with site: ApiSite) {
        displayName = site.name
        description = site.sidebar
        avatar = site.icon
        banner = site.banner
        lastRefreshDate = site.lastRefreshedAt
    }
}
