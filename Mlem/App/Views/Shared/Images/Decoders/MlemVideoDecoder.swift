//
//  MlemVideoDecoder.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-09.
//
//  Source: https://github.com/kean/Nuke/issues/811
//  Wraps NukeVideo's decoder to ensure a thumbnail is always generated

import Nuke
import Foundation

class MlemVideoDecoder: ImageDecoding, @unchecked Sendable {
    private let decoder: ImageDecoders.Video
    var isAsynchronous: Bool { decoder.isAsynchronous }
    
    init?(context: ImageDecodingContext) {
        guard let decoder = ImageDecoders.Video(context: context) else { return nil }
        self.decoder = decoder
    }
    
    func decode(_ data: Data) throws -> ImageContainer {
        if let image = decoder.decodePartiallyDownloadedData(data) { return image }
        return try decoder.decode(data)
    }
    
    func decodePartiallyDownloadedData(_ data: Data) -> ImageContainer? {
        decoder.decodePartiallyDownloadedData(data)
    }
}
