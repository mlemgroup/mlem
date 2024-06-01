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
            .navigationTitle(isAtTop ? "" : (person.displayName_ ?? person.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // TODO:
                    ToolbarEllipsisMenu {}
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
    func personContent(person: any Person3Providing) -> some View {
        BubblePicker(
            Tab.allCases,
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
    }
}
