//
//  RecentSearchListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct RecentSearchListView: View {
    @Environment(NavigationLayer.self) var navigation

    let visitHistory: VisitHistory

    var body: some View {
        let communities = visitHistory.communities(withContext: .search)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
            ForEach(communities) { community in
                Button {
                    navigation.push(.community(community, visitContext: .other))
                } label: {
                    CommunityListRowBody(community, complications: [.type])
                }
                .buttonStyle(.empty)
                .padding(.vertical, 6)
                .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
                .contentShape(.contextMenuPreview, .rect(cornerRadius: 16))
                .contextMenu(community: community)
                .popupAnchor()
                .paletteBorder(cornerRadius: 16)
            }
        }
    }
}
