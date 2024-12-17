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
        
        // mp4 handling
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
        
        // webp handling
        ImageDecoderRegistry.shared.register(NukeWebpBridgeDecoder.init)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        
        // caching
        URLCache.shared = Constants.main.urlCache
        
        // set up audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
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
