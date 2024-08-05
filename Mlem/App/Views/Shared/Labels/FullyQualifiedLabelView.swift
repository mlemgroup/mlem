//
//  FullyQualifiedLabelView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

enum FullyQualifiedLabelStyle {
    case small
    case medium
    case large
    
    var avatarSize: CGFloat {
        switch self {
        case .small: AppConstants.smallAvatarSize
        case .medium: AppConstants.mediumAvatarSize
        case .large: AppConstants.largeAvatarSize
        }
    }
    
    var avatarResolution: Int {
        switch self {
        case .small: 32
        case .medium: 64
        case .large: 96
        }
    }
    
    var instanceLocation: InstanceLocation {
        switch self {
        case .small: .trailing
        case .medium: .trailing
        case .large: .bottom
        }
    }
}

/// View for rendering fully qualified labels (i.e., user or community names)
struct FullyQualifiedLabelView: View {
    @Environment(\.postContext) var postContext: (any Post1Providing)?
    @Environment(\.commentContext) var commentContext: (any Comment1Providing)?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?

    let entity: (any CommunityOrPersonStub & Profile1Providing)?
    let labelStyle: FullyQualifiedLabelStyle
    let showAvatar: Bool
    
    var fallback: FixedImageView.Fallback {
        if entity is any CommunityStubProviding {
            return .community
        }
        if entity is any PersonStubProviding {
            return .person
        }
        return .image
    }
    
    var body: some View {
        HStack(spacing: AppConstants.halfSpacing) {
            if showAvatar {
                CircleCroppedImageView(
                    url: entity?.avatar?.withIconSize(labelStyle.avatarResolution),
                    fallback: fallback,
                    showProgress: false
                )
                .frame(width: labelStyle.avatarSize, height: labelStyle.avatarSize)
            }
            HStack(spacing: 2) {
                ForEach(flairs(), id: \.self) { flair in
                    Image(systemName: flair.icon)
                        .foregroundStyle(flair.color)
                }
            }
            .imageScale(.small)
            
            FullyQualifiedNameView(name: entity?.name, instance: entity?.host, instanceLocation: labelStyle.instanceLocation)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
    
    func flairs() -> [PersonFlair] {
        guard let person = entity as? any Person else { return [] }
        let flairs = person.flairs(
            interactableContext: (commentContext as? any Comment2Providing) ?? (postContext as? any Post2Providing),
            communityContext: communityContext as? any Community3Providing
        )
        return PersonFlair.allCases.filter { flairs.contains($0) }
    }
    
    var accessibilityLabel: String {
        guard let entity, let fullName = entity.fullName else { return String(localized: "Loading...") }
        let flairs = flairs()
        if !flairs.isEmpty {
            return "\(fullName), " + flairs.map { String(localized: $0.label) }.joined(separator: ", ")
        } else {
            return fullName
        }
    }
}
