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
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    switch selectedTab {
                    case .communities:
                        communityFiltersView
                    case .people:
                        personFiltersView
                    case .instances:
                        instanceFiltersView
                    case .posts:
                        postFiltersView
                    case .comments:
                        commentFiltersView
                    }
                }
                .padding(.bottom, 12)
                .padding(.horizontal, Constants.main.standardSpacing)
            }
            .scrollIndicators(.hidden)
            if selectedTab == .communities, communityFilters.instance.isOther {
                Label(
                    "Subscription statuses can't be displayed when using these filters.",
                    systemImage: Icons.warning
                )
                .font(.footnote)
                .foregroundStyle(palette.accent)
                .padding(.bottom, 12)
                .padding(.horizontal, Constants.main.standardSpacing)
            }
        }
        .animation(.easeOut(duration: 0.1), value: filterAnimationHashValue)
    }
    
    @ViewBuilder
    private var communityFiltersView: some View {
        CommunitySearchSortPicker(sort: $communityFilters.sort)
            .buttonStyle(.feedFilter(isOn: communityFilters.sort != .top(.allTime)))
        InstancePicker(filter: $communityFilters.instance, isForPersonSearch: false)
            .buttonStyle(.feedFilter(isOn: communityFilters.instance != .any))
    }
    
    @ViewBuilder
    private var personFiltersView: some View {
        Menu(personFilters.sort.label(timeRangeFormat: .topOnly), systemImage: personFilters.sort.systemImage) {
            Picker("Sort", selection: $personFilters.sort) {
                ForEach(SearchSortType.legacyPersonCases, id: \.self) { item in
                    Label(item.label(timeRangeFormat: .topOnly), systemImage: item.systemImage)
                }
            }
        }
        .buttonStyle(.feedFilter(isOn: personFilters.sort != .top(.allTime)))
        InstancePicker(filter: $personFilters.instance, isForPersonSearch: true)
            .buttonStyle(.feedFilter(isOn: personFilters.instance != .any))
    }
    
    @ViewBuilder
    private var postFiltersView: some View {
        FeedSortPicker(sort: $postFilters.sort)
            .buttonStyle(.feedFilter(isOn: postFilters.sort != .top(.allTime)))
        LocationPicker(filter: $postFilters.location)
            .buttonStyle(.feedFilter(isOn: postFilters.location != .any))
        CreatorPicker(
            api: postFilters.location.instanceStub?.api ?? appState.firstApi,
            creator: $postFilters.creator
        )
    }
    
    @ViewBuilder
    private var commentFiltersView: some View {
//        Menu(commentFilters.sort.label(topFormat: .topOnly), systemImage: commentFilters.sort.systemImage) {
//            Picker("Sort", selection: $commentFilters.sort) {
//                ForEach(ApiSortType.commentSearchCases, id: \.self) { item in
//                    Label(item.label(topFormat: .topOnly), systemImage: item.systemImage)
//                }
//            }
//        }
//        .buttonStyle(.feedFilter(isOn: personFilters.sort != .topAll))
        LocationPicker(filter: $commentFilters.location)
            .buttonStyle(.feedFilter(isOn: commentFilters.location != .any))
        CreatorPicker(
            api: commentFilters.location.instanceStub?.api ?? appState.firstApi,
            creator: $commentFilters.creator
        )
    }
    
    @ViewBuilder
    private var instanceFiltersView: some View {
        Menu(
            String(localized: instanceFilters.sort.label),
            systemImage: instanceFilters.sort.systemImage
        ) {
            Picker("Sort", selection: $instanceFilters.sort) {
                ForEach(InstanceSort.allCases, id: \.self) { sort in
                    Label(String(localized: sort.label), systemImage: sort.systemImage)
                }
            }
            .pickerStyle(.inline)
        }
        .buttonStyle(.feedFilter(isOn: instanceFilters.sort != .score))
    }
}
