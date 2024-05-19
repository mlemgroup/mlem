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
    let url: URL?
    let type: AvatarType
    var showLoadingPlaceholder: Bool = true
    
    var body: some View {
        LazyImage(url: url) { state in
            // Using an `if` statement to conditionally show the `Image` doesn't play well with SwiftUI animations/transitions, so do this instead
            Image(uiImage: state.imageContainer?.image ?? .init())
                .resizable()
                .clipShape(Circle())
                .background {
                    if url == nil || (showLoadingPlaceholder && state.isLoading) {
                        DefaultAvatarView(avatarType: type)
                    }
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension AvatarView {
    init<T: ProfileProviding>(
        _ model: T?,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            type: T.avatarType,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }

    init(
        _ model: any ProfileProviding,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: model.avatar,
            type: Swift.type(of: model).avatarType,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }
    
    init(
        _ model: (any ProfileProviding)?,
        type: AvatarType,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            type: type,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }
    
    init(
        _ userStub: UserStub?,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: userStub?.avatarUrl,
            type: .person,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }
}
