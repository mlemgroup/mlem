//
//  Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Foundation
import SwiftUI

extension FeedView {
    
    func setDefaultSortMode() {
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
        if let siteVersion = siteInformation.version, siteVersion < defaultPostSorting.minimumVersion {
            postSortType = fallbackDefaultPostSorting
        } else {
            postSortType = defaultPostSorting
        }
    }
    
    // MARK: Feed loading
    
    func initFeed() async {
        isLoading = true
        if postTracker.items.isEmpty {
            print("Post tracker is empty")
            await loadFeed()
        } else {
            print("Post tracker is not empty")
            isLoading = false
        }
    }
    
    func loadFeed() async {
        defer { isLoading = false }
        isLoading = true
        do {
            try await postTracker.loadNextPage(
                communityId: community?.communityId,
                sort: postSortType,
                type: feedType,
                filtering: filter
            )
        } catch {
            handle(error)
        }
    }
    
    @discardableResult
    func refreshFeed() async -> Bool {
        // NOTE: refresh doesn't need to touch isLoading because that visual cue is handled by .refreshable
        do {
            try await postTracker.refresh(
                communityId: community?.communityId,
                sort: postSortType,
                feedType: feedType,
                filtering: filter
            )
            errorDetails = nil
            return true
        } catch {
            handle(error)
            return false
        }
    }
    
    /// Function to reset the feed, used as a callback to switcher options. Clears the items and displays a loading view.
    func hardRefreshFeed() async {
        defer { isLoading = false }
        isLoading = true
        do {
            try await postTracker.refresh(
                communityId: community?.communityId,
                sort: postSortType,
                feedType: feedType,
                clearBeforeFetch: true,
                filtering: filter
            )
        } catch {
            handle(error)
        }
    }
    
    // MARK: Community loading

    func fetchCommunityDetails() async {
        if let community {
            do {
                let communityDetails: GetCommunityResponse = try await communityRepository.loadDetails(for: community.communityId)
                self.community = .init(from: communityDetails)
            } catch {
                errorHandler.handle(
                    .init(
                        title: "Could not load community information",
                        message: "The server might be overloaded.\nTry again later.",
                        underlyingError: error
                    ),
                    showNoInternet: false
                )
            }
        }
    }
    
    // MARK: Menus
    
