//
//  SearchView+CommunityPicker.swift
//  Mlem
//
//  Created by Sjmarf on 04/10/2024.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    struct LocationPicker: View {
        @Environment(AppState.self) var appState
        @Environment(NavigationLayer.self) var navigation

        @Binding var filter: LocationFilter
        var requiredFeature: Feature?
        
        var allowActiveAccountLocalInstanceSearch: Bool {
            if let requiredFeature {
                appState.firstApi.supports(requiredFeature, defaultValue: false)
            } else {
                true
            }
        }
        
        var body: some View {
            Menu(filter.label, icon: filter.icon) {
                Section {
                    Toggle(
                        "Anywhere",
                        systemImage: "globe",
                        isOn: .init(get: { filter == .any }, set: { _ in filter = .any })
                    )
                }
                Section {
                    switch filter {
                    case let .community(community):
                        Toggle(isOn: .constant(true)) {
                            Label {
                                Text(community.name)
                            } icon: {
                                SimpleAvatarView(url: community.avatar, type: .communityAvatar)
                                    .id(community.avatar)
                            }
                        }
                    default:
                        EmptyView()
                    }
                    Button("Choose Community...", icon: .lemmy.community) {
                        navigation.openSheet(.communityPicker(callback: { community in
                            filter = .community(community)
                        }))
                    }
                }
                Section {
                    if !((AppState.main.firstSession as? UserSession)?.subscriptions.communities.isEmpty ?? true) {
                        Toggle(
                            "Subscribed",
                            icon: .lemmy.subscribedFeed,
                            isOn: .init(get: { filter == .subscribed }, set: { _ in filter = .subscribed })
                        )
                    }
                    if !((AppState.main.firstSession as? UserSession)?.person?.moderatedCommunities.value?.isEmpty ?? true) {
                        Toggle(
                            "Moderated",
                            icon: .lemmy.moderation,
                            isOn: .init(get: { filter == .moderated }, set: { _ in filter = .moderated })
                        )
                    }
                }
                Section {
                    if allowActiveAccountLocalInstanceSearch {
                        Toggle(isOn: .init(get: { filter == .localInstance }, set: { _ in filter = .localInstance })) {
                            Label {
                                Text(AppState.main.firstApi.host)
                            } icon: {
                                SimpleAvatarView(url: AppState.main.firstSession.instance?.avatar, type: .instanceAvatar)
                            }
                        }
                    }
                    switch filter {
                    case let .instance(instance):
                        Toggle(isOn: .constant(true)) {
                            Label {
                                Text(instance.host)
                            } icon: {
                                SimpleAvatarView(url: instance.avatar, type: .instanceAvatar)
                                    .id(instance.avatar)
                            }
                        }
                    default:
                        EmptyView()
                    }
                    Button("Choose Instance...", icon: .lemmy.instance) {
                        navigation.openSheet(.instancePicker(callback: { instance in
                            filter = .instance(instance)
                        }, requiredFeature: requiredFeature))
                    }
                }
            }
        }
    }
}
