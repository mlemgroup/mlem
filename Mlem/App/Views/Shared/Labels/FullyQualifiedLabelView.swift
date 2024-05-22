//
//  FullyQualifiedLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// View for rendering fully qualified labels (i.e., user or community names)
struct FullyQualifiedLabelView: View {
    let avatar: URL?
    let showAvatar: Bool
    let name: String?
    let instance: String?
    let instanceLocation: InstanceLocation
    
    var spacing: CGFloat
    var avatarSize: CGFloat
    
    // TODO: future handle flairs. These require post, comment, and community context; to avoid the "bucket brigade" anti-pattern, those should be made available as @Environment properties
    
    init(entity: (any CommunityOrPersonStub & ProfileProviding)?, showAvatar: Bool, instanceLocation: InstanceLocation) {
        if instanceLocation == .bottom {
            self.spacing = AppConstants.largeAvatarSize
            self.avatarSize = AppConstants.largeAvatarSize
        } else {
            self.spacing = 8
            self.avatarSize = AppConstants.smallAvatarSize
        }
        self.instanceLocation = instanceLocation
        self.showAvatar = showAvatar

        self.avatar = entity?.avatar
        
        self.name = entity?.name
        self.instance = entity?.host
    }
    
    var body: some View {
        HStack {
            if showAvatar {
                AvatarView(url: avatar, type: .person)
                    .frame(width: avatarSize, height: avatarSize)
            }
            
            FullyQualifiedNameView(name: name, instance: instance, instanceLocation: instanceLocation)
        }
    }
}