    func genOuterSortMenuFunctions() -> [MenuFunction] {
        PostSortType.availableOuterTypes.map { type in
            let isSelected = postSortType == type
            let imageName = isSelected ? type.iconNameFill : type.iconName
            return MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: !isSelected
            ) {
                postSortType = type
            }
        }
    }
    
    func genTopSortMenuFunctions() -> [MenuFunction] {
        PostSortType.availableTopTypes.map { type in
            let isSelected = postSortType == type
            return MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: isSelected ? Icons.timeSortFill : Icons.timeSort,
                destructiveActionPrompt: nil,
                enabled: !isSelected
            ) {
                postSortType = type
            }
        }
    }
    
    func genEllipsisMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        let blurNsfwText = shouldBlurNsfw ? "Unblur NSFW" : "Blur NSFW"
        ret.append(MenuFunction.standardMenuFunction(
            text: blurNsfwText,
            imageName: Icons.blurNsfw,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            shouldBlurNsfw.toggle()
        })
        
        let showReadPostsText = showReadPosts ? "Hide read" : "Show read"
        ret.append(MenuFunction.standardMenuFunction(
            text: showReadPostsText,
            imageName: "book",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            showReadPosts.toggle()
        })
        
        return ret
    }
    
    // swiftlint:disable function_body_length
    func genCommunitySpecificMenuFunctions() -> [MenuFunction] {
        guard let community else { return [] }
        var ret: [MenuFunction] = .init()
        // new post
        ret.append(MenuFunction.standardMenuFunction(
            text: "New Post",
            imageName: Icons.sendFill,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            editorTracker.openEditor(with: PostEditorModel(
                community: community,
                postTracker: postTracker
            ))
        })
        
        // subscribe/unsubscribe
        if let subscribed = community.subscribed {
            let (subscribeText, subscribeSymbol, subscribePrompt) = subscribed
                ? ("Unsubscribe", Icons.unsubscribe, "Really unsubscribe from \(community.name)?")
                : ("Subscribe", Icons.subscribe, nil)
            ret.append(MenuFunction.standardMenuFunction(
                text: subscribeText,
                imageName: subscribeSymbol,
                destructiveActionPrompt: subscribePrompt,
                enabled: true
            ) {
                Task(priority: .userInitiated) {
                    await toggleSubscribe()
                }
            })
        }
        
        // favorite/unfavorite
        if favoriteCommunitiesTracker.isFavorited(community.community) {
            ret.append(MenuFunction.standardMenuFunction(
                text: "Unfavorite",
                imageName: "star.slash",
                destructiveActionPrompt: "Really unfavorite \(community.name)?",
                enabled: true
            ) {
                favoriteCommunitiesTracker.unfavorite(community.community)
                Task {
                    await notifier.add(.success("Unfavorited \(community.name)"))
                }
            })
        } else {
            ret.append(MenuFunction.standardMenuFunction(
                text: "Favorite",
                imageName: "star",
                destructiveActionPrompt: nil,
                enabled: true
            ) {
                favoriteCommunitiesTracker.favorite(community.community)
                Task {
                    await notifier.add(.success("Favorited \(community.name)"))
                }
            })
        }
        
        // share
        ret.append(MenuFunction.shareMenuFunction(url: community.communityUrl))
        
        // block/unblock
        if let blocked = community.blocked {
            // block
            let (blockText, blockSymbol, blockPrompt) = blocked
                ? ("Unblock", Icons.show, nil)
                : ("Block", Icons.hide, "Really block \(community.name)?")
            ret.append(MenuFunction.standardMenuFunction(
                text: blockText,
                imageName: blockSymbol,
                destructiveActionPrompt: blockPrompt,
                enabled: true
            ) {
                Task(priority: .userInitiated) {
                    await block()
                }
            })
        }
        
        return ret
    }

    // swiftlint:enable function_body_length
    
    func genFeedSwitchingFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        FeedType.allCases.forEach { type in
            let (imageName, enabled) = type != feedType
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            ret.append(MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: enabled,
                callback: { feedType = type }
            ))
        }
        
        return ret
    }
    
    func genPostSizeSwitchingFunctions() -> [MenuFunction] {
        PostSize.allCases.map { size in
            let (imageName, enabled) = size != postSize
                ? (size.iconName, true)
                : (size.iconNameFill, false)
            
            return MenuFunction.standardMenuFunction(
                text: size.label,
                imageName: imageName,
                destructiveActionPrompt: nil,
                enabled: enabled,
                callback: { postSize = size }
            )
        }
    }
    
    // MARK: Helper Functions
    
    private func handle(_ error: Error) {
        switch error {
        case APIClientError.networking:
            guard postTracker.items.isEmpty else {
                return
            }
            errorDetails = .init(title: "Unable to connect to Lemmy", error: error, refresh: refreshFeed)
            return
        case APIClientError.decoding(let data, _):
            // Checks if it's an "unknown sort type" error
            if let str = String(data: data, encoding: .utf8), str.starts(with: "Query deserialize error: unknown variant") {
                Task {
                    print("Unknown sort type: reloading feed")
                    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
                    postSortType = fallbackDefaultPostSorting
                    await loadFeed()
                }
                return
            }
        default:
            break
        }
        errorDetails = .init(error: error, refresh: refreshFeed)
    }
    
    private func filter(postView: PostModel) -> PostFilterReason? {
        guard !postView.post.name.lowercased().contains(filtersTracker.filteredKeywords) else { return .keyword }
        guard showReadPosts || !postView.read else { return .read }
        return nil
    }
    
    private func toggleSubscribe() async {
        if var community {
            hapticManager.play(haptic: .success, priority: .high)
            do {
                try await community.toggleSubscribe {
                    self.community = $0
                }
                if community.subscribed ?? false {
                    await notifier.add(.success("Subscribed to \(community.name)"))
                } else {
                    await notifier.add(.success("Unsubscribed from \(community.name)"))
                }
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    private func block() async {
        if var community {
            hapticManager.play(haptic: .violentSuccess, priority: .high)
            do {
                try await community.toggleBlock {
                    self.community = $0
                }
                // refresh the feed after blocking which will show/hide the posts
                await hardRefreshFeed()
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
