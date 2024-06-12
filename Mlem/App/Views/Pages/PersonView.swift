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
        var label: String { rawValue.capitalized }
    }
    
    @State var person: AnyPerson
    @State private var selectedTab: Tab = .overview
    @State private var isAtTop: Bool = true
    
    // This will a post tracker in future - this is just a proof-of-concept for post loading
    @State var posts: [Post2] = []
    
    var body: some View {
        if #available(iOS 17.1, *) {
            Self._printChanges()
        }
        return ContentLoader(model: person) { person, isLoading in
            // print("REFRESH", posts.count)
            content(person: person)
                .externalApiWarning(entity: person, isLoading: isLoading)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if person is any Person3Providing, isLoading {
                            ProgressView()
                        } else {
                            ToolbarEllipsisMenu {}
                        }
                    }
                }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api) { entity in
                if let entity = entity as? any Person1Providing {
                    let response = try await entity.getPosts(page: 1, limit: 3)
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
        FancyScrollView(isAtTop: $isAtTop) {
            VStack(spacing: AppConstants.standardSpacing) {
                ProfileHeaderView(person, type: .person)
                    .padding(.horizontal, AppConstants.standardSpacing)
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
            VStack(spacing: AppConstants.standardSpacing) {
                let blocks: [BlockNode] = .init(bio)
                if blocks.isSimpleParagraphs, bio.count < 300 {
                    MarkdownText(blocks, configuration: .default)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppConstants.standardSpacing)
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Markdown(blocks, configuration: .default)
                        .padding(.horizontal, AppConstants.standardSpacing)
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top, AppConstants.halfSpacing)
        } else {
            dateLabel(person: person)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    func dateLabel(person: any Person) -> some View {
        ProfileDateView(profilable: person)
            .padding(.horizontal, AppConstants.standardSpacing)
            .padding(.vertical, 2)
    }
    
    @ViewBuilder
    func personContent(person: any Person3Providing) -> some View {
        VStack {
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
            ForEach(posts, id: \.id) { post in
                Text(post.title)
                // FeedPostView(post: post)
                Divider()
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
