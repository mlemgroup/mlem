//
//  MediaFunctions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-09.
//

import Foundation
import Nuke
import AVFoundation
import UIKit

func retrieveCachedImage(for url: URL?, with processors: [ImageProcessing]) -> MediaType? {
    if let url, let container = ImagePipeline.shared.cache.cachedImage(for: .init(url: url, processors: processors)) {
        return container.animatedMediaType
    }
    return nil
}

func computeProxyBypass(for url: URL?) -> URL? {
    if let url,
       let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let base = components.queryItems?.first(where: { $0.name == "url" })?.value {
        return .init(string: base)
    }
    return nil
}

// // https://stackoverflow.com/a/31314494
// func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
//    let size = image.size
//    
//    let widthRatio  = targetSize.width  / size.width
//    let heightRatio = targetSize.height / size.height
//    
//    // Figure out what our orientation is, and use that to form the rectangle
//    var newSize: CGSize
//    if widthRatio > heightRatio {
//        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//    } else {
//        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
//    }
//    
//    // This is the rect that we've calculated out and this is what is actually used below
//    let rect = CGRect(origin: .zero, size: newSize)
//    
//    // Actually do the resizing to the rect using the ImageContext stuff
//    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//    image.draw(in: rect)
//    let newImage = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    
//    return newImage
// }
