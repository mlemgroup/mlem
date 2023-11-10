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
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.navigationPath) private var navigationPath
    @EnvironmentObject private var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var filtersTracker: FiltersTracker
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @AppStorage("upvoteOnSave") var upvoteOnSave = false
    
    // swiftlint:disable function_body_length
    // swiftlint:disable:next cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .community(let community):
                    FeedView(community: community, feedType: .all)
                        .environmentObject(appState)
                        .environmentObject(filtersTracker)
                case .communityLinkWithContext(let context):
                    FeedView(community: context.community, feedType: context.feedType)
                        .environmentObject(appState)
                        .environmentObject(filtersTracker)
                case .communitySidebarLinkWithContext(let context):
                    CommunitySidebarView(
                        community: context.community
                    )
                    .environmentObject(filtersTracker)
                case .apiPostView(let post):
                    let postModel = PostModel(from: post)
                    let postTracker = PostTracker(
                        shouldPerformMergeSorting: false,
                        internetSpeed: internetSpeed,
                        initialItems: [postModel],
                        upvoteOnSave: upvoteOnSave
                    )
                    // swiftlint:disable:next redundant_discardable_let
                    let _ = postTracker.add([postModel])
                    ExpandedPost(post: postModel)
                        .environmentObject(postTracker)
                        .environmentObject(appState)
                case .apiPost(let post):
                    LazyLoadExpandedPost(post: post)
                case .apiPerson(let user):
                    UserView(userID: user.id)
                case .userProfile(let user):
                    UserView(userID: user.userId)
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
                case .settings(let page):
                    settingsDestination(for: page)
                case .aboutSettings(let page):
                    aboutSettingsDestination(for: page)
                case .appearanceSettings(let page):
                    appearanceSettingsDestination(for: page)
                case .commentSettings(let page):
                    commentSettingsDestination(for: page)
                case .postSettings(let page):
                    postSettingsDestination(for: page)
                case .licenseSettings(let page):
                    licensesSettingsDestination(for: page)
                }
            }
    }
    // swiftlint:enable function_body_length
    
    @ViewBuilder
    private func settingsDestination(for page: SettingsPage) -> some View {
        switch page {
        case .accounts:
            AccountsPage()
        case .general:
            GeneralSettingsView()
        case .sorting:
            SortingSettingsView()
        case .contentFilters:
            FiltersSettingsView()
        case .accessibility:
            AccessibilitySettingsView()
        case .appearance:
            AppearanceSettingsView()
        case .about:
            AboutView(navigationPath: navigationPath)
        case .advanced:
            AdvancedSettingsView()
        }
    }
    
    @ViewBuilder
    private func aboutSettingsDestination(for page: AboutSettingsPage) -> some View {
        switch page {
        case .contributors:
            ContributorsView()
        case let .document(doc):
            DocumentView(text: doc.body)
        case .licenses:
            LicensesView()
        }
    }
    
    @ViewBuilder
    private func appearanceSettingsDestination(for page: AppearanceSettingsPage) -> some View {
        switch page {
        case .theme:
            ThemeSettingsView()
        case .appIcon:
            IconSettingsView()
        case .posts:
            PostSettingsView()
        case .comments:
            CommentSettingsView()
        case .communities:
            CommunitySettingsView()
        case .users:
            UserSettingsView()
        case .tabBar:
            TabBarSettingsView()
        }
    }
    
    @ViewBuilder
    private func commentSettingsDestination(for page: CommentSettingsPage) -> some View {
        switch page {
        case .layoutWidget:
            LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.comment, onSave: { widgets in
                layoutWidgetTracker.groups.comment = widgets
                layoutWidgetTracker.saveLayoutWidgets()
            })
        }
    }
    
    @ViewBuilder
    private func postSettingsDestination(for page: PostSettingsPage) -> some View {
        switch page {
        case .customizeWidgets:
            /// We really should be passing in the layout widget through the route enum value, but that would involve making layout widget tracker hashable and codable.
            LayoutWidgetEditView(widgets: layoutWidgetTracker.groups.post, onSave: { widgets in
                layoutWidgetTracker.groups.post = widgets
                layoutWidgetTracker.saveLayoutWidgets()
            })
        }
    }
    
    @ViewBuilder
    private func licensesSettingsDestination(for page: LicensesSettingsPage) -> some View {
        switch page {
        case let .licenseDocument(doc):
            DocumentView(text: doc.body)
        }
    }
}

struct HandleLemmyLinkResolution<Path: AnyNavigablePath>: ViewModifier {
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
            do {
                switch resolution {
                case let .post(object):
                    navigationPath.wrappedValue.append(try Path.makeRoute(object))
                    return true
                case let .person(object):
                    navigationPath.wrappedValue.append(try Path.makeRoute(object.person))
                    return true
                case let .community(object):
                    navigationPath.wrappedValue.append(try Path.makeRoute(object))
                    return true
                case .comment:
                    return false
                }
            } catch {
                errorHandler.handle(error)
                return false
            }
        }
    }
}

extension View {
    func handleLemmyViews() -> some View {
        modifier(HandleLemmyLinksDisplay())
    }

    func handleLemmyLinkResolution<P: AnyNavigablePath>(navigationPath: Binding<P>) -> some View {
        modifier(HandleLemmyLinkResolution(navigationPath: navigationPath))
    }
}
