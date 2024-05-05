//
//  ModlogLink.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

enum ModlogLink: Hashable {
    case userInstance
    case instance(InstanceModel)
    case community(CommunityModel)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .userInstance:
            hasher.combine("userInstance")
        case let .instance(instance):
            hasher.combine("instance")
            hasher.combine(instance)
        case let .community(community):
            hasher.combine("community")
            hasher.combine(community)
        }
    }
}
