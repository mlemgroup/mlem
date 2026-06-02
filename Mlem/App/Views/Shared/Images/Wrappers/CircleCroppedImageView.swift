//
//  CircleCroppedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-02.
//

import Foundation
import MlemMiddleware
import SwiftUI
import Media

/// Convenience struct to automatically circle-crop an image. Also applies the given `frame` parameter as a frame to the view.
struct CircleCroppedImageView: View {
    @Environment(MediaTracker.self) var mediaTracker
    
    let url: URL?
    let frame: CGFloat // only need one CGFloat because always 1:1 aspect ratio
    let fallback: MediaView.Fallback
    let showProgress: Bool
    let blurred: Bool
    let enableAnimation: Bool
    
    /// Creates an image from the given URL cropped into a circle
    /// - Parameters:
    ///   - url: URL of the image to render
    ///   - frame: frame to crop the image into
    ///   - fallback: fallback image
    ///   - showProgress: true if the progress spinner should be displayed, false otherwise. Defaults to true.
    ///   - blurred: true if the image should be blurred, false otherwise. Defaults to false.
    ///   - enableAnimation: true if the image should animate, false if it should not.
    ///     If unspecified, will only animate if the animated avatars settings is `.always`
    init(
        url: URL?,
        frame: CGFloat,
        fallback: MediaView.Fallback,
        showProgress: Bool = true,
        blurred: Bool = false,
        enableAnimation: Bool = (Settings.get(\.media_animatedAvatars) == .always)
    ) {
        self.url = url
        self.frame = frame
        self.fallback = fallback
        self.showProgress = showProgress
        self.blurred = blurred
        self.enableAnimation = enableAnimation
    }
    
    var body: some View {
        MediaView(
            size: .init(width: frame, height: frame),
            controlState: mediaTracker.controlState(for: url) { .init(
                url: url,
                blurred: blurred,
                animating: enableAnimation,
                muted: Settings.get(\.behavior_muteVideos)
            )},
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
    init<T: ProfileProviding>(
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
        _ model: any ProfileProviding,
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
