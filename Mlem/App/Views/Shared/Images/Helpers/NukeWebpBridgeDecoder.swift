//
//  NukeWebpBridgeDecoder.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-24.
//

import Foundation
import Nuke
import SDWebImageSwiftUI
import SDWebImageWebPCoder
import UIKit

/// Custom Nuke decoder that processes the image using SDWebImage. The resulting ImageContainer will have the following properties:
/// `image`: the first frame of the decoded webp
/// `type`: `.webp`
/// `data`: the raw webp data if the webp is animated, nil otherwise
struct NukeWebpBridgeDecoder: ImageDecoding {
    public init?(context: ImageDecodingContext) {
        guard
            let type = AssetType(context.data),
            type == .webp,
            context.data.isAnimatedWebp() // only use this for animated webp, fall back on Nuke default for non-animated
        else { return nil }
    }
    
    func decode(_ data: Data) throws -> ImageContainer {
        // decode the first frame to use as thumbnail
        let decoded = SDImageWebPCoder().decodedImage(with: data, options: [.decodeFirstFrameOnly: true])
        
        if let ret = decoded?.cgImage {
            return .init(image: .init(cgImage: ret), type: .webp, data: data)
        } else {
            return .init(image: UIImage.blank)
        }
    }
}

/// Raw values of "ANIM", which we can use to identify whether a webp is animated or not without decoding it
/// https://stackoverflow.com/questions/45190469/how-to-identify-whether-webp-image-is-static-or-animated
private let animHeader: Data = Data([65, 78, 73, 77])

private extension Data {
    /// If the given data is a webp, returns true if that webp is animated and false otherwise.
    /// - Warning: This function's behavior is undefined if the provided data is not an animated webp
    func isAnimatedWebp() -> Bool {
        // This function is built to run fast, banking on the fact that it's being passed in after Nuke checks that
        // the image is a webp to guarantee safety. The check itself therefore only targets the bytes that, if the
        // data is a webp, indicate an animated webp; it is assumed that the data is long enough and correctly formatted.
        
        // Sanity checks that the data conforms to the webp spec
        assert(self.count >= 33, "Invalid data (too short)")
        assert(self[..<4] == Data([82, 73, 70, 70]), "Invalid data (no RIFF header)")
        assert(self[8..<12] == Data([87, 69, 66, 80]), "Invalid data (no WEBP header)")
        assert(self[12..<15] == Data([86, 80, 56]), "Invalid data (no VP8X header)")
        
        return self[30..<34] == animHeader
    }
}
