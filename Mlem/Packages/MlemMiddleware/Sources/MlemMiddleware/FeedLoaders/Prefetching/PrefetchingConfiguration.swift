//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 10/08/2024.
//

import Foundation
import Nuke

public struct PrefetchingConfiguration {
    public enum ImageResolution {
        case unlimited, limited(Int)
    }
    
    public var prefetcher: ImagePrefetcher
    
    public var imageSize: ImageResolution
    
    /// If `nil`, does not fetch avatars.
    public var avatarSize: Int?
    
    let fetchFavicons: Bool
    let embedLoops: Bool
    
    public init(
        prefetcher: ImagePrefetcher,
        imageSize: ImageResolution,
        fetchFavicons: Bool,
        embedLoops: Bool,
        avatarSize: Int? = nil
    ) {
        self.prefetcher = prefetcher
        self.imageSize = imageSize
        self.avatarSize = avatarSize
        self.fetchFavicons = fetchFavicons
        self.embedLoops = embedLoops
    }
}
