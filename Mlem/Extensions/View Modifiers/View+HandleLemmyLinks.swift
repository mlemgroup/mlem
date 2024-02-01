//
//  View+HandleLemmyLinks.swift
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
    @EnvironmentObject private var quickLookState: ImageDetailSheetState
    
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
    @AppStorage("upvoteOnSave") var upvoteOnSave = false
    
    // swiftlint:disable:next cyclomatic_complexity
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case let .community(community):
                    CommunityFeedView(communityModel: community)
                        .environmentObject(appState)
                        .environmentObject(filtersTracker)
                        .environmentObject(quickLookState)
                case let .userProfile(user, communityContext):
                    UserView(user: user, communityContext: communityContext)
                        .environmentObject(appState)
                        .environmentObject(quickLookState)
                case let .instance(domainName, instance):
                    InstanceView(domainName: domainName, instance: instance)
                case let .postLinkWithContext(postLink):
                    ExpandedPost(post: postLink.post, community: postLink.community, scrollTarget: postLink.scrollTarget)
                        .environmentObject(postLink.postTracker)
                        .environmentObject(appState)
                        .environmentObject(quickLookState)
                        .environmentObject(layoutWidgetTracker)
                case let .lazyLoadPostLinkWithContext(post):
                    LazyLoadExpandedPost(post: post.post, scrollTarget: post.scrollTarget)
                        .environmentObject(quickLookState)
                case let .settings(page):
                    settingsDestination(for: page)
                case let .aboutSettings(page):
                    aboutSettingsDestination(for: page)
                case let .appearanceSettings(page):
                    appearanceSettingsDestination(for: page)
                case let .commentSettings(page):
                    commentSettingsDestination(for: page)
                case let .postSettings(page):
                    postSettingsDestination(for: page)
                case let .licenseSettings(page):
                    licensesSettingsDestination(for: page)
                }
            }
    }
    
    @ViewBuilder
    // swiftlint:disable:next cyclomatic_complexity
    private func settingsDestination(for page: SettingsPage) -> some View {
        switch page {
        case .currentAccount:
            AccountSettingsView()
        case .editProfile:
            ProfileSettingsView()
        case .signInAndSecurity:
            SignInAndSecuritySettingsView()
        case .accountGeneral:
            AccountGeneralSettingsView()
        case .accountLocal:
            LocalAccountSettingsView()
        case .accountAdvanced:
            AdvancedAccountSettingsView()
        case .accountDiscussionLanguages:
            AccountDiscussionLanguagesView()
        case .linkMatrixAccount:
            MatrixLinkView()
        case .accounts:
            AccountSwitcherSettingsView()
        case .quickSwitcher:
            QuickSwitcherSettingsView()
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
                    var altLookup: String?
                    
                    // anything with an @ gets parsed to mailto: by Markdown
                    if lookup.starts(with: "mailto:") {
                        // SUS I think this might be a community or user link
                        let processedLookup = lookup
                            .replacing(/.*\/c\//, with: "")
                            .replacingOccurrences(of: "mailto:", with: "")
                        
                        // the mailto: strips the ! and @, so we have to try both
                        lookup = "!\(processedLookup)" // community
                        altLookup = "@\(processedLookup)" // user
                    }
                    
                    print("lookup: \(lookup), altLookup: \(String(describing: altLookup)) (original: \(url.absoluteString))")
                    // Wooo this is a lemmy server we're talking to! time to parse this url and push it to the stack
                    do {
                        var resolved: Bool
                        if let altLookup {
                            do {
                                resolved = try await resolve(query: lookup)
                            } catch {
                                resolved = try await resolve(query: altLookup)
                            }
                        } else {
                            resolved = try await resolve(query: lookup)
                        }
                        
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
                    try navigationPath.wrappedValue.append(Path.makeRoute(object))
                    return true
                case let .person(object):
                    try navigationPath.wrappedValue.append(Path.makeRoute(object.person))
                    return true
                case let .community(object):
                    // TODO: routes should all be based on middleware models, and the resolution should return a middleware model
                    try navigationPath.wrappedValue.append(Path.makeRoute(CommunityModel(from: object)))
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

    func handleLemmyLinkResolution(navigationPath: Binding<some AnyNavigablePath>) -> some View {
        modifier(HandleLemmyLinkResolution(navigationPath: navigationPath))
    }
}
