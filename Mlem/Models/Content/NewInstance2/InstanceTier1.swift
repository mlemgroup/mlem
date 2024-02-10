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

protocol InstanceTier1Providing: InstanceStubProviding {
    var id: Int { get }
    var displayName: String { get }
    var description: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var creationDate: Date { get }
    var lastRefreshDate: Date { get }
    var publicKey: String { get }
}

@Observable
final class InstanceTier1: InstanceTier1Providing, IndependentContentModel {
    static let cache: IndepenentContentCache<InstanceTier1> = .init()
    var instance: NewInstanceStub { stub }
    typealias APIType = APISite
    
    let stub: NewInstanceStub
    
    var name: String { stub.name }
    var api: NewAPIClient { stub.api }
    var caches: DependentContentCacheGroup { stub.caches }

    let id: Int
    let creationDate: Date
    let publicKey: String

    private(set) var displayName: String
    private(set) var description: String?
    private(set) var avatar: URL?
    private(set) var banner: URL?
    private(set) var lastRefreshDate: Date

    required init(from site: APISite) {
        self.id = site.id
        self.creationDate = site.published
        self.publicKey = site.publicKey

        self.displayName = site.name
        self.description = site.description
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
        self.lastRefreshDate = site.lastRefreshedAt
        
        if var components = URLComponents(string: site.inboxUrl) {
            components.path = ""
            if let name = components.url?.host() {
                self.stub = .create(name: name)
                return
            }
        }
        print("WARNING: Failed to resolve site URL!")
        self.stub = .create(name: "lemmy.world")
    }

    func update(with site: APISite) {
        self.displayName = site.name
        self.description = site.sidebar
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
        self.lastRefreshDate = site.lastRefreshedAt
    }
}
