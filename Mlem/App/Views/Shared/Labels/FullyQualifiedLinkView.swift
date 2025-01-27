//
//  FullyQualifiedLinkView.swift
//  Mlem
//
//  Created by Sjmarf on 01/06/2024.
//

import MlemMiddleware
import SwiftUI

struct FullyQualifiedLinkView: View {
    @Environment(NavigationLayer.self) private var navigation
    
    let entity: (any FullyQualifiedLabelView.Entity)?
    let avatarFallback: FixedImageView.Fallback
    let labelStyle: FullyQualifiedLabelStyle
    var showAvatar: Bool = true
    var showInstance: Bool = true
    var blurred: Bool = false
    
    @State private var id = UUID()
    
    var body: some View {
        Button {
            if let person = entity as? any PersonStubProviding {
                navigation.push(.person(person))
            } else if let community = entity as? any CommunityStubProviding {
                navigation.push(.community(community))
            }
        } label: {
            FullyQualifiedLabelView(
                entity: entity,
                avatarFallback: avatarFallback,
                labelStyle: labelStyle,
                showAvatar: showAvatar,
                showInstance: showInstance,
                blurred: blurred
            )
        }
        .buttonStyle(.plain)
        .id(id)
    }
}

extension FullyQualifiedLinkView {
    init(
        _ entity: (any Person)?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool = true,
        showInstance: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .person,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            blurred: blurred
        )
    }
    
    init(
        _ entity: (any Community)?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool = true,
        showInstance: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .community,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            blurred: blurred
        )
    }
    
    init(
        _ entity: UserAccount?,
        labelStyle: FullyQualifiedLabelStyle,
        showAvatar: Bool = true,
        showInstance: Bool = true,
        blurred: Bool = false
    ) {
        self.init(
            entity: entity,
            avatarFallback: .person,
            labelStyle: labelStyle,
            showAvatar: showAvatar,
            showInstance: showInstance,
            blurred: blurred
        )
    }
}
