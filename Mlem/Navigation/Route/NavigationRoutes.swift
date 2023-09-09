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
enum NavigationRoute: Hashable {
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
}
