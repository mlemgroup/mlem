//
//  NukeWebpBridgeDecoder.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-24.
//

import Foundation
import Nuke
import SDWebImageWebPCoder
import UIKit

/// Custom Nuke decoder that processes the image using SDWebImage. The resulting ImageContainer will have the first frame
/// as image and the decoded webp data as data.
struct NukeWebpBridgeDecoder: ImageDecoding {
    public init?(context: ImageDecodingContext) {
        guard let type = AssetType(context.data), type == .webp else { return nil }
    }
    
    func decode(_ data: Data) throws -> ImageContainer {
        let decoded = SDImageWebPCoder().decodedImage(with: data, options: [.decodeFirstFrameOnly: true])
        
        if let ret = decoded?.cgImage {
            return .init(image: .init(cgImage: ret), type: .webp, data: data)
        } else {
            return .init(image: UIImage.blank)
        }
    }
}
