//
//  Modlog+LocationPicker.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-04.
//

import MlemMiddleware
import SwiftUI

extension ModlogView {
    enum TargetFilter {
        case community(any Community)
        case instance(InstanceSummary)
        
        var label: String {
            switch self {
            case let .community(community): community.name
            case let .instance(instanceSummary): instanceSummary.name
            }
        }
    }
    
    struct LocationPicker: View {
        @Environment(AppState.self) var appState
        @Environment(NavigationLayer.self) var navigation
        @Binding var filter: TargetFilter
        let isForPersonSearch: Bool
        
        var allowActiveAccountLocalInstanceSearch: Bool {
            !isForPersonSearch || (AppState.main.firstApi.fetchedVersion ?? .infinity) >= .v19_4
        }
        
        var body: some View {
            Menu(filter.label, systemImage: Icons.instance) {
                if allowActiveAccountLocalInstanceSearch {
                    Toggle(
                        isOn: .init(
                            get: { filter.label == appState.firstApi.host },
                            set: { _ in filter = appState.firstSession.instance }
                        )
                    ) {
                        Label {
                            Text(AppState.main.firstApi.host ?? String(localized: "Local"))
                        } icon: {
                            SimpleAvatarView(url: AppState.main.firstSession.instance?.avatar, type: .instance)
                        }
                    }
                }
                switch filter {
                case let .other(instance):
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
                        filter = .other(instance)
                    }, minimumVersion: isForPersonSearch ? .v19_4 : nil))
                }
            }
        }
    }
}
