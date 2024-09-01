//
//  SubscriptionListItemView.swift
//  Mlem
//
//  Created by Sjmarf on 07/08/2024.
//

import MlemMiddleware
import SwiftUI

struct SubscriptionListItemView: View {
    @Environment(NavigationLayer.self) private var navigation

    @Setting(\.subscriptionSort) private var sort
    @Setting(\.subscriptionInstanceLocation) private var savedInstanceLocation

    let community: Community2
    let section: SubscriptionListSection
    let sectionIndicesShown: Bool
    
    var body: some View {
        NavigationLink(.community(community)) {
            HStack(spacing: 15, content: label)
        }
        .contextMenu { community.menuActions(feedback: [.toast], navigation: navigation) }
        .swipeActions(edge: .trailing) {
            Button("Unsubscribe", systemImage: Icons.failure) {
                community.toggleSubscribe(feedback: [.toast])
            }
            .labelStyle(.iconOnly)
            .tint(.red)
        }
        .padding(.trailing, sectionIndicesShown ? 5 : 0)
    }
    
    @ViewBuilder
    private func label() -> some View {
        switch instanceLocation(section: section) {
        case .trailing:
            CircleCroppedImageView(community, size: 28)
                .frame(width: 28, height: 28)
            (
                Text(community.name)
                    + Text(verbatim: "@\(community.host ?? "unknown")")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            )
            .lineLimit(1)
        case .bottom:
            CircleCroppedImageView(community, size: 36)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 0) {
                Text(community.name)
                    .lineLimit(1)
                Text(verbatim: "@\(community.host ?? "")")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        case .disabled:
            CircleCroppedImageView(community, size: 28)
                .frame(width: 28, height: 28)
            Text(community.name)
                .lineLimit(1)
        }
    }
    
    private func instanceLocation(section: SubscriptionListSection) -> InstanceLocation {
        switch sort {
        case .alphabetical:
            savedInstanceLocation
        case .instance:
            section.label == String(localized: "Other") ? .trailing : .disabled
        }
    }
}
