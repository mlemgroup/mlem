//
//  SearchView+InstancePicker.swift
//  Mlem
//
//  Created by Sjmarf on 04/10/2024.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    struct InstancePicker: View {
        @Environment(NavigationLayer.self) var navigation
        @Binding var filter: InstanceFilter
        let isForPersonSearch: Bool
        
        var allowActiveAccountLocalInstanceSearch: Bool {
            !isForPersonSearch || (AppState.main.firstApi.fetchedVersion ?? .infinity) >= .v0_19_4
        }
        
        var body: some View {
            Menu(filter.label, icon: .lemmy.instance) {
                Toggle(
                    "Any Instance",
                    icon: .lemmy.federation,
                    isOn: .init(get: { filter == .any }, set: { _ in filter = .any })
                )
                if allowActiveAccountLocalInstanceSearch {
                    Toggle(isOn: .init(get: { filter == .local }, set: { _ in filter = .local })) {
                        Label {
                            Text(AppState.main.firstApi.host)
                        } icon: {
                            SimpleAvatarView(url: AppState.main.firstSession.instance?.avatar, type: .instanceAvatar)
                        }
                    }
                }
                switch filter {
                case let .other(instance):
                    if instance.host != AppState.main.firstApi.host {
                        Toggle(isOn: .constant(true)) {
                            Label {
                                Text(instance.host)
                            } icon: {
                                SimpleAvatarView(url: instance.avatar, type: .instanceAvatar)
                                    .id(instance.avatar)
                            }
                        }
                    } else {
                        EmptyView()
                    }
                default:
                    EmptyView()
                }
                Button("Choose Instance...", icon: .lemmy.instance) {
                    navigation.openSheet(.instancePicker(callback: { instance in
                        filter = .other(instance)
                    }, minimumVersion: isForPersonSearch ? .v0_19_4 : nil))
                }
            }
        }
    }
}
