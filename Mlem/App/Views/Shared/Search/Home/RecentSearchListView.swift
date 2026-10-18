//
//  RecentSearchListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct RecentSearchListView: View {
    let visitHistory: VisitHistory

    var body: some View {
        let communities = visitHistory.communities(withContext: .search)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 16)], spacing: 16) {
            ForEach(communities) { community in
                CommunityListRow(community)
            }
        }
    }
}
