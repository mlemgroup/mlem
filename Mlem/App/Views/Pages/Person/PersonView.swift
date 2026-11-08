//
//  PersonView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import Actions
import ComponentViews
import Flow
import Icons
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

struct PersonView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case overview, comments, posts, communities
        
        var id: Self { self }
        var label: LocalizedStringResource {
            switch self {
            case .overview: "Overview"
            case .comments: "Comments"
            case .posts: "Posts"
            case .communities: "Communities"
            }
        }
    }
    
    @Setting(\.post_size) var postSize
    @Setting(\.behavior_internetSpeed) var internetSpeed
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(FiltersTracker.self) var filtersTracker
    @Environment(\.palette) var palette

    let visitContext: VisitHistory.VisitContext?
    
    @State var person: Person
    @State var selectedTab: Tab = .overview
    @State var selectedContentType: PersonContentType = .all
    @State var feedLoader: SingleSourceMixedFeedLoader?
    @State var isLoading: Bool = false
    @State var sort: PersonContentSortType = .new

    let isProfileTab: Bool
    
    init(
        appState: AppState = .main,
        person: Person,
        isProfileTab: Bool = false,
        visitContext: VisitHistory.VisitContext?
    ) {
        self.visitContext = visitContext
        self._person = .init(wrappedValue: person)
        self.isProfileTab = isProfileTab
        
        if person.api === appState.firstApi {
            self._feedLoader = .init(wrappedValue: .init(
                api: appState.firstApi,
                pageSize: internetSpeed.pageSize,
                userId: person.id,
                sortType: .new,
                savedOnly: false,
                prefetchingConfiguration: .forPostSize(postSize)
            ))
        }
    }
    
    var body: some View {
        content
            .id(person.uid)
            .reloadOnAccountSwitch(entity: $person, isLoading: $isLoading) { newPerson in
                feedLoader = .init(
                    api: appState.firstApi,
                    pageSize: internetSpeed.pageSize,
                    userId: newPerson.id,
                    sortType: .new,
                    savedOnly: false,
                    prefetchingConfiguration: .forPostSize(postSize)
                )
            }
            .onAppear {
                preheatFeedLoader()
            }
            .onChange(of: selectedTab) {
                switch selectedTab {
                case .comments: selectedContentType = .comments
                case .posts: selectedContentType = .posts
                default: selectedContentType = .all
                }
            }
            .environment(\.feedContext, .person)
    }
    
    var content: some View {
        content(person: person)
            .externalApiWarning(entity: person, isLoading: isLoading)
            .onAppear {
                logVisit(person)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortPicker
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    SwiftUI.Section {
                        ActionButtons(person: person)
                    }
                }
            }
            .popupAnchor()
            .conditionalNavigationTitle(person.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .themedGroupedBackground()
    }
    
    @ViewBuilder
    func content(person: Person) -> some View {
        FancyScrollView {
            VStack(spacing: 0) {
                VStack(spacing: Constants.main.standardSpacing) {
                    ProfileHeaderView(person, fallback: .personAvatar)
                    flairsView(person: person)
                    bio(person: person)
                }
                .padding([.horizontal], Constants.main.standardSpacing)
                
                VStack(spacing: 0) {
                    personContent(person: person)
                }
            }
        }
        .outdatedFeedPopup(feedLoader: feedLoader, showPopup: selectedTab != .communities)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment(api: .realistic)) {
//        @Previewable @Environment(AppState.self) var appState
//        NavigationStack {
//            PersonView(
//                appState: appState,
//                person: .init(Person2.mock(.realistic(.anteSocial45), api: .realistic)),
//                isProfileTab: true,
//                visitContext: .other
//            )
//        }
//        .previewTabBar(selected: .profile)
//    }
// #endif
