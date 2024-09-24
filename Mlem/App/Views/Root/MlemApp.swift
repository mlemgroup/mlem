//
//  MlemApp.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Nuke
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
        ImagePipeline.shared = ImagePipeline(configuration: imageConfig)
        
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
        
        URLCache.shared = Constants.main.urlCache
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
