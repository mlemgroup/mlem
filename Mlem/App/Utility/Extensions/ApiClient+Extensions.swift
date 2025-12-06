//
//  ApiClient+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/06/2024.
//

import Foundation
import MlemMiddleware
import OpenGraph
import PhotosUI
import SwiftUI

extension ApiClient {
    func isActive(appState: AppState) -> Bool {
        appState.guestSession.api === self || appState.activeSessions.contains(where: { $0.api === self })
    }
    
    func canInteract(appState: AppState) -> Bool { isActive(appState: appState) && token != nil }
    
    var voteFederationMode: VoteFederationMode {
        myInstance?.voteFederationMode ?? .all
    }
    
    func getPostLinkOrUseOpenGraph(url: URL) async throws -> PostLink {
        if  try await self.supports(.fetchLinkMetadata) {
            return try await self.getPostLink(url: url)
        }
        let metadata = try await OpenGraph.fetch(url: url)
        let thumbnailUrl = metadata[.image].map { URL(string: $0) } ?? nil
        return .init(content: url, thumbnail: thumbnailUrl, label: metadata[.title] ?? url.absoluteString)
    }
}
