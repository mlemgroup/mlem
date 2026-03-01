//
//  PersonView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import Actions
import ComponentViews
import Flow
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
    @State private var selectedTab: Tab = .overview
    @State private var selectedContentType: PersonContentType = .all
    @State var feedLoader: SingleSourceMixedFeedLoader?
    @State var isLoading: Bool = false

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
//            .onChange(of: person.moderatedCommunities.value_?.isEmpty) {
//                if selectedTab == .communities && person.moderatedCommunities.value_?.isEmpty ?? false {
//                    selectedTab = .overview
//                }
//            }
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
    
    @ViewBuilder
    func bio(person: Person) -> some View {
        if let bio = person.description {
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
    func flairsView(person: Person) -> some View {
        if person.isBot || person.isMlemDeveloper || (person.isAdmin.value ?? false) || person.note != nil {
            HFlow(spacing: Constants.main.halfSpacing) {
                if person.isMlemDeveloper {
                    Label("Mlem Developer", systemImage: Icons.developerFlair)
                        .tint(.themedColorfulAccent(4))
                }
                if person.isAdmin.value ?? false {
                    Label("\(person.host) Administrator", systemImage: Icons.administrationFill)
                        .tint(.themedAdministration)
                }
                if person.isBot {
                    Label("Bot Account", icon: .lemmy.botFlair)
                        .tint(.themedColorfulAccent(5))
                }
                if let note = person.note {
                    Label(note, icon: .lemmy.note)
                        .tint(.themedNeutralAccent)
                        .onTapGesture {
                            navigation.openSheet(.editNote(person))
                        }
                }
                
            }
            .labelStyle(FlairLabelStyle())
        }
        if person.bannedFromInstance {
            banFlairView(person: person)
        }
    }
    
    @ViewBuilder
    func banFlairView(person: Person) -> some View {
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
    func dateLabel(person: Person) -> some View {
        ProfileDateView(profilable: person)
            .padding(.horizontal, Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func personContent(person: Person) -> some View {
        Section {
            switch selectedTab {
            case .communities:
                communitiesTab(person: person)
            default:
                if let feedLoader {
                    if isProfileTab, selectedTab == .overview || selectedTab == .posts {
                        Button("New Post", icon: .general.add) {
                            navigation.openSheet(.createPost(community: nil, type: nil, feedLoader: feedLoader))
                        }
                        .buttonStyle(.capsule)
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                    }
                    PersonContentGridView(feedLoader: .singleSourceMixed(feedLoader, contentType: selectedContentType))
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
                        person.postCount.value ?? 0
                    case .comments:
                        person.commentCount.value ?? 0
                    case .communities:
                        person.moderatedCommunities.value?.count ?? 0
                    default:
                        nil
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    func communitiesTab(person: Person) -> some View {
        VStack(spacing: Constants.main.halfSpacing) {
            ForEach(person.moderatedCommunities.value ?? [], id: \.actorId) { community in
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
