//
//  ModlogEntryView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogEntryView: View {
    @Environment(Palette.self) var palette
    
    let entry: ModlogEntry
    var targetCommunity: (any Community)?
    @State private var id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            headerView
            contentView
            HStack(spacing: 5) {
                Image(systemName: Icons.time)
                Text(entry.created.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.footnote)
            .foregroundStyle(palette.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .environment(\.communityContext, entry.type.community)
    }
    
    @ViewBuilder
    var headerView: some View {
        HStack(spacing: Constants.main.standardSpacing) {
            Circle()
                .fill(entry.type.color.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay {
                    Image(systemName: entry.type.systemImage)
                        .imageScale(.small)
                        .symbolVariant(.fill)
                        .foregroundStyle(entry.type.color)
                }
            Text(headerText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .imageScale(.small)
        }
    }
    
    var headerText: LocalizedStringKey {
        if let moderator = entry.moderator {
            let userText = moderator.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? entry.type.community,
                font: .footnote
            )
            return entry.type.label(userText: userText)
        }
        return entry.type.label(userText: nil)
    }
    
    @ViewBuilder
    var contentView: some View {
        switch entry.type {
        case let .removePost(post, community: community, removed: _, reason: reason):
            reasonView(reason)
            postLink(post: post, community: community)
        case let .lockPost(post, community: community, locked: _):
            postLink(post: post, community: community)
        case let .pinPost(post, community: community, pinned: _, type: _):
            postLink(post: post, community: community)
        case let .purgePost(reason: reason):
            reasonView(reason)
        case let .removeComment(comment, creator: _, post: _, community: _, removed: _, reason: reason):
            reasonView(reason)
            commentLink(comment: comment)
        case let .purgeComment(reason: reason):
            reasonView(reason)
        case let .removeCommunity(community, removed: _, reason: reason):
            reasonView(reason)
            FullyQualifiedLinkView(entity: community, labelStyle: .medium, showAvatar: true)
        case let .purgeCommunity(reason: reason):
            reasonView(reason)
        case let .hideCommunity(community, hidden: _, reason: reason):
            reasonView(reason)
            FullyQualifiedLinkView(entity: community, labelStyle: .medium, showAvatar: true)
        case let .transferCommunityOwnership(person: person, community: community):
            transferCommunityView(person: person, community: community)
        case let .updatePersonModeratorStatus(person: person, community: community, appointed: appointed):
            updatePersonModeratorStatusView(person: person, community: community, appointed: appointed)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func transferCommunityView(
        person: Person1,
        community: Community1
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            let userText = person.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? entry.type.community,
                font: .footnote
            )
            FullyQualifiedLinkView(entity: community, labelStyle: .small, showAvatar: true)
            HStack(spacing: Constants.main.halfSpacing) {
                Image(systemName: Icons.transferCommunity)
                Text("Now owned by \(userText)")
                    .lineLimit(1)
                    .imageScale(.small)
            }
            .foregroundStyle(palette.secondary)
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func updatePersonModeratorStatusView(
        person: Person1,
        community: Community1,
        appointed: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            let userText = person.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? entry.type.community,
                font: .footnote
            )
            FullyQualifiedLinkView(entity: community, labelStyle: .small, showAvatar: true)
            HStack(spacing: Constants.main.halfSpacing) {
                Image(systemName: appointed ? "plus.circle.fill" : "minus.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(appointed ? palette.positive : palette.negative)
                    .fontWeight(.semibold)
                Text(appointed ? "Appointed \(userText)" : "Removed \(userText)")
                    .foregroundStyle(palette.secondary)
                    .lineLimit(1)
                    .imageScale(.small)
            }
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func reasonView(_ reason: String?) -> some View {
        if let reason {
            Text("Reason: ").foregroundStyle(.secondary) + Text(reason)
        } else {
            Text("No reason given")
                .foregroundStyle(.secondary)
                .italic()
        }
    }
    
    @ViewBuilder
    func postLink(post: any Post, community: any Community) -> some View {
        NavigationLink(.post(post)) {
            FooterLinkView(title: post.title, subtitle: community.fullNameWithPrefix)
        }
        .id("\(id)_modlog_footer")
    }
    
    @ViewBuilder
    func commentLink(comment: Comment1) -> some View {
        NavigationLink(.comment(comment)) {
            VStack {
                Text(comment.content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
            }
            .foregroundStyle(palette.secondary)
            .padding(Constants.main.standardSpacing)
            .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
        .id("\(id)_modlog_footer")
    }
}
