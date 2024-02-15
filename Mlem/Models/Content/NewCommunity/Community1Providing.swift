//
//  Community1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Community1Providing: CommunityStubProviding, ActorIdentifiable, Identifiable {
    var community1: Community1 { get }
    
    var creationDate: Date { get }
    var updatedDate: Date? { get }
    var displayName: String { get }
    var description: String? { get }
    var removed: Bool { get }
    var deleted: Bool { get }
    var nsfw: Bool { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var hidden: Bool { get }
    var onlyModeratorsCanPost: Bool { get }
}

typealias Community = Community1Providing

extension Community1Providing {
    var actorId: URL { community1.actorId }
    var id: Int { community1.id }
    var name: String { community1.name }
    var creationDate: Date { community1.creationDate }
    var updatedDate: Date? { community1.updatedDate }
    var displayName: String { community1.displayName }
    var description: String? { community1.description }
    var removed: Bool { community1.removed }
    var deleted: Bool { community1.deleted }
    var nsfw: Bool { community1.nsfw }
    var avatar: URL? { community1.avatar }
    var banner: URL? { community1.banner }
    var hidden: Bool { community1.hidden }
    var onlyModeratorsCanPost: Bool { community1.onlyModeratorsCanPost }
}

// Overwrite the `upgrade()` method from CommunityStubProviding
extension Community1Providing {
    func upgrade() async throws -> Community3 {
        let response = try await source.api.getCommunity(id: id)
        return source.caches.community3.createModel(source: source, for: response)
    }
}
