//
//  UserLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct UserLabelView: View {
    let avatar: URL?
    let showAvatar: Bool
    let username: String?
    let instance: String?
    
    let instanceLocation: InstanceLocation
    
    var spacing: CGFloat
    var avatarSize: CGFloat
    
    init(person: (any Person1Providing)?, showAvatar: Bool, instanceLocation: InstanceLocation) {
        if instanceLocation == .bottom {
            self.spacing = AppConstants.largeAvatarSize
            self.avatarSize = AppConstants.largeAvatarSize
        } else {
            self.spacing = 8
            self.avatarSize = AppConstants.smallAvatarSize
        }
        self.instanceLocation = instanceLocation
        self.showAvatar = showAvatar

        self.avatar = person?.avatar
        
        // TODO: this PR get this from Person1Providing
        self.username = person?.name
        self.instance = person?.actorId.host()
    }
    
    var body: some View {
        HStack {
            if showAvatar {
                AvatarView(url: avatar, type: .person)
                    .frame(width: avatarSize, height: avatarSize)
            }
            
            FullyQualifiedNameView(name: nil, instance: nil, instanceLocation: instanceLocation)
        }
    }
}
