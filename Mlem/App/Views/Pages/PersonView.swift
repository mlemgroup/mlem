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
            VStack(spacing: AppConstants.standardSpacing) {
                let blocks: [BlockNode] = .init(bio)
                if blocks.isSimpleParagraphs {
                    Text(blocks, configuration: .default)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppConstants.standardSpacing)
                    dateLabel
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Markdown(blocks)
                        .padding(.horizontal, AppConstants.standardSpacing)
                    dateLabel
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top, AppConstants.halfSpacing)
        } else {
            dateLabel
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    var dateLabel: some View {
        if let person = person as? any Person1Providing {
            ProfileDateView(profilable: person)
                .padding(.horizontal, AppConstants.standardSpacing)
                .padding(.vertical, 2)
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
