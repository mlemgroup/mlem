//
//  PersonView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

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
    
    @Setting(\.postSize) var postSize
    
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    @State var person: AnyPerson
    @State private var selectedTab: Tab = .overview
    @State private var selectedContentType: PersonContentType = .all
    @State private var isAtTop: Bool = true
    @State var feedLoader: PersonContentFeedLoader?
    let isProfileTab: Bool
    
    init(person: AnyPerson, isProfileTab: Bool = false) {
        self._person = .init(wrappedValue: person)
        self.isProfileTab = isProfileTab
        
        if let person1 = person.wrappedValue as? any Person1Providing, person1.api === AppState.main.firstApi {
            self._feedLoader = .init(wrappedValue: .init(
                api: AppState.main.firstApi,
                userId: person1.id,
                sortType: .new,
                savedOnly: false,
                prefetchingConfiguration: .forPostSize(postSize)
            ))
            
            preheatFeedLoader()
        }
    }
    
    var body: some View {
        content
            .isAtTopSubscriber(isAtTop: $isAtTop)
            .onChange(of: selectedTab) {
                switch selectedTab {
                case .comments: selectedContentType = .comments
                case .posts: selectedContentType = .posts
                default: selectedContentType = .all
                }
            }
    }
    
    var content: some View {
        ContentLoader(model: person) { proxy in
            if let person = proxy.entity {
                content(person: person)
                    .externalApiWarning(entity: person, isLoading: proxy.isLoading)
                    .toolbar {
                        ToolbarItemGroup(placement: .secondaryAction) {
                            SwiftUI.Section {
                                if person is any Person3Providing, proxy.isLoading {
                                    ProgressView()
                                } else {
                                    MenuButtons { person.menuActions(navigation: navigation) }
                                }
                            }
                        }
                    }
                    .popupAnchor()
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api) { entity in
                if let entity = entity as? any Person1Providing {
                    let response = try await entity.getContent(page: 1, limit: 3)
                    
                    if feedLoader == nil {
                        feedLoader = .init(
                            api: AppState.main.firstApi,
                            userId: response.person.id,
                            sortType: .new,
                            savedOnly: false,
                            prefetchingConfiguration: .forPostSize(postSize)
                        )
                        preheatFeedLoader()
                    } else if let feedLoader, feedLoader.api !== entity.api {
                        Task {
                            await feedLoader.switchUser(api: entity.api, userId: entity.id)
                        }
                    }
                    
                    return response.person
                }
                return try await entity.upgrade()
            }
        }
        .navigationTitle(isAtTop ? "" : (person.wrappedValue.displayName_ ?? person.wrappedValue.name))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func content(person: any Person) -> some View {
        FancyScrollView {
            VStack(spacing: Constants.main.standardSpacing) {
                VStack(spacing: Constants.main.standardSpacing) {
                    ProfileHeaderView(person, fallback: .person)
                    bio(person: person)
                }
                .padding([.horizontal], Constants.main.standardSpacing)
                
                if let person = person as? any Person3Providing {
                    VStack(spacing: 0) {
                        personContent(person: person)
                    }
                    .transition(.opacity)
                } else {
                    VStack(spacing: 0) {
                        Divider()
                        ProgressView()
                            .padding(.top)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: person is any Person3Providing)
        }
        .outdatedFeedPopup(feedLoader: feedLoader, showPopup: selectedTab != .communities)
        .background(palette.groupedBackground)
    }
    
    @ViewBuilder
    func bio(person: any Person) -> some View {
        if let bio = person.description_ {
            Divider()
            VStack(spacing: Constants.main.standardSpacing) {
                let blocks: [BlockNode] = .init(bio)
                if blocks.isSimpleParagraphs, bio.count < 300 {
                    MarkdownText(blocks, configuration: .default)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.main.standardSpacing)
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Markdown(blocks, configuration: .default)
                        .padding(.horizontal, Constants.main.standardSpacing)
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top, Constants.main.halfSpacing)
        } else {
            dateLabel(person: person)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    func dateLabel(person: any Person) -> some View {
        ProfileDateView(profilable: person)
            .padding(.horizontal, Constants.main.standardSpacing)
            .padding(.vertical, 2)
    }
    
    @ViewBuilder
    func personContent(person: any Person3Providing) -> some View {
        Section {
            switch selectedTab {
            case .communities:
                communitiesTab(person: person)
            default:
                if let feedLoader {
                    if isProfileTab, selectedTab == .overview || selectedTab == .posts {
                        Button("New Post", systemImage: "plus") {
                            navigation.openSheet(.createPost(community: nil))
                        }
                        .buttonStyle(.capsule)
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                    }
                    PersonContentGridView(feedLoader: feedLoader, contentType: $selectedContentType)
                } else {
                    ProgressView()
                }
            }
        } header: {
            BubblePicker(
                tabs(person: person),
                selected: $selectedTab,
                withDividers: [],
                label: \.label,
                value: { tab in
                    switch tab {
                    case .posts:
                        person.postCount
                    case .comments:
                        person.commentCount
                    case .communities:
                        person.moderatedCommunities.count
                    default:
                        nil
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    func communitiesTab(person: any Person) -> some View {
        VStack(spacing: Constants.main.halfSpacing) {
            ForEach(person.moderatedCommunities_ ?? []) { community in
                CommunityListRow(community)
            }
        }
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
}
