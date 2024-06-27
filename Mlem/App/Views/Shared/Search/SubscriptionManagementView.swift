//
//  SubscriptionManagementView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import MlemMiddleware
import SwiftUI

struct SubscriptionManagementView: View {
    var body: some View {
        SearchSheetView { (community: Community2, _: DismissAction) in
            HStack {
                CommunityListRowBody(community)
                Button {
                    community.toggleSubscribe()
                } label: {
                    Image(systemName: community.subscribed ? "checkmark.circle.fill" : "plus.circle")
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.default, value: community.subscribed)
                }
            }
            .padding(.vertical, 6)
        }
    }
}
