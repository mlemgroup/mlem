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
        @Environment(NavigationLayer.self) var navigation
        @Binding var filter: LocationFilter
        
        var body: some View {
            Menu(filter.label, systemImage: filter.systemImage) {
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
                                SimpleAvatarView(url: community.avatar, type: .community)
                                    .id(community.avatar)
                            }
                        }
                    default:
                        EmptyView()
                    }
                    Button("Choose Community...", systemImage: Icons.community) {
                        navigation.openSheet(.communityPicker(callback: { community in
                            filter = .community(community)
                        }))
                    }
                }
                Section {
                    if !((AppState.main.firstSession as? UserSession)?.subscriptions.communities.isEmpty ?? true) {
                        Toggle(
                            "Subscribed",
                            systemImage: Icons.subscribedFeed,
                            isOn: .init(get: { filter == .subscribed }, set: { _ in filter = .subscribed })
                        )
                    }
                    if !((AppState.main.firstSession as? UserSession)?.person?.moderatedCommunities.isEmpty ?? true) {
                        Toggle(
                            "Moderated",
                            systemImage: Icons.moderation,
                            isOn: .init(get: { filter == .moderated }, set: { _ in filter = .moderated })
                        )
                    }
                }
                Section {
                    Toggle(isOn: .init(get: { filter == .localInstance }, set: { _ in filter = .localInstance })) {
                        Label {
                            Text(AppState.main.firstApi.host ?? "Local")
                        } icon: {
                            SimpleAvatarView(url: AppState.main.firstSession.instance?.avatar, type: .instance)
                        }
                    }
                    switch filter {
                    case let .instance(instance):
                        Toggle(isOn: .constant(true)) {
                            Label {
                                Text(instance.host)
                            } icon: {
                                SimpleAvatarView(url: instance.avatar, type: .instance)
                                    .id(instance.avatar)
                            }
                        }
                    default:
                        EmptyView()
                    }
                    Button("Choose Instance...", systemImage: Icons.instance) {
                        navigation.openSheet(.instancePicker(callback: { instance in
                            filter = .instance(instance)
                        }))
                    }
                }
            }
        }
    }
}
