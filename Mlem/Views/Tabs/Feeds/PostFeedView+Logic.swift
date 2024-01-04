//
//  PostFeedView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import SwiftUI
import Dependencies

extension PostFeedView {
    
    func setDefaultSortMode() {
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
        @Dependency(\.siteInformation) var siteInformation
        if let siteVersion = siteInformation.version, siteVersion < defaultPostSorting.minimumVersion {
            postSortType = fallbackDefaultPostSorting
        } else {
            postSortType = defaultPostSorting
        }
    }

    func filter(postView: PostModel) -> PostFilterReason? {
        guard !postView.post.name.lowercased().contains(filtersTracker.filteredKeywords) else { return .keyword }
        guard showReadPosts || !postView.read else { return .read }
        return nil
    }
    
    func handle(_ error: Error) {
        switch error {
        case APIClientError.networking:
            guard postTracker.items.isEmpty else {
                return
            }
            errorDetails = .init(title: "Unable to connect to Lemmy", error: error, refresh: { return await postTracker.refresh() })
            return
        case APIClientError.decoding(let data, _):
            // Checks if it's an "unknown sort type" error
            if let str = String(data: data, encoding: .utf8), str.starts(with: "Query deserialize error: unknown variant") {
                Task {
                    print("Unknown sort type: reloading feed")
                    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
                    postSortType = fallbackDefaultPostSorting
                    await postTracker.loadNextPage()
                }
                return
            }
        default:
            break
        }
        errorDetails = .init(error: error, refresh: { return await postTracker.refresh() })
    }
}
