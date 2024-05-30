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
    
    @State var person: any PersonStubProviding
    @State var selectedTab: Tab = .overview
    @State var isAtTop: Bool = true
    
    var body: some View {
        FancyScrollView(isAtTop: $isAtTop) {
            VStack(spacing: AppConstants.standardSpacing) {
                ProfileHeaderView(person as? any Profile1Providing, type: .person)
                    .padding(.horizontal, AppConstants.standardSpacing)
                bio
                personContent
            }
        }
        .navigationTitle(isAtTop ? "" : person.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var bio: some View {
        if let bio = person.description_ {
            Divider()
            
            let blocks: [BlockNode] = .init(bio)
            Group {
                // If there is only a single paragraph, render it centered
                if let first = blocks.first, case let .paragraph(inlines) = first {
                    InlineMarkdown(inlines, configuration: .default)
                        .multilineTextAlignment(.center)
                    
                } else {
                    Markdown(blocks)
                }
            }
            .padding(AppConstants.standardSpacing)
        }
    }
    
    @ViewBuilder
    var personContent: some View {
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
