//
//  PersonView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-08.
//

import Actions
import ComponentViews
import Flow
import Icons
import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

extension PersonView {
    @ViewBuilder
    func bio(person: Person) -> some View {
        if let bio = person.description {
            VStack(spacing: Constants.main.standardSpacing) {
                let blocks: [BlockNode] = .init(bio)
                if blocks.isSimpleParagraphs, bio.count < 300, blocks.links.isEmpty {
                    MarkdownText(blocks, configuration: .default(palette: palette))
                        .multilineTextAlignment(.center)
                    dateLabel(person: person)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    MarkdownWithLinkList(blocks)
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
                    Label("Mlem Developer", icon: .lemmy.developerFlair)
                        .symbolVariant(.fill)
                        .tint(.themedColorfulAccent(4))
                }
                if person.isAdmin.value ?? false {
                    Label("\(person.host) Administrator", icon: .lemmy.administration)
                        .symbolVariant(.fill)
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

    @ViewBuilder
    var sortPicker: some View {
        Menu("Sort", icon: sort.icon) {
            ForEach(PersonContentSortType.allCases, id: \.self) { item in
                Toggle(
                    item.label,
                    icon: item.icon,
                    isOn: .init(
                        get: { sort == item },
                        set: { _ in
                            self.sort = item
                            Task { @MainActor in
                                do {
                                    try await feedLoader?.changeSortType(to: item, forceRefresh: false)
                                } catch {
                                    handleError(error)
                                }
                            }
                        }
                    )
                )
            }
        }
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
