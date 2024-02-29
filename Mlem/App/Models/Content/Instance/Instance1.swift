//
//  InstanceTier1.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance1: Instance1Providing, CoreModel {
    static var cache: CoreContentCache<Instance1> = .init()
    typealias ApiType = ApiSite
    var instance1: Instance1 { self }
    
    let stub: InstanceStub
    
    let id: Int
    let creationDate: Date
    let publicKey: String
    
    var displayName: String = ""
    var description: String?
    var avatar: URL?
    var banner: URL?
    var lastRefreshDate: Date = .distantPast
    
    required init(from site: ApiSite) {
        self.id = site.id
        self.creationDate = site.published
        self.publicKey = site.publicKey
        self.stub = .createModel(url: site.actorId)
        update(with: site)
    }
    
    func update(with site: ApiSite) {
        displayName = site.name
        description = site.sidebar
        avatar = site.icon
        banner = site.banner
        lastRefreshDate = site.lastRefreshedAt
    }
}
