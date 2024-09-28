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

/// Raw values of "ANMF", which we can use to identify whether a webp is animated or not without decoding it
/// https://stackoverflow.com/questions/45190469/how-to-identify-whether-webp-image-is-static-or-animated
let animatedWebpHeader: [UInt8] = [65, 78, 77, 70]

/// Custom Nuke decoder that processes the image using SDWebImage. The resulting ImageContainer will have the following properties:
/// `image`: the first frame of the decoded webp
/// `type`: `.webp`
/// `data`: the raw webp data if the webp is animated, nil otherwise
struct NukeWebpBridgeDecoder: ImageDecoding {
    public init?(context: ImageDecodingContext) {
        guard let type = AssetType(context.data), type == .webp else { return nil }
    }
    
    func decode(_ data: Data) throws -> ImageContainer {
        // decode the first frame to use as thumbnail
        let decoded = SDImageWebPCoder().decodedImage(with: data, options: [.decodeFirstFrameOnly: true])
        
        // use magic numbers to check if animated
        let animated = data.contains(animatedWebpHeader)
        
        if let ret = decoded?.cgImage {
            return .init(image: .init(cgImage: ret), type: .webp, data: animated ? data : nil)
        } else {
            return .init(image: UIImage.blank)
        }
    }
}
