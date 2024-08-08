//
//  AvatarType.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation

// TODO: move into DefaultAvatarView?
/// Enum of things that can have avatars
enum AvatarType {
    case person, community, instance
}

extension AvatarType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .person:
            return Icons.personCircle
        case .community:
            return Icons.communityCircle
        case .instance:
            return Icons.instanceCircle
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .person:
            return Icons.personCircleFill
        case .community:
            return Icons.communityCircleFill
        case .instance:
            return Icons.instanceCircleFill
        }
    }
}
