//
//  InstanceTier1.swift
//  Mlem
//
//  Created by Sjmarf on 09/02/2024.
//

import Foundation
import Observation
import SwiftUI

enum PermissionError: Error {
    case notLoggedIn, notAModerator, notAnAdministrator
}

protocol Instance1Providing: InstanceStubProviding {
    var displayName: String { get }
    var description: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var creationDate: Date { get }
    var publicKey: String { get }
}

@Observable
final class InstanceCore1: CoreModel {
    static let cache: CoreContentCache<InstanceCore1> = .init()
    var instance: NewInstanceStub { stub }
    typealias APIType = APISite
    
    let stub: NewInstanceStub
    
    var actorId: URL { stub.actorId }
    var api: NewAPIClient { stub.api }
    var caches: BaseCacheGroup { stub.caches }

    let creationDate: Date
    let publicKey: String

    var displayName: String
    var description: String?
    var avatar: URL?
    var banner: URL?

    required init(from site: APISite) {
        self.creationDate = site.published
        self.publicKey = site.publicKey

        self.displayName = site.name
        self.description = site.description
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
        
        self.stub = .create(url: site.actorId)
    }

    func update(with site: APISite) {
        self.displayName = site.name
        self.description = site.sidebar
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
    }
}
