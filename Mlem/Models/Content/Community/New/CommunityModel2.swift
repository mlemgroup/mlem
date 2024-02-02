//
//  CommunityModel2.swift
//  Mlem
//
//  Created by Sjmarf on 02/02/2024.
//

import Dependencies
import SwiftUI
import Observation

enum SubscriptionStatus {
    case unsubscribed, subscribed, favorited
}

@Observable
final class CommunityModel2 {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    
    // MARK: - Unsettable properties
    
    let community1: CommunityModel1

    private(set) var subscriberCount: Int
    private(set) var postCount: Int
    private(set) var commentCount: Int
    private(set) var activeUserCount: ActiveUserCount

    // MARK: - Settable properties

    private var _subscribed: Bool
    var subscribed: Bool {
        get { _subscribed }
        set async throws { newValue in 
            if newValue != _subscribed {
                _subscribed = newValue
                do {
                    let response = try await apiClient.followCommunity(id: communityId, shouldFollow: newValue)
                    update(with: response.communityView)
                } catch {
                    _subscribed = !newValue
                    throw error
                }
            }
        }
    }

    private var _blocked: Bool
    var blocked: Bool {
        get { _blocked }
        set async throws { newValue in
            if newValue != _blocked {
                _blocked = newValue
                do {
                    let response = try await apiClient.blockCommunity(id: communityId, shouldBlock: newValue)
                    update(with: response.communityView)
                } catch {
                    _blocked = !newValue
                    throw error
                }
            }
        }
    }
}

extension CommunityModel2: CommunityModelProto {
    var communityId: Int { community1.communityId }
    var creationDate: Date { community1.creationDate }
    var actorId: URL { community1.actorId }
    var local: Bool { community1.local }

    var updatedDate: Date { community1.updatedDate }

    var name: String { community1.name }
    var displayName: String { community1.displayName }
    var removed: Bool { community1.removed }
    var deleted: Bool { community1.deleted }
    var nsfw: Bool { community1.nsfw }
    var avatarURL: URL? { community1.avatarURL }
    var bannerURL: URL? { community1.bannerURL }
    var onlyModeratorsCanPost: Bool { community1.onlyModeratorsCanPost }
    var hidden: Bool { community1.hidden }

    var fullyQualifiedName: String? { community1.fullyQualifiedName }
    func copyFullyQualifiedName() { community1.copyFullyQualifiedName() }

    func menuFunctions(editorTracker: EditorTracker?) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        functions.append(contentsOf: community1.menuFunctions(editorTracker: editorTracker))
        return functions
    }
}

extension CommunityModel2: NewContentModel {
    static var cache: ContentCache<CommunityModel2> = .init()
    typealias APIType = APICommunityView

    required init(from communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscriberCount
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )

        _subscribed = communityView.subscribed
        blocked = communityView.blocked

        community1 = CommunityModel1.cache.createModel(for: communityView.community)
    }

    func update(with communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscriberCount
        postCount = communityView.counts.postCount
        commentCount = communityView.counts.commentCount
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )

        _subscribed = communityView.subscribed
        blocked = communityView.blocked
    }
}