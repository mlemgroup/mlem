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
        }
        .animation(.easeOut(duration: 0.1), value: filterAnimationHashValue)
    }
    
    @ViewBuilder
    private var communityFiltersView: some View {
        if let communityFilters {
            CommunitySearchSortPicker(sort: Binding(
                get: { communityFilters.sort }, set: { self.communityFilters?.sort = $0 }
            ))
            .buttonStyle(.feedFilter(isOn: !communityFilters.isDefault))
            InstancePicker(
                filter: Binding(get: { communityFilters.instance }, set: { self.communityFilters?.instance = $0 }),
                requiredFeature: .searchLocalCommunities
            )
            .buttonStyle(.feedFilter(isOn: communityFilters.instance != .any))
        }
    }
    
    @ViewBuilder
    private var personFiltersView: some View {
        if let personFilters {
            Menu(personFilters.sort.label, icon: personFilters.sort.icon) {
                Picker("Sort", selection: Binding(
                    get: { personFilters.sort }, set: { self.personFilters?.sort = $0 }
                )) {
                    let sortTypes = PersonSortType.allCases.filter {
                        appState.firstApi.supports(.personSortType($0), defaultValue: true)
                    }
                    ForEach(sortTypes, id: \.self) { item in
                        Label(item.label, icon: item.icon)
                    }
                }
            }
            .buttonStyle(.feedFilter(isOn: !personFilters.isDefault))
            InstancePicker(
                filter: Binding(get: { personFilters.instance }, set: { self.personFilters?.instance = $0 }),
                requiredFeature: .searchLocalPeople
            )
            .buttonStyle(.feedFilter(isOn: personFilters.instance != .any))
        }
    }
    
    @ViewBuilder
    private var postFiltersView: some View {
        if let postFilters {
            FeedSortPicker(sort: Binding(get: { postFilters.sort }, set: { self.postFilters?.sort = $0 }))
                .buttonStyle(.feedFilter(isOn: postFilters.sort != .top(.allTime)))
            LocationPicker(filter: Binding(get: { postFilters.location }, set: { self.postFilters?.location = $0 }))
                .buttonStyle(.feedFilter(isOn: postFilters.location != .any))
            CreatorPicker(
                api: postFilters.location.instanceStub?.api ?? appState.firstApi,
                creator: Binding(get: { postFilters.creator }, set: { self.postFilters?.creator = $0 })
            )
        }
    }
    
    @ViewBuilder
    private var commentFiltersView: some View {
        Menu(commentFilters.sort.label(timeRangeFormat: .topOnly), icon: commentFilters.sort.icon) {
            Picker("Sort", selection: $commentFilters.sort) {
                ForEach(CommentSortType.legacyCases, id: \.self) { item in
                    Label(item.label(timeRangeFormat: .topOnly), icon: item.icon)
                }
            }
        }
        .buttonStyle(.feedFilter(isOn: commentFilters.sort != .top(.allTime)))
        LocationPicker(filter: $commentFilters.location, requiredFeature: .searchLocalComments)
            .buttonStyle(.feedFilter(isOn: commentFilters.location != .any))
        CreatorPicker(
            api: commentFilters.location.instanceStub?.api ?? appState.firstApi,
            creator: $commentFilters.creator
        )
    }
    
    @ViewBuilder
    private var instanceFiltersView: some View {
        Menu(
            instanceFilters.sort.label,
            icon: instanceFilters.sort.icon
        ) {
            Picker("Sort", selection: $instanceFilters.sort) {
                ForEach(InstanceSort.allCases, id: \.self) { sort in
                    Label(sort.label.key, icon: sort.icon)
                }
            }
            .pickerStyle(.inline)
        }
        .buttonStyle(.feedFilter(isOn: instanceFilters.sort != .score))
    }
}
