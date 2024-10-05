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
                    case .users:
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
        FeedSortPicker(
            sort: $communityFilters.sort,
            filters: [.availableOnInstance, .communitySearchable]
        )
        .buttonStyle(FilterButtonStyle(isOn: communityFilters.sort != .topAll))
        InstancePicker(filter: $communityFilters.instance, isForPersonSearch: false)
            .buttonStyle(FilterButtonStyle(isOn: communityFilters.instance != .any))
    }
    
    @ViewBuilder
    private var personFiltersView: some View {
        FeedSortPicker(
            sort: $personFilters.sort,
            filters: [.availableOnInstance, .personSearchable]
        )
        .buttonStyle(FilterButtonStyle(isOn: personFilters.sort != .topAll))
        InstancePicker(filter: $personFilters.instance, isForPersonSearch: true)
            .buttonStyle(FilterButtonStyle(isOn: personFilters.instance != .any))
    }
    
    @ViewBuilder
    private var postFiltersView: some View {
        FeedSortPicker(
            sort: $postFilters.sort,
            filters: [.availableOnInstance]
        )
        .buttonStyle(FilterButtonStyle(isOn: postFilters.sort != .topAll))
        LocationPicker(filter: $postFilters.location)
            .buttonStyle(FilterButtonStyle(isOn: postFilters.location != .any))
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
        .buttonStyle(FilterButtonStyle(
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
        .buttonStyle(FilterButtonStyle(isOn: instanceFilters.sort != .score))
    }
    
    private struct FilterButtonStyle: ButtonStyle {
        @Environment(Palette.self) var palette
        
        let isOn: Bool
        var systemImage: String? = Icons.dropDownCircleFill
        
        @ScaledMetric(relativeTo: .footnote) var height: CGFloat = 32
        
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 4) {
                configuration.label
                if let systemImage {
                    Image(systemName: systemImage)
                        .symbolRenderingMode(.hierarchical)
                        .padding(.trailing, 8)
                }
            }
            .frame(height: height)
            .foregroundStyle(isOn ? palette.selectedInteractionBarItem : palette.accent)
            .font(.footnote)
            .padding(systemImage == nil ? .horizontal : .leading, 12)
            .background(
                Capsule()
                    .fill(isOn ? palette.accent : .clear)
                    .strokeBorder(palette.accent, lineWidth: isOn ? 0 : 1)
            )
        }
    }
}
