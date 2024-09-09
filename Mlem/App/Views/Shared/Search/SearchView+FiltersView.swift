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
                    }
                }
                .padding(.vertical, 12)
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
        .background(palette.accent.opacity(0.1))
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
    
    private struct InstancePicker: View {
        @Environment(NavigationLayer.self) var navigation
        @Binding var filter: InstanceFilter
        let isForPersonSearch: Bool
        
        var allowActiveAccountLocalInstanceSearch: Bool {
            !isForPersonSearch || (AppState.main.firstApi.fetchedVersion ?? .infinity) >= .v19_4
        }
        
        var body: some View {
            Menu("Instance: \(filter.label)", systemImage: Icons.instance) {
                Toggle(
                    "Any",
                    systemImage: "point.3.filled.connected.trianglepath.dotted",
                    isOn: .init(get: { filter == .any }, set: { _ in filter = .any })
                )
                if allowActiveAccountLocalInstanceSearch {
                    Toggle(isOn: .init(get: { filter == .local }, set: { _ in filter = .local })) {
                        Label {
                            Text(AppState.main.firstApi.host ?? String(localized: "Local"))
                        } icon: {
                            SimpleAvatarView(url: AppState.main.firstSession.instance?.avatar, type: .instance)
                        }
                    }
                }
                Toggle(isOn: .init(get: { filter.isOther }, set: { _ in
                    navigation.openSheet(.instancePicker(callback: { instance in
                        filter = .other(instance)
                    }, minimumVersion: isForPersonSearch ? .v19_4 : nil))
                })) {
                    Label {
                        Text(otherLabel)
                    } icon: {
                        if let otherIcon {
                            SimpleAvatarView(url: otherIcon, type: .instance)
                                .id(otherIcon)
                        }
                    }
                }
            }
        }
        
        var otherLabel: String {
            if allowActiveAccountLocalInstanceSearch {
                switch filter {
                case let .other(instance):
                    .init(localized: "Other (\(instance.host))")
                default:
                    .init(localized: "Other...")
                }
            } else {
                switch filter {
                case let .other(instance):
                    instance.host
                default:
                    .init(localized: "Choose...")
                }
            }
        }
        
        var otherIcon: URL? {
            switch filter {
            case let .other(instance):
                instance.avatar
            default:
                nil
            }
        }
    }
    
    private struct FilterButtonStyle: ButtonStyle {
        @Environment(Palette.self) var palette
        
        let isOn: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 4) {
                configuration.label
                Image(systemName: "chevron.down.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .padding([.vertical, .trailing], 8)
            }
            .foregroundStyle(isOn ? palette.selectedInteractionBarItem : palette.accent)
            .font(.footnote)
            .padding(.leading, 12)
            .background(
                Capsule()
                    .fill(isOn ? palette.accent : .clear)
                    .strokeBorder(palette.accent, lineWidth: isOn ? 0 : 1)
            )
        }
    }
    
    enum InstanceFilter: Hashable {
        case any, local, other(InstanceSummary)
        
        var label: String {
            switch self {
            case .any: .init(localized: "Any")
            case .local: AppState.main.firstApi.host ?? .init(localized: "Local")
            case let .other(instance): instance.host
            }
        }
        
        var isOther: Bool {
            switch self {
            case .other: true
            default: false
            }
        }
    }
    
    @Observable
    class CommunityFilters {
        var sort: ApiSortType = .topAll
        var instance: InstanceFilter = .any
        
        init() {}
    }
    
    @Observable
    class PersonFilters {
        var sort: ApiSortType = .topAll
        var instance: InstanceFilter = .any
        
        init() {}
    }
    
    @Observable
    class InstanceFilters {
        var sort: InstanceSort = .score
        
        init() {}
    }
}
