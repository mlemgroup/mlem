//
//  CircleCroppedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct CircleCroppedImageView: View {
    let url: URL?
    let fallback: FixedImageView.Fallback
    let showProgress: Bool
    
    init(url: URL?, fallback: FixedImageView.Fallback, showProgress: Bool = true) {
        self.url = url
        self.fallback = fallback
        self.showProgress = showProgress
    }
    
    var body: some View {
        FixedImageView(url: url, fallback: fallback, showProgress: showProgress)
            .clipShape(Circle())
    }
}

// convenience initializers for avatars
extension CircleCroppedImageView {
    init<T: Profile1Providing>(
        _ model: T?,
        showProgress: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            fallback: T.avatarFallback
        )
    }

    init(
        _ model: any Profile1Providing,
        showProgress: Bool = true
    ) {
        self.init(
            url: model.avatar,
            fallback: Swift.type(of: model).avatarFallback
        )
    }
}
