//
//  MlemApp.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Nuke
import SDWebImageWebPCoder
import SwiftUI

/// Root view for the app
@main
struct MlemApp: App {
    init() {
        var imageConfig = ImagePipeline.Configuration.withDataCache(name: "main", sizeLimit: Constants.main.cacheSize)
        imageConfig.dataLoadingQueue = OperationQueue(maxConcurrentCount: 8)
        imageConfig.imageDecodingQueue = OperationQueue(maxConcurrentCount: 8) // Let's use those CORES
        imageConfig.imageDecompressingQueue = OperationQueue(maxConcurrentCount: 8)
        
        // TODO: rate limiting
        // set up Nuke
        ImagePipeline.shared = ImagePipeline(configuration: imageConfig)
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
        URLCache.shared = Constants.main.urlCache
        
        // set up SDWebImage
//        let cache = SDImageCache(namespace: "tiny")
//        cache.config.maxMemoryCost = 100 * 1024 * 1024 // 500MB memory
//        cache.config.maxDiskSize = 500 * 1024 * 1024 // 500MB disk
//        SDImageCachesManager.shared.addCache(cache)
//        SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
//
//        let WebPCoder = SDImageWebPCoder.shared
//        SDImageCodersManager.shared.addCoder(WebPCoder)
//        SDImageCodersManager.shared.addCoder(SDImageGIFCoder.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension OperationQueue {
    convenience init(maxConcurrentCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentCount
    }
}
