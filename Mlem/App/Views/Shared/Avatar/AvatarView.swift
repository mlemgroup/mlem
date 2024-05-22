//
//  AvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import MlemMiddleware
import NukeUI
import SwiftUI

struct AvatarView: View {
    var url: URL?
    var type: AvatarType
    
    var body: some View {
        LazyImage(url: url) { state in
            if let imageContainer = state.imageContainer {
                Image(uiImage: imageContainer.image)
                    .resizable()
                    .clipShape(Circle())
            } else {
                DefaultAvatarView(avatarType: type)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension AvatarView {
    init<T: Profile1Providing>(_ model: T?) {
        self.init(url: model?.avatar, type: T.avatarType)
    }
    
    init(_ model: any Profile1Providing) {
        self.init(url: model.avatar, type: Swift.type(of: model).avatarType)
    }
    
    init(_ model: (any Profile1Providing)?, type: AvatarType) {
        self.init(url: model?.avatar, type: type)
    }
}
