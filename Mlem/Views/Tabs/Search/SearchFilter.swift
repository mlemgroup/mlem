//
//  SearchToken.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import Foundation

enum SearchFilter {
    case community(APICommunityView)
    case user(APIPersonView)
    case subscribed
    case users
    case posts
    case communities
    
    var label: String {
        switch self {
        case .community(let communityView):
            return communityView.community.name
        case .user(let personView):
            return personView.person.name
        case .subscribed:
            return "Subscribed"
        case .users:
            return "Users"
        case .posts:
            return "Posts"
        case .communities:
            return "Communities"
        }
    }
    
    var icon: String {
        switch self {
        case .subscribed:
            return "newspaper.fill"
        case .community, .communities:
            return "house.fill"
        case .user, .users:
            return "person.fill"
        case .posts:
            return "scroll.fill"
        }
    }
}

extension SearchFilter: Hashable, Identifiable, Equatable {
    var id: Self {
        return self
    }
}
