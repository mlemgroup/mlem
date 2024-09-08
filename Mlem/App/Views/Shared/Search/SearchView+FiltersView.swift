//
//  SearchView+FiltersView.swift
//  Mlem
//
//  Created by Sjmarf on 08/09/2024.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    @ViewBuilder
    var filtersView: some View {
        ScrollView(.horizontal) {
            HStack {
                communityFiltersView
            }
            .padding(.vertical, 12)
            .padding(.horizontal, Constants.main.standardSpacing)
        }
        .buttonStyle(FilterButtonStyle())
        .background(palette.accent.opacity(0.1))
    }
    
    @ViewBuilder
    private var communityFiltersView: some View {
        FeedSortPicker(
            sort: $communityFilters.sort,
            filters: [.availableOnInstance, .communityAndPersonSearchable]
        )
    }
    
    private struct FilterButtonStyle: ButtonStyle {
        @Environment(Palette.self) var palette
        
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 4) {
                configuration.label
                Image(systemName: "chevron.down.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .padding([.vertical, .trailing], 8)
            }
            .foregroundStyle(palette.selectedInteractionBarItem)
            .font(.footnote)
            .padding(.leading, 12)
            .background(palette.accent, in: .capsule)
        }
    }
    
    @Observable
    class CommunityFilters {
        var sort: ApiSortType
        
        init(sort: ApiSortType) {
            self.sort = sort
        }
    }
    
    @Observable
    class PersonFilters {
        var sort: ApiSortType
        
        init(sort: ApiSortType) {
            self.sort = sort
        }
    }
}
