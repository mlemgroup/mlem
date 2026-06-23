//
//  File.swift
//  Media
//
//  Created by Sjmarf on 2026-06-19.
//  

import Foundation
import Nuke

extension ImagePipeline {
    @discardableResult
    public func data(url: URL) async throws -> (Data, URLResponse?) {
        try await data(for: ImageRequest(url: url))
    }
}

extension ImagePipeline.Configuration {
    public static func mlem(sizeLimit: Int) -> Self {
        var config = ImagePipeline.Configuration.withDataCache(name: "main", sizeLimit: sizeLimit)
        config.dataLoadingQueue = OperationQueue(maxConcurrentCount: 8)
        config.imageDecodingQueue = OperationQueue(maxConcurrentCount: 8) // Let's use those CORES
        config.imageDecompressingQueue = OperationQueue(maxConcurrentCount: 8)
        config.dataLoader = NukeRewriteDataLoader()
        return config
    }
}

private extension OperationQueue {
    convenience init(maxConcurrentCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentCount
    }
}
