//
//  CircleCroppedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import MlemMiddleware
import SwiftUI

/// Convenience struct to automatically circle-crop an image. Also applies the given `frame` parameter as a frame to the view.
struct CircleCroppedImageView: View {
    let url: URL?
    let frame: CGFloat // only need one CGFloat because always 1:1 aspect ratio
    let fallback: MediaView.Fallback
    let showProgress: Bool
    let blurred: Bool
    
    init(
        url: URL?,
        frame: CGFloat,
        fallback: MediaView.Fallback,
        showProgress: Bool = true,
        blurred: Bool = false
    ) {
        self.url = url
        self.frame = frame
        self.fallback = fallback
        self.showProgress = showProgress
        self.blurred = blurred
    }
    
    var body: some View {
        MediaView(
            url: url,
            size: .init(width: frame, height: frame),
            controlState: .constant(.init(
                blurred: blurred,
                animating: false,
                overlays: [],
                enableAnimation: false
            )),
            aspectRatioBounds: .absoluteSquare,
            contentMode: .fill,
            fallback: fallback
        )
        .clipShape(Circle())
        .geometryGroup()
        .frame(width: frame, height: frame)
    }
}

// convenience initializers for avatars
extension CircleCroppedImageView {
    init<T: Profile1Providing>(
        _ model: T?,
        frame: CGFloat,
        blurred: Bool = false,
        showProgress: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            frame: frame,
            fallback: T.avatarFallback,
            blurred: blurred
        )
    }

    init(
        _ model: any Profile1Providing,
        frame: CGFloat,
        blurred: Bool = false,
        showProgress: Bool = true
    ) {
        self.init(
            url: model.avatar,
            frame: frame,
            fallback: Swift.type(of: model).avatarFallback,
            blurred: blurred
        )
    }
}
