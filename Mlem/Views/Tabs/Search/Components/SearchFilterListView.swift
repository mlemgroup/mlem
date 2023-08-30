//
//  FilterList.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct SearchFilterListView: View {
    
    @EnvironmentObject var searchModel: SearchModel
    
    var filters: [SearchFilter?]
    
    let active: Bool
    let shouldAnimate: Bool
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(Array(filters.enumerated()), id: \.offset) { _, filter in
                    if let filter = filter {
                        SearchFilterView(filter: filter, active: active, shouldAnimate: shouldAnimate)
                    } else {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
    }
}
