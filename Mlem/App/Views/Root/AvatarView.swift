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
                DefaultAvatarView(avatarType: .person)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension AvatarView {
    init(_ userStub: UserStub) {
        self.init(url: userStub.avatarUrl, type: .person)
    }
}
