//
//  CommunitySearchSheet.swift
//  Mlem
//
//  Created by Sjmarf on 2025-06-30.
//

import MlemMiddleware
import SwiftUI

struct CommunitySearchSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.colorScheme) var colorScheme
    
    let api: ApiClient?
    let callback: (Community2) -> Void
    var feedLoader: (any FeedLoading)?
    
    var body: some View {
        NewSearchSheet(callback: callback, loadContent: load) { community in
            HStack {
                CircleCroppedImageView(
                    url: community.avatar?.withIconSize(128),
                    frame: 32,
                    fallback: .communityAvatar,
                    blurred: community.nsfw
                )
                .background(.themedSecondary.opacity(0.2), in: .circle)
                (
                    Text(community.name).foregroundStyle(.tint)
                        + Text("@\(community.host)").foregroundStyle(.tint.opacity(0.5))
                )
                .saturation(0.3)
                .brightness(colorScheme == .dark ? 0.5 : -0.5)
                .lineLimit(1)
                Spacer()
            }
            .mask {
                HStack(spacing: 0) {
                    Color.black
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 20)
                    Color.clear
                        .frame(width: 50)
                }
            }
            .overlay(alignment: .trailing) {
                Text(community.subscriberCount.abbreviated)
                    .font(.footnote)
                    .foregroundStyle(.tint)
                    .saturation(0.7)
                    .brightness(colorScheme == .dark ? 0.3 : -0.3)
                    .opacity(0.5)
                    .padding(.trailing, 10)
            }
        }
    }
    
    var effectiveApi: ApiClient {
        api ?? appState.firstApi
    }
    
    func load(query: String) async throws -> [Community2] {
        try await effectiveApi.searchCommunities(query: query, limit: 10)
    }
}
