//
//  InstanceResultView.swift
//  Mlem
//
//  Created by Sjmarf on 22/01/2024.
//

import Dependencies
import SwiftUI

enum InstanceComplication: CaseIterable {
    case type, version, users
}

extension [InstanceComplication] {
    static let withTypeLabel: [InstanceComplication] = [.type, .version, .users]
    static let withoutTypeLabel: [InstanceComplication] = [.version, .users]
}

struct InstanceResultView: View {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.hapticManager) var hapticManager
    
    let instance: InstanceModel
    let swipeActions: SwipeConfiguration?
    let complications: [InstanceComplication]
    
    init(
        _ instance: InstanceModel,
        complications: [InstanceComplication] = .withoutTypeLabel,
        swipeActions: SwipeConfiguration? = nil
    ) {
        self.instance = instance
        self.complications = complications
        self.swipeActions = swipeActions
    }

    var caption: String {
        var parts: [String] = []
        if complications.contains(.type) {
            parts.append("Instance")
        }
        if complications.contains(.version), let version = instance.version {
            parts.append(String(describing: version))
        }
        return parts.joined(separator: " ∙ ")
    }
    
    var body: some View {
        NavigationLink(value: AppRoute.instance(instance)) {
            HStack(spacing: 10) {
                AvatarView(instance: instance, avatarSize: 48, iconResolution: .fixed(128))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(instance.name)
                        .lineLimit(1)
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if complications.contains(.users), let userCount = instance.userCount {
                    HStack(spacing: 5) {
                        Text(abbreviateNumber(userCount))
                            .monospacedDigit()
                        Image(systemName: Icons.personFill)
                    }
                    .foregroundStyle(.secondary)
                }
                Image(systemName: Icons.forward)
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .background(.background)
        .draggable(instance.url) {
            HStack {
                AvatarView(instance: instance, avatarSize: 24)
                Text(instance.name)
            }
            .padding(8)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .addSwipeyActions(swipeActions ?? .init())
        .contextMenu {
            ForEach(instance.menuFunctions()) { item in
                MenuButton(menuFunction: item, confirmDestructive: nil)
            }
        }
    }
}
