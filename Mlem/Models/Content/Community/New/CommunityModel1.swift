//
//  CommunityModel1.swift
//  Mlem
//
//  Created by Sjmarf on 02/02/2024.
//

import Dependencies
import SwiftUI
import Observation

@Observable
final class CommunityModel1: CommunityModelProto {
    
    // MARK: - Unsettable properties
    let communityId: Int
    let creationDate: Date
    let actorId: URL
    let local: Bool

    private(set) var updatedDate: Date?

    // MARK: - Settable properties
    
    private(set) var name: String
    private(set) var displayName: String
    private(set) var removed: Bool
    private(set) var deleted: Bool
    private(set) var nsfw: Bool
    private(set) var avatarURL: URL?
    private(set) var bannerURL: URL?
    private(set) var onlyModeratorsCanPost: Bool
    private(set) var hidden: Bool

    var fullyQualifiedName: String? {
        if let host = communityUrl.host() {
            return "\(name!)@\(host)"
        }
        return nil
    }
    
    func copyFullyQualifiedName() {
        let pasteboard = UIPasteboard.general
        if let fullyQualifiedName {
            pasteboard.string = "!\(fullyQualifiedName)"
            Task { await notifier.add(.success("Community Name Copied")) }
        } else {
            Task { await notifier.add(.failure("Failed to copy")) }
        }
    }

    func menuFunctions(editorTracker: EditorTracker?) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        
        functions.append(
            .standardMenuFunction(
                text: "Copy Name",
                imageName: Icons.copy,
                destructiveActionPrompt: nil,
                enabled: true,
                callback: copyFullyQualifiedName
            )
        )
        functions.append(.shareMenuFunction(url: communityUrl))

        return functions
    }
}

extension CommunityModel1: NewContentModel {
    static var cache: ContentCache<CommunityModel1> = .init()
    typealias APIType = APICommunity

    required init(from community: APICommunity) {
        communityId = community.id
        creationDate = community.published
        actorId = community.actorId
        local = community.local

        updatedDate = community.updatedDate
        
        name = community.name
        displayName = community.displayName
        removed = community.removed
        deleted = community.deleted
        nsfw = community.nsfw
        avatarURL = community.avatarURL
        bannerURL = community.bannerURL
        onlyModeratorsCanPost = community.postingRestrictedToMods
        hidden = community.hidden
    }

    func update(with community: APICommunity) {
        updatedDate = community.updatedDate
        
        name = community.name
        displayName = community.displayName
        removed = community.removed
        deleted = community.deleted
        nsfw = community.nsfw
        avatarURL = community.avatarURL
        bannerURL = community.bannerURL
        onlyModeratorsCanPost = community.postingRestrictedToMods
        hidden = community.hidden
    }
}