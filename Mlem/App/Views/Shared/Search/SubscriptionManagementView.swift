//
//  SubscriptionManagementView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import MlemMiddleware
import SwiftUI

struct SubscriptionManagementView: View {
    @Environment(Palette.self) var palette
    
    var body: some View {
        SearchSheetView(closeButtonLabel: .done) { (community: Community2, _: DismissAction) in
            CommunityListRowBody(community, complications: [.instance, .subscriberCount]) {
                Button {
                    community.toggleSubscribe(feedback: [.haptic])
                } label: {
                    Image(systemName: community.subscribed ? "checkmark.circle.fill" : "plus.circle")
                        .imageScale(.large)
                        .contentTransition(.symbolEffect(.replace, options: .speed(5)))
                        .padding(.trailing, 8)
                        .foregroundStyle(palette.accent)
                }
                .buttonStyle(EmptyButtonStyle())
            }
            .padding(.vertical, 6)
        }
    }
}
