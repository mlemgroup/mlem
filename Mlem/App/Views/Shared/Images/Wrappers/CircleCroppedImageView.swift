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
    let size: CGFloat // only need one CGFloat because always 1:1 aspect ratio
    let fallback: PreprocessedFixedImageView.Fallback
    let showProgress: Bool
    let blurred: Bool
    
    init(
        url: URL?,
        size: CGFloat,
        fallback: PreprocessedFixedImageView.Fallback,
        showProgress: Bool = true,
        blurred: Bool = false
    ) {
        self.url = url
        self.size = size
        self.fallback = fallback
        self.showProgress = showProgress
        self.blurred = blurred
    }
    
    var body: some View {
        PreprocessedFixedImageView(
            url: url,
            size: .init(width: size, height: size),
            fallback: fallback,
            showProgress: showProgress,
            blurred: blurred
        )
        .clipShape(Circle())
        .geometryGroup()
    }
}

// convenience initializers for avatars
extension CircleCroppedImageView {
    init<T: Profile1Providing>(
        _ model: T?,
        size: CGFloat,
        showProgress: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            size: size,
            fallback: T.avatarFallback
        )
    }

    init(
        _ model: any Profile1Providing,
        size: CGFloat,
        showProgress: Bool = true
    ) {
        self.init(
            url: model.avatar,
            size: size,
            fallback: Swift.type(of: model).avatarFallback
        )
    }
}
