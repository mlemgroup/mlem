//
//  Community.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation

struct Community: Identifiable, Codable, Equatable, Hashable {
    let id: Int

    let name: String
    let title: String?
    let description: String?
    let icon: URL?
    let banner: URL?

    let createdAt: String?
    let updatedAt: String?

    let actorID: URL

    let local: Bool

    let deleted: Bool
    let nsfw: Bool

    var details: CommunityDetails?
}

struct CommunityDetails: Codable, Equatable, Hashable {
    var isSubscribed: Bool

    let numberOfSubscribers: Int
    let numberOfPosts: Int
    let numberOfActiveUsersOverall: Int?

    let moderators: [User]
}
