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
    
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    @State var person: AnyPerson
    @State private var selectedTab: Tab = .overview
    @State private var isAtTop: Bool = true
    
    // This will a post tracker in future - this is just a proof-of-concept for post loading
    @State var posts: [Post2] = []
    
    var body: some View {
        content
            .onPreferenceChange(IsAtTopPreferenceKey.self, perform: { value in
                isAtTop = value
            })
    }
    
    var content: some View {
        ContentLoader(model: person) { proxy in
            if let person = proxy.entity {
                content(person: person)
                    .externalApiWarning(entity: person, isLoading: proxy.isLoading)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if person is any Person3Providing, proxy.isLoading {
                                ProgressView()
                            } else {
                                ToolbarEllipsisMenu(person.menuActions(navigation: navigation))
                            }
                        }
                    }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api) { entity in
                if let entity = entity as? any Person1Providing {
                    let response = try await entity.getContent(page: 1, limit: 3)
                    Task { @MainActor in
                        posts = response.posts
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
                ProfileHeaderView(person, fallback: .person)
                    .padding(.horizontal, Constants.main.standardSpacing)
                bio(person: person)
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
    
    // TODO: PersonContentGridView
    @ViewBuilder
    func personContent(person: any Person3Providing) -> some View {
        VStack(spacing: 0) {
            BubblePicker(
                tabs(person: person),
                selected: $selectedTab,
                withDividers: [.top, .bottom],
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

            switch selectedTab {
            case .communities:
                communitiesTab(person: person)
            default:
                ForEach(posts, id: \.id) { post in
                    FeedPostView(post: post)
                    Divider()
                }
            }
        }
    }
    
    @ViewBuilder
    func communitiesTab(person: any Person) -> some View {
        VStack(spacing: 0) {
            ForEach(person.moderatedCommunities_ ?? []) { community in
                CommunityListRow(community)
                Divider()
                    .padding(.leading, 71)
            }
        }
    }
    
    func tabs(person: any Person3Providing) -> [Tab] {
        var output: [Tab] = [.overview, .posts, .comments]
        if !person.moderatedCommunities.isEmpty {
            output.append(.communities)
        }
        return output
    }
}
