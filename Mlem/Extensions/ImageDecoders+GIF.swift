//
//  ImageDecoders+GIF.swift
//  Mlem
//
//  Created by tht7 on 02/09/2023.
//

import Foundation
import Nuke
import SwiftyGif
import UIKit

extension ImageDecoders {
    /// The Gif decoder.
    ///
    /// To enable the Gif decoder, register it with a shared registry:
    ///
    /// ```swift
    /// ImageDecoderRegistry.shared.register(ImageDecoders.Gif.init)
    /// ```
    public final class Gif: ImageDecoding, @unchecked Sendable {
        private var isPreviewForGIFGenerated = false
        private let scale: Float?
        public var isAsynchronous: Bool { false }

        private let lock = NSLock()

        public init?(context: ImageDecodingContext) {
            guard let type = AssetType(context.data), type == .gif else { return nil }
            self.scale = (context.request.userInfo[.scaleKey] as? NSNumber)?.floatValue as Float?
        }

        public func decode(_ data: Data) throws -> ImageContainer {
            lock.lock()
            defer { lock.unlock() }
            guard let image = try UIImage(imageData: data) else {
                throw ImageDecodingError.unknown
            }
            guard let imageSource = image.imageSource,
                let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw ImageDecodingError.unknown
            }
            
            return ImageContainer(
                image: image,
                type: .gif,
                data: data,
                userInfo: ["size": CGSize(width: cgImage.width, height: cgImage.height)]
            )
        }

        public func decodePartiallyDownloadedData(_ data: Data) -> ImageContainer? {
            lock.lock()
            defer { lock.unlock() }

            guard let type = AssetType(data), type == .gif else { return nil }
            if !isPreviewForGIFGenerated, let image = try? UIImage(imageData: data) {
                isPreviewForGIFGenerated = true
                return ImageContainer(image: image, type: .gif, isPreview: true, userInfo: [:])
            }
            return nil
        }
    }
}
