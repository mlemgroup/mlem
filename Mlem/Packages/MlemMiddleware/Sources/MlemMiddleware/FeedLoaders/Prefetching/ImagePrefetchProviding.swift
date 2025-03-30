//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-25.
//

import Foundation
import Nuke

public protocol ImagePrefetchProviding {
    func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest]
}
