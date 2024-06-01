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
    @State var selectedTab: Tab = .overview
    @State var isAtTop: Bool = true
    
    var body: some View {
        ContentLoader(model: person) { person in
            FancyScrollView(isAtTop: $isAtTop) {
                VStack(spacing: AppConstants.standardSpacing) {
                    ProfileHeaderView(person, type: .person)
                        .padding(.horizontal, AppConstants.standardSpacing)
                    bio(person: person)
                    personContent(person: person)
                }
            }
            .navigationTitle(isAtTop ? "" : (person.displayName_ ?? person.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarEllipsisMenu {
                        Button("Edit", systemImage: Icons.edit) {}
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func bio(person: any Person) -> some View {
        if let bio = person.description_ {
            Divider()
            VStack(spacing: AppConstants.standardSpacing) {
                let blocks: [BlockNode] = .init(bio)
                if blocks.isSimpleParagraphs {
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
    func personContent(person: any Person) -> some View {
        BubblePicker(
            Tab.allCases,
            selected: $selectedTab,
            withDividers: [.top, .bottom],
            label: \.label,
            value: { tab in
                switch tab {
                case .posts:
                    person.postCount_ ?? 0
                case .comments:
                    person.commentCount_ ?? 0
                case .communities:
                    person.moderatedCommunities_?.count ?? 0
                default:
                    nil
                }
            }
        )
        Text("Footer")
            .padding(.top, 1000)
    }
}
