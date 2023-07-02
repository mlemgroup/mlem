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
    @EnvironmentObject var savedAccounts: SavedAccountTracker

    // swiftlint:disable function_body_length
    func body(content: Content) -> some View {
        let account = appState.currentActiveAccount ?? savedAccounts.savedAccounts.first
        return content
            .navigationDestination(for: APICommunityView.self) { context in
                if let account = account {
                    CommunityView(account: account, community: context.community)
                } else {
                    Text("You must be signed in to view this community")
                }
            }
            .navigationDestination(for: APICommunity.self) { community in
                if let account = account {
                    CommunityView(account: account, community: community)
                } else {
                    Text("You must be signed in to view this community")
                }
            }
            .navigationDestination(for: CommunityLinkWithContext.self) { context in
                if let account = account {
                    CommunityView(account: account, community: context.community, feedType: context.feedType)
                } else {
                    Text("You must be signed in to view this community")
                }
            }
            .navigationDestination(for: CommunitySidebarLinkWithContext.self) { context in
                if let account = account {
                    CommunitySidebarView(
                        account: account,
                        community: context.community,
                        communityDetails: context.communityDetails)
                } else {
                    Text("You must be signed in to view this community")
                }
            }
            .navigationDestination(for: APIPostView.self) { post in
                if let account = account {
                    ExpandedPost(
                        account: account,
                        post: post,
                        feedType: .constant(.all)
                    ).environmentObject(appState)
                } else {
                    Text("You must be signed in to view this post")
                }
            }
            .navigationDestination(for: APIPost.self) { post in
                if let account = account {
                    LazyLoadExpandedPost(
                        account: account,
                        post: post
                    ).environmentObject(appState)
                } else {
                    Text("You must be signed in to view this post")
                }
            }
            .navigationDestination(for: PostLinkWithContext.self) { post in
                if let account = account {
                    ExpandedPost(
                        account: account,
                        post: post.post,
                        feedType: post.feedType
                    ).environmentObject(post.postTracker)
                        .environmentObject(appState)
                } else {
                    Text("You must be signed in to view this post")
                }
            }
            .navigationDestination(for: LazyLoadPostLinkWithContext.self) { post in
                if let account = account {
                    LazyLoadExpandedPost(
                        account: account,
                        post: post.post
                    ).environmentObject(post.postTracker)
                        .environmentObject(appState)
                } else {
                    Text("You must be signed in to view this post")
                }
            }
            .navigationDestination(for: APIPerson.self) { user in
                if let account = account {
                    UserView(userID: user.id, account: account).environmentObject(appState)
                } else {
                    Text("You must be signed in to view this user")
                }
            }
            .navigationDestination(for: UserModeratorLink.self) { user in
                if let account = account {
                    UserModeratorView(account: account, userDetails: user.user, moderatedCommunities: user.moderatedCommunities)
                } else {
                    Text("You must be signed in to view this user")
                }
            }
    }
    // swiftlint:enable function_body_length
}

struct HandleLemmyLinkResolution: ViewModifier {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedAccounts: SavedAccountTracker
    let navigationPath: Binding<NavigationPath>
    let local: String

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
    }

    @MainActor
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        let account = appState.currentActiveAccount ?? savedAccounts.savedAccounts.first
        // let's try keep peps in the app!
        if let account = account {
            if url.absoluteString.contains(["lem", "/c/", "/u/", "/post/", "@"]) {
                // this link is sus! let's go
                // but first let's let the user know what's happning!
                appState.toast = AlertToast(displayMode: .hud, type: .loading, title: "Redirecting... please wait")
                appState.isShowingToast = true
                Task(priority: .userInitiated) {
                    defer { appState.isShowingToast = false }
                    var lookup = url.absoluteString
                    lookup = lookup.replacingOccurrences(of: "mlem://", with: "https://")
                    if !lookup.contains("http") {
                        // something fishy is going on. I think the markdown view is playing with us!
                        if lookup.contains("@") && !lookup.contains("!") {
                            lookup = "!\(lookup)".replacingOccurrences(of: "/c/", with: "").replacingOccurrences(of: "mailto:", with: "")
                        }
                    }

                    print("lookup: \(lookup) (original: \(url.absoluteString)) (\(local))")
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
                        print(String(describing: error))
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

        }

        let outcome = URLHandler.handle(url)
        return outcome.result
    }
}

extension View {
    func handleLemmyViews() -> some View {
        modifier(HandleLemmyLinksDisplay())
    }

    func handleLemmyLinkResolution(navigationPath: Binding<NavigationPath>, local: String) -> some View {
        modifier(HandleLemmyLinkResolution(navigationPath: navigationPath, local: local))
    }

}
