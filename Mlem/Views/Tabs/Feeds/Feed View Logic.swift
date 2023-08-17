//
//  Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Foundation

extension FeedView {
    
    // MARK: Feed loading
    
    func initFeed() async {
        defer { isLoading = false }
        isLoading = true
        if postTracker.items.isEmpty {
            print("Post tracker is empty")
            await loadFeed()
        } else {
            print("Post tracker is not empty")
        }
    }
    
    func loadFeed() async {
        defer { isLoading = false }
        isLoading = true
        do {
            try await postTracker.loadNextPage(
                account: appState.currentActiveAccount,
                communityId: community?.id,
                sort: postSortType,
                type: feedType,
                filtering: filter
            )
        } catch {
            handle(error)
        }
    }
    
    func refreshFeed() async {
        // NOTE: refresh doesn't need to touch isLoading because that visual cue is handled by .refreshable
        do {
            try await postTracker.refresh(
                account: appState.currentActiveAccount,
                communityId: community?.id,
                sort: postSortType,
                type: feedType,
                filtering: filter
            )
        } catch {
            handle(error)
        }
    }
    
    /**
     Function to reset the feed, used as a callback to switcher options. Clears the items and displays a loading view.
     */
    func hardRefreshFeed() async {
            defer { isLoading = false }
            isLoading = true
            do {
                try await postTracker.refresh(
                    account: appState.currentActiveAccount,
                    communityId: community?.id,
                    sort: postSortType,
                    type: feedType,
                    clearBeforeFetch: true,
                    filtering: filter)
            } catch {
                handle(error)
            }
    }
    
    // MARK: Community loading
    
    func fetchCommunityDetails() async {
        if let community {
            do {
                communityDetails = try await apiClient.getCommunityDetails(id: community.id)
            } catch {
                errorHandler.handle(
                    .init(
                        title: "Could not load community information",
                        message: "The server might be overloaded.\nTry again later.",
                        underlyingError: error
                    )
                )
            }
        }
    }
    
    // MARK: Menus
    
    func genOuterSortMenuFunctions() -> [MenuFunction] {
        return PostSortType.outerTypes.map { type in
            let isSelected = postSortType == type
            let imageName = isSelected ? type.iconNameFill : type.iconName
            return MenuFunction(text: type.description,
                                imageName: imageName,
                                destructiveActionPrompt: nil,
                                enabled: !isSelected) {
                postSortType = type
            }
        }
    }
    
    func genTopSortMenuFunctions() -> [MenuFunction] {
        return PostSortType.topTypes.map { type in
            let isSelected = postSortType == type
            return MenuFunction(text: type.description,
                                imageName: isSelected ? AppConstants.timeSymbolNameFill : AppConstants.timeSymbolName,
                                destructiveActionPrompt: nil,
                                enabled: !isSelected) {
                postSortType = type
            }
        }
    }
    
    func genEllipsisMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        let blurNsfwText = shouldBlurNsfw ? "Unblur NSFW" : "Blur NSFW"
        ret.append(MenuFunction(
            text: blurNsfwText,
            imageName: AppConstants.blurNsfwSymbolName,
            destructiveActionPrompt: nil,
            enabled: true) {
                shouldBlurNsfw.toggle()
            })
        
        let showReadPostsText = showReadPosts ? "Hide read" : "Show read"
        ret.append(MenuFunction(text: showReadPostsText,
                                imageName: "book",
                                destructiveActionPrompt: nil,
                                enabled: true) {
            showReadPosts.toggle()
        })
        
