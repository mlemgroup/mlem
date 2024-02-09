//
//  InstanceTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

protocol InstanceTier1Providing: InstanceStubProviding {
    var id: Int { get }
    var displayName: String { get }
    var description: String { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var creationDate: Date { get }
    var lastRefreshDate: Date { get }
    var publicKey: String { get }
}

@Observable
final class InstanceTier1: InstanceTier1Providing, NewContentModel {
    // NewContentModel conformance
    typealias APIType = APISite
    
    let stub: InstanceStub
    var name: String { stub.name }
    var apiClient: APIClient { stub.apiClient }

    let id: Int
    let creationDate: Date
    
    private(set) var displayName: String
    private(set) var description: String
    private(set) var avatar: URL?
    private(set) var banner: URL?
    private(set) var lastRefreshDate: Date
    private(set) var publicKey: String

    required init(domainName: String, from site: APISite) {
        self.id = site.id
        self.name = domainName
        self.creationDate = site.published

        self.displayName = site.name
        self.description = site.description
        self.avatar = site.avatar
        self.banner = site.banner
        self.lastRefreshDate = site.lastRefreshedAt
        self.publicKey = site.publicKey
    }

    func update(with site: APISite) {
        self.displayName = site.displayName
        self.description = site.description
        self.avatar = site.iconUrl
        self.banner = site.bannerUrl
        self.lastRefreshDate = site.lastRefreshedAt
        self.publicKey = site.publicKey
    }
}