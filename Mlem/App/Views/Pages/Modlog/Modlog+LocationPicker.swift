//
//  Modlog+LocationPicker.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-04.
//

import MlemMiddleware
import SwiftUI

extension ModlogView {
    enum TargetFilter: Equatable {
        case community(any Community)
        case instance(InstanceSummary)
        
        var label: String {
            switch self {
            case let .community(community): community.name
            case let .instance(instanceSummary): instanceSummary.name
            }
        }
        
        var communityValue: (any Community)? {
            switch self {
            case let .community(community): community
            default: nil
            }
        }
        
        static func == (lhs: TargetFilter, rhs: TargetFilter) -> Bool {
            switch (lhs, rhs) {
            case let (.community(lhs), .community(rhs)): lhs === rhs
            case let (.instance(lhs), .instance(rhs)): lhs == rhs
            default: false
            }
        }
    }
    
    struct LocationPicker: View {
        @Environment(AppState.self) var appState
        @Environment(NavigationLayer.self) var navigation
        @Binding var filter: TargetFilter
        
        var body: some View {
            Menu(filter.label, systemImage: Icons.instance) {
                communitySection
                instanceSection
            }
        }
        
        @ViewBuilder
        var communitySection: some View {
            Section {
                switch filter {
                case let .community(community):
                    Toggle(isOn: .constant(true)) {
                        Label {
                            Text(community.name)
                        } icon: {
                            SimpleAvatarView(url: community.avatar, type: .instance)
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
        }
        
        @ViewBuilder
        var instanceSection: some View {
            Section {
                if let myInstance = appState.firstSession.instance {
                    Toggle(
                        isOn: .init(
                            get: { filter.label == appState.firstApi.host },
                            set: { _ in
                                filter = .instance(myInstance.instanceSummary)
                            }
                        )
                    ) {
                        Label {
                            Text(myInstance.name)
                        } icon: {
                            SimpleAvatarView(url: myInstance.avatar, type: .instance)
                        }
                    }
                }
                switch filter {
                case let .instance(instance):
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
                        filter = .instance(instance)
                    }))
                }
            }
        }
    }
}
