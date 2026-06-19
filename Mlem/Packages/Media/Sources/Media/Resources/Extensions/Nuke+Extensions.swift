//
//  File.swift
//  Media
//
//  Created by Sjmarf on 2026-06-19.
//  

import Foundation
import Nuke

extension ImagePipeline {
    @discardableResult public func data(url: URL) async throws -> (Data, URLResponse?) {
        try await data(for: ImageRequest(url: url))
    }
}
