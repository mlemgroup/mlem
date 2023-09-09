//
//  View - Handle Lemmy Links.swift
//  Mlem
//
//  Created by tht7 on 23/06/2023.
//

import Dependencies
import Foundation
import SwiftUI

struct HandleLemmyLinksDisplay: ViewModifier {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("upvoteOnSave") var upvoteOnSave = false

    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .apiCommunity(let community):
                    FeedView(community: community, feedType: .all, sortType: defaultPostSorting)
                        .environmentObject(appState)
                        .environmentObject(filtersTracker)
                        .environmentObject(CommunitySearchResultsTracker())
                case .apiCommunityView(let context):
                    FeedView(community: context.community, feedType: .all, sortType: defaultPostSorting)
                        .environmentObject(appState)
                        .environmentObject(filtersTracker)
                        .environmentObject(CommunitySearchResultsTracker())
                case .communityLinkWithContext(let context):
                    FeedView(community: context.community, feedType: context.feedType, sortType: defaultPostSorting)
                        .environmentObject(appState)
                        .environmentObject(filtersTracker)
                        .environmentObject(CommunitySearchResultsTracker())
                case .communitySidebarLinkWithContext(let context):
                    CommunitySidebarView(
                        community: context.community,
                        communityDetails: context.communityDetails
                    )
                    .environmentObject(filtersTracker)
                    .environmentObject(CommunitySearchResultsTracker())
                case .apiPostView(let post):
                    let postModel = PostModel(from: post)
                    ExpandedPost(post: postModel)
                        .environmentObject(
                            PostTracker(
                                shouldPerformMergeSorting: false,
                                internetSpeed: internetSpeed,
                                initialItems: [postModel],
                                upvoteOnSave: upvoteOnSave
                            )
                        )
                        .environmentObject(appState)
                case .apiPost(let post):
                    LazyLoadExpandedPost(post: post)
                case .apiPerson(let user):
                    UserView(userID: user.id)
                        .environmentObject(appState)
                case .postLinkWithContext(let post):
                    ExpandedPost(post: post.post, scrollTarget: post.scrollTarget)
                        .environmentObject(post.postTracker)
                        .environmentObject(appState)
                case .lazyLoadPostLinkWithContext(let post):
                    LazyLoadExpandedPost(post: post.post, scrollTarget: post.scrollTarget)
                case .userModeratorLink(let user):
                    UserModeratorView(userDetails: user.user, moderatedCommunities: user.moderatedCommunities)
                        .environmentObject(appState)
                }
            }
    }
    // swiftlint:enable function_body_length
}

struct HandleLemmyLinkResolution<Path: AnyNavigationPath>: ViewModifier {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    let navigationPath: Binding<Path>

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }

    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        // let's try keep peps in the app!
        if url.absoluteString.contains(["lem", "/c/", "/u/", "/post/", "@"]) {
            // this link is sus! let's go
            // but first let's let the user know what's happning!
            Task {
                await notifier.performWithLoader {
                    var lookup = url.absoluteString
                    lookup = lookup.replacingOccurrences(of: "mlem://", with: "https://")
                    if lookup.contains("@"), !lookup.contains("!") {
                        // SUS I think this might be a community link
                        let processedLookup = lookup
                            .replacing(/.*\/c\//, with: "")
                            .replacingOccurrences(of: "mailto:", with: "")
                        lookup = "!\(processedLookup)"
                    }
                    
                    print("lookup: \(lookup) (original: \(url.absoluteString))")
                    // Wooo this is a lemmy server we're talking to! time to parse this url and push it to the stack
                    do {
                        let resolved = try await resolve(query: lookup)
                        
                        if resolved {
                            // as the link was handled we return, else it would also be passed to the default URL handling below
                            return
                        }
                    } catch {
                        guard case let APIClientError.response(apiError, _) = error,
                              apiError.error == "couldnt_find_object",
                              url.scheme == "https" else {
                            errorHandler.handle(error)
                            
                            return
                        }
                    }
                    
                    // if all else fails fallback!
                    let outcome = URLHandler.handle(url)
                    if outcome.action != nil {
                        if url.scheme == "mlem" {
                            // if we got here then someone intentionally wanted to open this in mlem but now we need to tell him we have no idea how to open it
                            await notifier.add(.failure("Couldn't resolve link"))
                        } else {
                            // if we failed to open it let the system try!
                            OpenURLAction(handler: { _ in .systemAction }).callAsFunction(url)
                        }
                    }
                }
            }

            // since this is a sus link we need to ask the lemmy servers about it, so for now we ask the system to forget-'bout-itt
            return .discarded
        }
        
        let outcome = URLHandler.handle(url)
        return outcome.result
    }
    
    private func resolve(query: String) async throws -> Bool {
        guard let resolution = try await apiClient.resolve(query: query) else {
            return false
        }
        
        return await MainActor.run {
            switch resolution {
            case let .post(object):
                navigationPath.wrappedValue.append(object)
                return true
            case let .person(object):
                navigationPath.wrappedValue.append(object.person)
                return true
            case let .community(object):
                navigationPath.wrappedValue.append(object)
                return true
            case .comment:
                return false
            }
        }
    }
}

extension View {
    func handleLemmyViews() -> some View {
        modifier(HandleLemmyLinksDisplay())
    }

    func handleLemmyLinkResolution<P: AnyNavigationPath>(navigationPath: Binding<P>) -> some View {
        modifier(HandleLemmyLinkResolution(navigationPath: navigationPath))
    }
}
