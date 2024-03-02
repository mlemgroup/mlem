//
//  Community1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Community1Providing: CommunityStubProviding, Identifiable {
    var community1: Community1 { get }
    
    var updatedDate: Date? { get }
    var creationDate: Date { get }
    var displayName: String { get }
    var description: String? { get }
    var removed: Bool { get }
    var deleted: Bool { get }
    var nsfw: Bool { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var hidden: Bool { get }
    var onlyModeratorsCanPost: Bool { get }
    var blocked: Bool { get }
}

typealias Community = Community1Providing

extension Community1Providing {
    var actorId: URL { community1.actorId }
    var name: String { community1.name }
    
    var id: Int { community1.id }
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
    var blocked: Bool { community1.blocked }
    
    var id_: Int? { community1.id }
    var creationDate_: Date? { community1.creationDate }
    var updatedDate_: Date? { community1.updatedDate }
    var displayName_: String? { community1.displayName }
    var description_: String? { community1.description }
    var removed_: Bool? { community1.removed }
    var deleted_: Bool? { community1.deleted }
    var nsfw_: Bool? { community1.nsfw }
    var avatar_: URL? { community1.avatar }
    var banner_: URL? { community1.banner }
    var hidden_: Bool? { community1.hidden }
    var onlyModeratorsCanPost_: Bool? { community1.onlyModeratorsCanPost }
    var blocked_: Bool? { community1.blocked }
}

extension Community1Providing {
    // Overwrite the `upgrade()` method from CommunityStubProviding
    func upgrade() async throws -> Community3 {
        try await api.getCommunity(id: id)
    }
    
    func getPosts(
        sort: ApiSortType,
        page: Int = 1,
        cursor: String? = nil,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        try await api.getPosts(
            communityId: id,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            savedOnly: savedOnly
        )
    }
}
