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
    
    var label: String {
        switch self {
        case .community(let communityView):
            return communityView.community.name
        case .user(let personView):
            return personView.person.name
        case .subscribed:
            return "Subscribed"
        }
    }
    
    var icon: String {
        switch self {
        case .community:
            return "house.fill"
        case .user:
            return "person.fill"
        case .subscribed:
            return "newspaper.fill"
        }
    }
}

extension SearchFilter: Hashable, Identifiable, Equatable {
    var id: Self {
        return self
    }
}
