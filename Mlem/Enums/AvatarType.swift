//
//  AvatarType.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation

/// Enum of things that can have avatars
enum AvatarType {
    case user, community
}

extension AvatarType: AssociatedIcon {
    var iconName: String {
        switch self {
        case .user:
            return Icons.user
        case .community:
            return Icons.community
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .user:
            return Icons.userFill
        case .community:
            return Icons.communityFill
        }
    }
}
