// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).
//
// Source: https://github.com/kean/Nuke/blob/main/Sources/NukeVideo/ImageDecoders%2BVideo.swift
// Adapted to always make a preview image

import Foundation
import AVKit
import AVFoundation
import Nuke

extension ImageDecoders {
    /// The video decoder.
    ///
    /// To enable the video decoder, register it with a shared registry:
    ///
    /// ```swift
    /// ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
    /// ```
    public final class MlemVideo: ImageDecoding, @unchecked Sendable {
        private var didProducePreview = false
        private let type: AssetType
        public var isAsynchronous: Bool { true }

        private let lock = NSLock()

        public init?(context: ImageDecodingContext) {
            guard let type = AssetType(context.data), type.isVideo else { return nil }
            self.type = type
        }

        public func decode(_ data: Data) throws -> ImageContainer {
            ImageContainer(image: makePreview(for: data, type: type) ?? .blank, type: type, data: data, userInfo: [
                .videoAssetKey: AVDataAsset(data: data, type: type)
            ])
        }

        public func decodePartiallyDownloadedData(_ data: Data) -> ImageContainer? {
            lock.lock()
            defer { lock.unlock() }

            guard let type = AssetType(data), type.isVideo else { return nil }
            guard !didProducePreview else {
                return nil // We only need one preview
            }
            guard let preview = makePreview(for: data, type: type) else {
                return nil
            }
            didProducePreview = true
            return ImageContainer(image: preview, type: type, isPreview: true, data: data, userInfo: [
                .videoAssetKey: AVDataAsset(data: data, type: type)
            ])
        }
    }
}

extension ImageContainer.UserInfoKey {
    /// A key for a video asset (`AVAsset`)
    public static let videoAssetKey: ImageContainer.UserInfoKey = "com.github/kean/nuke/video-asset"
}

private func makePreview(for data: Data, type: AssetType) -> PlatformImage? {
    let asset = AVDataAsset(data: data, type: type)
    let generator = AVAssetImageGenerator(asset: asset)
    guard let cgImage = try? generator.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil) else {
        return nil
    }
    return PlatformImage(cgImage: cgImage)
}

extension AssetType {
    /// Returns `true` if the asset represents a video file
    public var isVideo: Bool {
        self == .mp4 || self == .m4v || self == .mov
    }
}

private extension AssetType {
    var avFileType: AVFileType? {
        switch self {
        case .mp4: return .mp4
        case .m4v: return .m4v
        case .mov: return .mov
        default: return nil
        }
    }
}

// This class keeps strong pointer to DataAssetResourceLoader
final class AVDataAsset: AVURLAsset, @unchecked Sendable {
    private let resourceLoaderDelegate: DataAssetResourceLoader

    init(data: Data, type: AssetType?) {
        self.resourceLoaderDelegate = DataAssetResourceLoader(
            data: data,
            contentType: type?.avFileType?.rawValue ?? AVFileType.mp4.rawValue
        )

        // The URL is irrelevant
        let url = URL(string: "in-memory-data://\(UUID().uuidString)") ?? URL(fileURLWithPath: "/dev/null")
        super.init(url: url, options: nil)

        resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global())
    }
}

// This allows LazyImage to play video from memory.
private final class DataAssetResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    private let data: Data
    private let contentType: String

    init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }

    // MARK: - DataAssetResourceLoader

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        if let contentRequest = loadingRequest.contentInformationRequest {
            contentRequest.contentType = contentType
            contentRequest.contentLength = Int64(data.count)
            contentRequest.isByteRangeAccessSupported = true
        }

        if let dataRequest = loadingRequest.dataRequest {
            if dataRequest.requestsAllDataToEndOfResource {
                dataRequest.respond(with: data[dataRequest.requestedOffset...])
            } else {
                let range = dataRequest.requestedOffset..<(dataRequest.requestedOffset + Int64(dataRequest.requestedLength))
                dataRequest.respond(with: data[range])
            }
        }

        loadingRequest.finishLoading()

        return true
    }
}
