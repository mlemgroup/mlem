//
//  ModlogView+Filters.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-22.
//  

import Icons
import MlemMiddleware
import SwiftUI

extension ModlogView {
    @ViewBuilder
    func filtersView(communityFilter: CommunityFilter) -> some View {
        ScrollView(.horizontal) {
            HStack {
                typeFilterView()
                    .buttonStyle(.feedFilter(isOn: actionTypeFilter != nil))
                communityFilterView(communityFilter: communityFilter)
                personFilterView(filter: $targetPersonFilter, icon: .lemmy.targetedPerson)
                personFilterView(filter: $moderatorPersonFilter, icon: .lemmy.moderation)
            }
            .padding(.horizontal, Constants.main.standardSpacing)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    func communityFilterView(communityFilter: CommunityFilter) -> some View {
        Button {
            if communityFilter == .any {
                navigation.openSheet(.communityPicker(api: api) { community in
                    self.communityFilter = .community(community)
                })
            } else {
                self.communityFilter = .any
            }
        } label: {
            Label(communityFilter.label, icon: .lemmy.community)
        }
        .buttonStyle(
            .feedFilter(
                isOn: communityFilter != .any,
                icon: communityFilter == .any ? .general.dropDown : .general.close
            )
        )
    }
    
    @ViewBuilder
    func personFilterView(filter: Binding<PersonFilter>, icon: Icon) -> some View {
        Button {
            if filter.wrappedValue == .any {
                navigation.openSheet(.personPicker(api: api) { person in
                    filter.wrappedValue = .person(person)
                })
            } else {
                filter.wrappedValue = .any
            }
        } label: {
            Label(filter.wrappedValue.label, icon: icon)
        }
        .buttonStyle(
            .feedFilter(
                isOn: filter.wrappedValue != .any,
                icon: filter.wrappedValue == .any ? .general.dropDown : .general.close
            )
        )
    }
    
    @ViewBuilder
    func typeFilterView() -> some View {
        Menu(
            String(localized: actionTypeFilter?.label ?? "Action Type"),
            icon: actionTypeFilter?.icon ?? .general.action
        ) {
            Section {
                Toggle(
                    "Any",
                    icon: .general.action,
                    isOn: .init(get: { actionTypeFilter == nil }, set: { _ in actionTypeFilter = nil })
                )
            }
            Section {
                Picker("Post", icon: .lemmy.post, selection: $actionTypeFilter) {
                    typeFilterLabel(.removePost)
                    typeFilterLabel(.lockPost)
                    typeFilterLabel(.pinPost)
                    typeFilterLabel(.purgePost)
                }
                Picker("Comment", icon: .lemmy.comment, selection: $actionTypeFilter) {
                    typeFilterLabel(.removeComment)
                    typeFilterLabel(.purgeComment)
                }
                Picker("Community", icon: .lemmy.community, selection: $actionTypeFilter) {
                    typeFilterLabel(.removeCommunity)
                    typeFilterLabel(.hideCommunity)
                    typeFilterLabel(.updatePersonModeratorStatus)
                    typeFilterLabel(.transferCommunityOwnership)
                    typeFilterLabel(.purgeCommunity)
                }
                Picker("User", icon: .lemmy.person, selection: $actionTypeFilter) {
                    typeFilterLabel(.banPersonFromInstance)
                    typeFilterLabel(.banPersonFromCommunity)
                    typeFilterLabel(.updatePersonModeratorStatus)
                    typeFilterLabel(.updatePersonAdminStatus)
                    typeFilterLabel(.purgePerson)
                }
            }
        }
        .pickerStyle(.menu)
    }
    
    @ViewBuilder
    func typeFilterLabel(_ type: ModlogEntryType) -> some View {
        if type.appliesToCommunity || communityFilter == .any {
            Label(type.contextualLabel.key, icon: type.icon)
                .tag(type)
        }
    }
}
