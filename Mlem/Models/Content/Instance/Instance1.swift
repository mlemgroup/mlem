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
    typealias APIType = APISite
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

    required init(from site: APISite) {
        self.id = site.id
        self.creationDate = site.published
        self.publicKey = site.publicKey
        self.stub = .createModel(url: site.actorId)
        self.update(with: site)
    }

    func update(with site: APISite) {
        self.displayName = site.name
        self.description = site.sidebar
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
        self.lastRefreshDate = site.lastRefreshedAt
    }
}
