//
//  PersonView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import ComponentViews
import Flow
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

// swiftlint:disable:next type_body_length
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
    
    @State var person: AnyPerson
    @State private var selectedTab: Tab = .overview
    @State private var selectedContentType: PersonContentType = .all
    @State var feedLoader: PersonContentFeedLoader?
    @State var isAdmin: Bool
    @State var upgraded: Bool = false
    let isProfileTab: Bool
    
    init(
        appState: AppState = .main,
        person: AnyPerson,
        isProfileTab: Bool = false,
        visitContext: VisitHistory.VisitContext?
    ) {
        self.visitContext = visitContext
        self._person = .init(wrappedValue: person)
        self._isAdmin = .init(wrappedValue: person.wrappedValue.isAdmin_ ?? false)
        self.isProfileTab = isProfileTab
        
        if let person1 = person.wrappedValue as? any Person1Providing, person1.api === appState.firstApi {
            self._feedLoader = .init(wrappedValue: .init(
                api: appState.firstApi,
                pageSize: internetSpeed.pageSize,
                userId: person1.id,
                sortType: .new,
                savedOnly: false,
                prefetchingConfiguration: .forPostSize(postSize)
            ))
        }
    }
    
    var body: some View {
        content
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
            .onChange(of: person.wrappedValue.isAdmin_, initial: false) {
                // track changes to the upgraded model while ignoring upgrade-related state changes
                if upgraded {
                    isAdmin = person.wrappedValue.isAdmin_ ?? isAdmin
                }
            }
            .environment(\.feedContext, .person)
    }
    
    var content: some View {
        ContentLoader(model: person) { proxy in
            if let person = proxy.entity {
                content(person: person)
                    .externalApiWarning(entity: person, isLoading: proxy.isLoading)
                    .onChange(of: (person as? any Person2Providing)?.person2 == nil, initial: true) {
                        if let person2 = (person as? any Person2Providing)?.person2 {
                            logVisit(person2)
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .secondaryAction) {
                            SwiftUI.Section {
                                if person is any Person3Providing, proxy.isLoading {
                                    ProgressView()
                                } else {
                                    MenuButtons { person.menuActions(appState: appState, navigation: navigation, community: nil) }
                                }
                            }
                        }
                    }
                    .popupAnchor()
            } else if let error = proxy.error {
                ErrorView(.init(error: error))
            } else {
                ProgressView()
                    .tint(.themedSecondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api) { entity in
                if let entity = entity as? any Person1Providing {
                    if feedLoader == nil {
                        feedLoader = .init(
                            api: AppState.main.firstApi,
                            pageSize: internetSpeed.pageSize,
                            userId: entity.id,
                            sortType: .new,
                            savedOnly: false,
                            prefetchingConfiguration: .forPostSize(postSize)
                        )
                        preheatFeedLoader()
                    } else if let feedLoader, feedLoader.api !== entity.api {
                        Task {
                            await feedLoader.changeUser(api: entity.api, context: filtersTracker.filterContext, userId: entity.id)
                        }
                    }
                    
                    let response = try await entity.getContent(page: 1, limit: 1)
                    return response.person
                }
                return try await entity.upgrade()
            }
            // This prevents the admin flair from disappearing if the `ContentLoader`
            // switches from an external ApiClient to the active ApiClient, e.g. when
            // navigating to `PersonView` from the administrator list in `InstanceView`.
            if model.wrappedValue.isAdmin_ ?? false {
                isAdmin = true
            }
            
            upgraded = true
        }
        .conditionalNavigationTitle(person.wrappedValue.displayName_ ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .themedGroupedBackground()
    }
    
    @ViewBuilder
    func content(person: any Person) -> some View {
        FancyScrollView {
            VStack(spacing: 0) {
                VStack(spacing: Constants.main.standardSpacing) {
                    ProfileHeaderView(person, fallback: .personAvatar)
                    flairsView(person: person)
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
                        ProgressView()
                            .padding(.top)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: person is any Person3Providing)
        }
        .outdatedFeedPopup(feedLoader: feedLoader, showPopup: selectedTab != .communities)
    }
    
    @ViewBuilder
    func bio(person: any Person) -> some View {
        if let bio = person.description_ {
            VStack(spacing: Constants.main.standardSpacing) {
                let blocks: [BlockNode] = .init(bio)
                if blocks.isSimpleParagraphs, bio.count < 300 {
                    MarkdownText(blocks, configuration: .default(palette: palette))
                        .multilineTextAlignment(.center)
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Markdown(blocks, configuration: .default(palette: palette))
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(Constants.main.standardSpacing)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        } else {
            dateLabel(person: person)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, Constants.main.halfSpacing)
        }
    }
    
    @ViewBuilder
    func flairsView(person: any Person) -> some View {
        if person.isBot || person.isMlemDeveloper || isAdmin {
            HFlow(spacing: Constants.main.halfSpacing) {
                if person.isMlemDeveloper {
                    Label("Mlem Developer", systemImage: Icons.developerFlair)
                        .tint(.themedColorfulAccent(4))
                }
                if isAdmin {
                    Label("\(person.host) Administrator", systemImage: Icons.administrationFill)
                        .tint(.themedAdministration)
                }
                if person.isBot {
                    Label("Bot Account", icon: .lemmy.botFlair)
                        .tint(.themedColorfulAccent(5))
                }
            }
            .labelStyle(FlairLabelStyle())
        }
        if person.bannedFromInstance {
            banFlairView(person: person)
        }
    }
    
    @ViewBuilder
    func banFlairView(person: any Person) -> some View {
        HStack {
            Image(icon: .lemmy.bannedFromInstance)
                .imageScale(.large)
                .symbolVariant(.fill)
            switch person.instanceBan {
            case let .temporarilyBanned(expires: expires):
                Text("\(person.name) is banned from \(person.api.host) until \(expires.formatted(date: .numeric, time: .omitted)).")
            default:
                Text("\(person.name) is permanently banned from \(person.api.host).")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.themedNegative)
        .padding(Constants.main.standardSpacing)
        .background(.themedNegative.opacity(0.2), in: .rect(cornerRadius: Constants.main.standardSpacing))
    }
    
    @ViewBuilder
    func dateLabel(person: any Person) -> some View {
        ProfileDateView(profilable: person)
            .padding(.horizontal, Constants.main.standardSpacing)
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
                        Button("New Post", icon: .general.add) {
                            navigation.openSheet(.createPost(community: nil, feedLoader: feedLoader))
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

private struct FlairLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon
                .imageScale(.small)
            configuration.title
        }
        .font(.footnote)
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .foregroundStyle(.tint)
        .background(.tint.opacity(0.2), in: .capsule)
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment(api: .realistic)) {
        @Previewable @Environment(AppState.self) var appState
        NavigationStack {
            PersonView(
                appState: appState,
                person: .init(Person2.mock(.realistic(.anteSocial45), api: .realistic)),
                isProfileTab: true,
                visitContext: .other
            )
        }
        .previewTabBar(selected: .profile)
    }
#endif