        return ret
    }
    
    // swiftlint:disable function_body_length
    func genCommunitySpecificMenuFunctions(for community: APICommunity) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        // new post
        ret.append(MenuFunction(text: "New Post",
                                imageName: AppConstants.sendSymbolNameFill,
                                destructiveActionPrompt: nil,
                                enabled: true) {
            editorTracker.openEditor(with: PostEditorModel(community: community,
                                                           postTracker: postTracker))
        })
        
        // subscribe/unsubscribe
        if let communityDetails {
            let isSubscribed: Bool = communityDetails.communityView.subscribed.rawValue == "Subscribed"
            let (subscribeText, subscribeSymbol, subscribePrompt) = isSubscribed
            ? ("Unsubscribe", AppConstants.unsubscribeSymbolName, "Really unsubscribe from \(community.name)?")
            : ("Subscribe", AppConstants.subscribeSymbolName, nil)
            ret.append(MenuFunction(text: subscribeText,
                                    imageName: subscribeSymbol,
                                    destructiveActionPrompt: subscribePrompt,
                                    enabled: true) {
                Task(priority: .userInitiated) {
                    await subscribe(communityId: community.id, shouldSubscribe: !isSubscribed)
                }
            })
        }
        
        // favorite/unfavorite
        if favoriteCommunitiesTracker.favoriteCommunities.contains(where: { $0.community.id == community.id }) {
            ret.append(MenuFunction(text: "Unfavorite",
                                    imageName: "star.slash",
                                    destructiveActionPrompt: "Really unfavorite \(community.name)?",
                                    enabled: true) {
                favoriteCommunitiesTracker.unfavorite(community)
                Task {
                    await notifier.add(.success("Unfavorited \(community.name)"))
                }
            })
        } else {
            ret.append(MenuFunction(text: "Favorite",
                                    imageName: "star",
                                    destructiveActionPrompt: nil,
                                    enabled: true) {
                favoriteCommunitiesTracker.favorite(community, for: appState.currentActiveAccount)
                Task {
                    await notifier.add(.success("Favorited \(community.name)"))
                }
            })
        }
        
        // share
        ret.append(MenuFunction(text: "Share",
                                imageName: AppConstants.shareSymbolName,
                                destructiveActionPrompt: nil,
                                enabled: true) {
            showShareSheet(URLtoShare: community.actorId)
        })
        
        // block/unblock
        if let communityDetails {
            // block
            let (blockText, blockSymbol, blockPrompt) = communityDetails.communityView.blocked
            ? ("Unblock", AppConstants.unblockSymbolName, nil)
            : ("Block", AppConstants.blockSymbolName, "Really block \(community.name)?")
            ret.append(MenuFunction(text: blockText,
                                    imageName: blockSymbol,
                                    destructiveActionPrompt: blockPrompt,
                                    enabled: true) {
                Task(priority: .userInitiated) {
                    await block(communityId: community.id, shouldBlock: !communityDetails.communityView.blocked)
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
            ret.append(MenuFunction(text: type.label,
                                    imageName: imageName,
                                    destructiveActionPrompt: nil,
                                    enabled: enabled,
                                    callback: { feedType = type }))
        }
        
        return ret
    }
    
    func genPostSizeSwitchingFunctions() -> [MenuFunction] {
        return PostSize.allCases.map { size in
            let (imageName, enabled) = size != postSize
            ? (size.iconName, true)
            : (size.iconNameFill, false)
            
            return MenuFunction(text: size.label,
                                imageName: imageName,
                                destructiveActionPrompt: nil,
                                enabled: enabled,
                                callback: { postSize = size })
        }
    }
    
    // MARK: Helper Functions
    
    private func handle(_ error: Error) {
        let title: String?
        let errorMessage: String?
        
        switch error {
        case APIClientError.networking:
            guard postTracker.items.isEmpty else {
                return
            }
            
            title = "Unable to connect to Lemmy"
            errorMessage = "Please check your internet connection and try again"
        default:
            title = nil
            errorMessage = nil
        }
        
        errorHandler.handle(
            .init(title: title, message: errorMessage, underlyingError: error)
        )
    }
    
    private func filter(postView: APIPostView) -> Bool {
        !postView.post.name.lowercased().contains(filtersTracker.filteredKeywords) &&
        (showReadPosts || !postView.read)
    }
    
    // MARK: TODO: MOVE TO REPOSITORY MODEL
    
    private func subscribe(communityId: Int, shouldSubscribe: Bool) async {
        hapticManager.play(haptic: .success, priority: .high)
        do {            
            _ = try await apiClient.followCommunity(id: communityId, shouldSubscribe: shouldSubscribe)
            
            let communityName = community?.name ?? "community"
            Task {
                if shouldSubscribe {
                    await notifier.add(.success("Subscibed to \(communityName)"))
                } else {
                    await notifier.add(.success("Unsubscribed from \(communityName)"))
                }
            }
            
            // re-fetch to get new subscribed status
            // TODO: do this in middleware model with a state faker to avoid a second API call
            await fetchCommunityDetails()
        } catch {
            // TODO: If we fail here and want to notify the user we can pass values into the below error
            errorHandler.handle(
                .init(underlyingError: error)
            )
        }
    }
    
    private func block(communityId: Int, shouldBlock: Bool) async {
        do {
            hapticManager.play(haptic: .violentSuccess, priority: .high)
            
            let communityName = community?.name ?? "community"
            Task {
                if shouldBlock {
                    await notifier.add(.success("Blocked \(communityName)"))
                } else {
                    await notifier.add(.success("Unblocked \(communityName)"))
                }
            }
            
            _ = try await apiClient.blockCommunity(id: communityId, shouldBlock: shouldBlock)
            await fetchCommunityDetails()
        } catch {
            // TODO: If we fail here and want to notify the user we should
            // pass a message into the contextual error below
            errorHandler.handle(
                .init(underlyingError: error)
            )
        }
    }
}
