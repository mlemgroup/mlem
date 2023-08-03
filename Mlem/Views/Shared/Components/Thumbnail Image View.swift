//
//  ThumbnailImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-29.
//

import Foundation
import SwiftUI
import Dependencies

struct ThumbnailImageView: View {
    
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @EnvironmentObject var postTracker: PostTracker
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    let postView: APIPostView
    
    var showNsfwFilter: Bool { (postView.post.nsfw || postView.community.nsfw) && shouldBlurNsfw }
    
    let size = CGSize(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
    
    var body: some View {
        Group {
            switch postView.postType {
            case .image(let url):
                // just blur, no need for the whole filter viewModifier since this is just a thumbnail
                CachedImage(url: url,
                            fixedSize: size,
                            dismissCallback: markPostAsRead)
                    .blur(radius: showNsfwFilter ? 8 : 0)
            case .link(let url):
                CachedImage(url: url, shouldExpand: false, fixedSize: size)
                    .blur(radius: showNsfwFilter ? 8 : 0)
            case .text:
                Image(systemName: "text.book.closed")
            case .titleOnly:
                Image(systemName: "character.bubble")
            }
        }
        .foregroundColor(.secondary)
        .font(.title)
        .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
        .background(Color(UIColor.systemGray4))
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
    }
    
    /**
     Synchronous void wrapper for apiClient.markPostAsRead to pass into CachedImage as dismiss callback
     */
    func markPostAsRead() {
        Task(priority: .userInitiated) {
            do {
                let readPost = try await apiClient.markPostAsRead(for: postView.post.id, read: true)
                postTracker.update(with: readPost.postView)
            } catch {
                errorHandler.handle(.init(underlyingError: error))
            }
        }
    }
}
