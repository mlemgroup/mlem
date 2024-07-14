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
        var imageConfig = ImagePipeline.Configuration.withDataCache(name: "main", sizeLimit: AppConstants.cacheSize)
        imageConfig.dataLoadingQueue = OperationQueue(maxConcurrentCount: 8)
        imageConfig.imageDecodingQueue = OperationQueue(maxConcurrentCount: 8) // Let's use those CORES
        imageConfig.imageDecompressingQueue = OperationQueue(maxConcurrentCount: 8)
        
        // TODO: rate limiting
        ImagePipeline.shared = ImagePipeline(configuration: imageConfig)
        
        URLCache.shared = AppConstants.urlCache
    }
    
    var body: some Scene {
        WindowGroup {
            FlowRoot()
        }
    }
}

extension OperationQueue {
    convenience init(maxConcurrentCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentCount
    }
}
