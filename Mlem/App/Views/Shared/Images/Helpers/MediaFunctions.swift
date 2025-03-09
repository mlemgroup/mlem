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
