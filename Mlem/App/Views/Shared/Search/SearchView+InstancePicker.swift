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
            !isForPersonSearch || (AppState.main.firstApi.fetchedVersion ?? .infinity) >= .v19_4
        }
        
        var body: some View {
            Menu(filter.label, systemImage: Icons.instance) {
                Toggle(
                    "Any Instance",
                    systemImage: Icons.federation,
                    isOn: .init(get: { filter == .any }, set: { _ in filter = .any })
                )
                if allowActiveAccountLocalInstanceSearch {
                    Toggle(isOn: .init(get: { filter == .local }, set: { _ in filter = .local })) {
                        Label {
                            Text(AppState.main.firstApi.host)
                        } icon: {
                            SimpleAvatarView(url: AppState.main.firstSession.instance?.avatar, type: .instance)
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
                                SimpleAvatarView(url: instance.avatar, type: .instance)
                                    .id(instance.avatar)
                            }
                        }
                    } else {
                        EmptyView()
                    }
                default:
                    EmptyView()
                }
                Button("Choose Instance...", systemImage: Icons.instance) {
                    navigation.openSheet(.instancePicker(callback: { instance in
                        filter = .other(instance)
                    }, minimumVersion: isForPersonSearch ? .v19_4 : nil))
                }
            }
        }
    }
}
