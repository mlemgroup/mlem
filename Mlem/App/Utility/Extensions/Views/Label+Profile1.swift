//
//  Label+Profile1.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-11.
//

import MlemMiddleware
import SwiftUI

extension Label {
    init(_ model: ProfileProviding) where Title == Text, Icon == SimpleAvatarView {
        self.init {
            Text(model.name)
        } icon: {
            SimpleAvatarView(url: model.avatar, type: type(of: model).avatarFallback)
        }
    }
}
