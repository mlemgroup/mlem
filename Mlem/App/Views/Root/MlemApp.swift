//
//  MlemApp.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import AVFAudio
import Nuke
import SDWebImageWebPCoder
import SwiftUI
import Media

/// Root view for the app
@main
struct MlemApp: App {
    init() {
        var imageConfig = ImagePipeline.Configuration.withDataCache(name: "main", sizeLimit: Constants.main.cacheSize)
        imageConfig.dataLoadingQueue = OperationQueue(maxConcurrentCount: 8)
        imageConfig.imageDecodingQueue = OperationQueue(maxConcurrentCount: 8) // Let's use those CORES
        imageConfig.imageDecompressingQueue = OperationQueue(maxConcurrentCount: 8)
        imageConfig.dataLoader = NukeRewriteDataLoader()
        
        // TODO: rate limiting
        ImagePipeline.shared = ImagePipeline(configuration: imageConfig)
        
        // video handling
        ImageDecoderRegistry.shared.register(MlemVideoDecoder.init)
        
        // webp handling
        ImageDecoderRegistry.shared.register(NukeWebpBridgeDecoder.init)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        
        // caching
        URLCache.shared = Constants.main.urlCache
        
        // set up audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        } catch {
            handleError(error)
        }
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
