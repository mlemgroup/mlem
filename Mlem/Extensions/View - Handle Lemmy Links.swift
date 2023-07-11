//
//  View - Handle Lemmy Links.swift
//  Mlem
//
//  Created by tht7 on 23/06/2023.
//

import Foundation
import SwiftUI
import AlertToast

struct HandleLemmyLinksDisplay: ViewModifier {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    @EnvironmentObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker
    @EnvironmentObject var savedAccounts: SavedAccountTracker

    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: APICommunityView.self) { context in
                CommunityView(community: context.community, feedType: .all)
                    .environmentObject(appState)
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                    .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: APICommunity.self) { community in
                CommunityView(community: community, feedType: .all)
                    .environmentObject(appState)
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                    .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: CommunityLinkWithContext.self) { context in
                CommunityView(community: context.community, feedType: context.feedType)
                    .environmentObject(appState)
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                    .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: CommunitySidebarLinkWithContext.self) { context in
                CommunitySidebarView(
                    community: context.community,
                    communityDetails: context.communityDetails)
                .environmentObject(appState)
                .environmentObject(filtersTracker)
                .environmentObject(CommunitySearchResultsTracker())
                .environmentObject(favoriteCommunitiesTracker)
            }
            .navigationDestination(for: APIPostView.self) { post in
                ExpandedPost(post: post)
                .environmentObject(
                    PostTracker(shouldPerformMergeSorting: false, initialItems: [post])
                )
                .environmentObject(appState)
            }
            .navigationDestination(for: APIPost.self) { post in
                LazyLoadExpandedPost(post: post)
                    .environmentObject(appState)
            }
            .navigationDestination(for: PostLinkWithContext.self) { post in
                ExpandedPost(post: post.post)
                    .environmentObject(post.postTracker)
                    .environmentObject(appState)
            }
            .navigationDestination(for: LazyLoadPostLinkWithContext.self) { post in
                LazyLoadExpandedPost(post: post.post)
                    .environmentObject(post.postTracker)
                    .environmentObject(appState)
            }
            .navigationDestination(for: APIPerson.self) { user in
                UserView(userID: user.id)
                    .environmentObject(appState)
            }
            .navigationDestination(for: UserModeratorLink.self) { user in
                UserModeratorView(userDetails: user.user, moderatedCommunities: user.moderatedCommunities)
                    .environmentObject(appState)
            }
    }
    // swiftlint:enable function_body_length
}

struct HandleLemmyLinkResolution: ViewModifier {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedAccounts: SavedAccountTracker
    let navigationPath: Binding<NavigationPath>

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }

    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        let account = appState.currentActiveAccount
        // let's try keep peps in the app!
        if url.absoluteString.contains(["lem", "/c/", "/u/", "/post/", "@"]) {
            // this link is sus! let's go
            // but first let's let the user know what's happning!
            appState.toast = AlertToast(displayMode: .hud, type: .loading, title: "Redirecting... please wait")
            appState.isShowingToast = true
            Task(priority: .userInitiated) {
                defer { appState.isShowingToast = false }
                var lookup = url.absoluteString
                lookup = lookup.replacingOccurrences(of: "mlem://", with: "https://")
                if lookup.contains("@") && !lookup.contains("!") {
                    // SUS I think this might be a community link
                    let processedLookup = lookup
                        .replacing(/.*\/c\//, with: "")
                        .replacingOccurrences(of: "mailto:", with: "")
                    lookup = "!\(processedLookup)"
                }
                
                print("lookup: \(lookup) (original: \(url.absoluteString))")
                // Wooo this is a lemmy server we're talking to! time to pasre this url and push it to the stack
                do {
                    let resolution = try await APIClient().perform(request: ResolveObjectRequest(account: account, query: lookup))
                    
                    // this is gonna be a bit of an ugly if switch but oh well for now
                    if let post = resolution.post {
                        // wop wop that was a post link!
                        return navigationPath.wrappedValue.append(post)
                    } else if let community = resolution.community {
                        return navigationPath.wrappedValue.append(community)
                    } else if let user = resolution.person?.person {
                        return navigationPath.wrappedValue.append(user)
                    }
                    // else if let d = resolution.comment {
                    // hmm I don't think we can do that right now!
                    // so I'll skip and let the system open it instead
                    // }
                } catch {
                    appState.contextualError = .init(underlyingError: error)
                }
                
                // if all else fails fallback!
                let outcome = URLHandler.handle(url)
                if outcome.action != nil {
                    if url.scheme == "mlem" {
                        // if we got here then someone intentionally wanted to open this in mlem but now we need to tell him we have no idea how to open it
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            appState.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "Couldn't resolve link")
                            appState.isShowingToast = true
                        }
                    } else {
                        // if we failed to open it let the system try!
                        OpenURLAction(handler: { _ in .systemAction }).callAsFunction(url)
                    }
                }
            }
            // since this is a sus link we need to ask the lemmy servers about it, so for now we ask the system to forget-'bout-itt
            return .discarded
        }
        
        let outcome = URLHandler.handle(url)
        return outcome.result
    }
}

extension View {
    func handleLemmyViews() -> some View {
        modifier(HandleLemmyLinksDisplay())
    }

    func handleLemmyLinkResolution(navigationPath: Binding<NavigationPath>) -> some View {
        modifier(HandleLemmyLinkResolution(navigationPath: navigationPath))
    }

}
