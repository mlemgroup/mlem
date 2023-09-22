//
//  NavigationRoutes.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation

/// Possible routes for navigation links in `Mlem.app`.
///
/// See `SettingsRoutes` for settings-related routes.
enum NavigationRoute: Routable {
    case apiCommunityView(APICommunityView)
    case apiCommunity(APICommunity)
    
    case communityLinkWithContext(CommunityLinkWithContext)
    case communitySidebarLinkWithContext(CommunitySidebarLinkWithContext)
    
    case apiPostView(APIPostView)
    case apiPost(APIPost)
    
    case apiPerson(APIPerson)
    
    case postLinkWithContext(PostLinkWithContext)
    case lazyLoadPostLinkWithContext(LazyLoadPostLinkWithContext)
    case userModeratorLink(UserModeratorLink)
    
    // swiftlint:disable cyclomatic_complexity
    static func makeRoute<V>(_ value: V) -> NavigationRoute where V: Hashable {
        switch value {
        case let value as APICommunityView:
            return .apiCommunityView(value)
        case let value as APICommunity:
            return .apiCommunity(value)
        case let value as CommunityLinkWithContext:
            return .communityLinkWithContext(value)
        case let value as CommunitySidebarLinkWithContext:
            return .communitySidebarLinkWithContext(value)
        case let value as APIPostView:
            return .apiPostView(value)
        case let value as APIPost:
            return .apiPost(value)
        case let value as APIPerson:
            return .apiPerson(value)
        case let value as PostLinkWithContext:
            return .postLinkWithContext(value)
        case let value as LazyLoadPostLinkWithContext:
            return .lazyLoadPostLinkWithContext(value)
        case let value as UserModeratorLink:
            return .userModeratorLink(value)
        default:
            fatalError(Self.makeRouteErrorString)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
