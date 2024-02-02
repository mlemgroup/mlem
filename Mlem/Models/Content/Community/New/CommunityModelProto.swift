//
//  CommunityModelProto.swift
//  Mlem
//
//  Created by Sjmarf on 02/02/2024.
//

// TODO: Rename to "CommunityModel" once the previous CommunityModel is removed?
protocol CommunityModelProto: AnyObject {
    var communityId: Int { get }
    var creationDate: Date { get }
    var actorId: URL { get }
    var local: Bool { get }

    var updatedDate: Date { get }

    var name: String { get }
    var displayName: String { get }
    var removed: Bool { get }
    var deleted: Bool { get }
    var nsfw: Bool { get }
    var avatarURL: URL? { get }
    var bannerURL: URL? { get }
    var onlyModeratorsCanPost: Bool { get }
    var hidden: Bool { get }
}
