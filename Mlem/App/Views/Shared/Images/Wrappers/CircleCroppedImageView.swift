//
//  CircleCroppedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// Convenience struct to automatically circle-crop an image. Also applies the given `size` parameter as a frame to the view.
struct CircleCroppedImageView: View {
    let url: URL?
    let size: CGFloat // only need one CGFloat because always 1:1 aspect ratio
    let fallback: FixedImageView.Fallback
    let showProgress: Bool
    let blurred: Bool
    
    init(
        url: URL?,
        size: CGFloat,
        fallback: FixedImageView.Fallback,
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
        FixedImageView(
            url: url,
            size: .init(width: size, height: size),
            fallback: fallback,
            showProgress: showProgress,
            blurred: blurred
        )
        .clipShape(Circle())
        .geometryGroup()
        .frame(width: size, height: size)
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
