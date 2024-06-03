//
//  FullyQualifiedLinkView.swift
//  Mlem
//
//  Created by Sjmarf on 01/06/2024.
//

import MlemMiddleware
import SwiftUI

struct FullyQualifiedLinkView: View {
    @Environment(NavigationLayer.self) var navigation
    
    let entity: (any CommunityOrPersonStub & Profile2Providing)?
    let labelStyle: FullyQualifiedLabelStyle
    let showAvatar: Bool
    
    var body: some View {
        Button {
            if let person = entity as? any PersonStubProviding {
                navigation.push(.person(PersonStub(api: AppState.main.firstApi, actorId: person.actorId)))
            }
        } label: {
            FullyQualifiedLabelView(entity: entity, labelStyle: labelStyle, showAvatar: showAvatar)
        }
        .buttonStyle(.plain)
    }
}
