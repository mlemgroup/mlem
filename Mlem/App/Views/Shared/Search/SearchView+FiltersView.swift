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
            .buttonStyle(.feedFilter(isOn: communityFilters.sort != .topAll))
        InstancePicker(filter: $communityFilters.instance, isForPersonSearch: false)
            .buttonStyle(.feedFilter(isOn: communityFilters.instance != .any))
    }
    
    @ViewBuilder
    private var personFiltersView: some View {
        Menu(personFilters.sort.label(topFormat: .topOnly), systemImage: personFilters.sort.systemImage) {
            Picker("Sort", selection: $personFilters.sort) {
                ForEach(ApiSortType.personSearchCases, id: \.self) { item in
                    Label(item.label(topFormat: .topOnly), systemImage: item.systemImage)
                }
            }
        }
        .buttonStyle(.feedFilter(isOn: personFilters.sort != .topAll))
        InstancePicker(filter: $personFilters.instance, isForPersonSearch: true)
            .buttonStyle(.feedFilter(isOn: personFilters.instance != .any))
    }
    
    @ViewBuilder
    private var postFiltersView: some View {
        FeedSortPicker(sort: $postFilters.sort)
            .buttonStyle(.feedFilter(isOn: postFilters.sort != .topAll))
        LocationPicker(filter: $postFilters.location)
            .buttonStyle(.feedFilter(isOn: postFilters.location != .any))
        Button(postFilters.creator?.name ?? .init(localized: "Anyone"), systemImage: Icons.person) {
            if postFilters.creator == nil {
                navigation.openSheet(.personPicker(
                    api: postFilters.location.instanceStub?.api ?? appState.firstApi,
                    callback: { person in
                        postFilters.creator = person
                    }
                ))
            } else {
                postFilters.creator = nil
            }
        }
        .buttonStyle(FeedFilterButtonStyle(
            isOn: postFilters.creator != nil,
            systemImage: postFilters.creator == nil ? Icons.dropDownCircleFill : Icons.closeCircleFill
        ))
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
