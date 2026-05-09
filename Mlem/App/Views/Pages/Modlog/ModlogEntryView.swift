//
//  ModlogEntryView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

// swiftlint:disable:next type_body_length
struct ModlogEntryView: View {
    @Environment(\.palette) var palette
    @Environment(\.navigation) var navigation
    
    let entry: ModlogEntry
    var targetCommunity: Community?
    @State private var id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            headerView
            contentView
            HStack(spacing: 5) {
                Image(icon: .general.time)
                Text(entry.created.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.footnote)
            .foregroundStyle(.themedSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
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
                    Image(icon: entry.type.icon)
                        .foregroundStyle(entry.type.color)
                }
            Text(headerText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .imageScale(.small)
        .symbolVariant(.fill)
    }
    
    var headerText: LocalizedStringKey {
        if let moderator = entry.moderator {
            let userText = moderator.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? entry.type.community,
                font: .footnote,
                palette: palette
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
        case let .removeComment(comment, creator: _, post: _, community: community, removed: _, reason: reason):
            reasonView(reason)
            commentLink(comment: comment, community: community)
        case let .purgeComment(reason: reason):
            reasonView(reason)
        case let .removeCommunity(community, removed: _, reason: reason):
            reasonView(reason)
            FullyQualifiedLinkView(community, labelStyle: .medium)
        case let .purgeCommunity(reason: reason):
            reasonView(reason)
        case let .hideCommunity(community, hidden: _, reason: reason):
            reasonView(reason)
            FullyQualifiedLinkView(community, labelStyle: .medium)
        case let .transferCommunityOwnership(person: person, community: community):
            transferCommunityView(person: person, community: community)
        case let .updatePersonModeratorStatus(person: person, community: community, appointed: appointed):
            updatePersonModeratorStatusView(person: person, community: community, appointed: appointed)
        case let .updatePersonAdminStatus(person: person, appointed: appointed):
            updatePersonModeratorStatusView(person: person, community: nil, appointed: appointed)
        case let .banPersonFromCommunity(person: person, community: community, banned: banned, reason: reason, expires: expires):
            reasonView(reason)
            banPersonView(person: person, community: community, banned: banned, expires: expires)
        case let .banPersonFromInstance(person: person, banned: banned, reason: reason, expires: expires):
            reasonView(reason)
            banPersonView(person: person, community: nil, banned: banned, expires: expires)
        case let .purgePerson(reason: reason):
            reasonView(reason)
        }
    }
    
    @ViewBuilder
    func banPersonView(person: Person, community: Community?, banned: Bool, expires: Date?) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            let userText = person.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? community,
                font: .subheadline,
                palette: palette
            )
            let targetText: Text
            if let community {
                targetText = community.nameTextView(
                    showFlairs: true,
                    showInstance: true,
                    font: .subheadline,
                    palette: palette
                )
            } else {
                targetText = Text("Instance")
            }
            if banned {
                let expiresText = expires?.formatted(date: .abbreviated, time: .omitted) ?? "Never"
                return Text("Banned: \(userText)\nFrom: \(targetText)\nExpires: \(expiresText)")
            } else {
                return Text("Unbanned: \(userText)\nFrom: \(targetText)")
            }
        }
        .imageScale(.small)
        .symbolVariant(.fill)
        .foregroundStyle(.themedSecondary)
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func transferCommunityView(
        person: Person,
        community: Community
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            let userText = person.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? community,
                font: .subheadline,
                palette: palette
            )
            let communityText = community.nameTextView(
                showFlairs: true,
                showInstance: true,
                font: .subheadline,
                palette: palette
            )
            Text("Community: \(communityText)\nNew Owner: \(userText)")
                .imageScale(.small)
        }
        .foregroundStyle(.themedSecondary)
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func updatePersonModeratorStatusView(
        person: Person,
        community: Community?,
        appointed: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            let userText = person.nameTextView(
                showFlairs: true,
                showInstance: true,
                communityContext: targetCommunity ?? community,
                font: .subheadline,
                palette: palette
            )
            if let community {
                let communityText = community.nameTextView(
                    showFlairs: true,
                    showInstance: true,
                    font: .subheadline,
                    palette: palette
                )
                Text(
                    appointed ? "Appointed: \(userText)\nTo: \(communityText)" : "Removed: \(userText)\nFrom: \(communityText)"
                )
            } else {
                Text(appointed ? "Appointed: \(userText)" : "Removed: \(userText)")
            }
        }
        .foregroundStyle(.themedSecondary)
        .imageScale(.small)
        .symbolVariant(.fill)
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.main.standardSpacing)
        .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func reasonView(_ reason: String?) -> some View {
        if let reason {
            Text("Reason:").foregroundStyle(.secondary) + Text(verbatim: " \(reason)")
        } else {
            Text("No reason given")
                .foregroundStyle(.secondary)
                .italic()
        }
    }
    
    @ViewBuilder
    func postLink(post: Post?, community: Community) -> some View {
        if let post {
            NavigationLink(.post(post)) {
                FooterLinkView(title: post.title, subtitle: community.fullNameWithPrefix)
            }
            .id("\(id)_modlog_footer")
        } else {
            unavailableView()
            communityLink(community: community)
        }
    }
    
    @ViewBuilder
    func commentLink(comment: Comment?, community: Community?) -> some View {
        if let comment {
            NavigationLink(.comment(comment, exposeRemovedContent: true)) {
                VStack {
                    Text(comment.content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                }
                .foregroundStyle(.themedSecondary)
                .padding(Constants.main.standardSpacing)
                .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
            }
            .id("\(id)_modlog_footer")
        } else {
            unavailableView()
            if let community {
                communityLink(community: community)
            }
        }
    }

    @ViewBuilder
    func unavailableView() -> some View {
            HStack {
                Text("Post unavailable")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .italic()
                Spacer()
                Button("More info", icon: .settings.ask) {
                    navigation?.openSheet(.unavailableContentInfo)
                }
                .labelStyle(.iconOnly)
            }
            .foregroundStyle(.themedSecondary)
            .padding(Constants.main.standardSpacing)
            .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }

    @ViewBuilder
    func communityLink(community: Community) -> some View {
        NavigationLink(.community(community, visitContext: .other)) {
            VStack {
                Text(community.fullNameWithPrefix)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
            }
            .foregroundStyle(.themedSecondary)
            .padding(Constants.main.standardSpacing)
            .background(.themedTertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
        .id("\(id)_modlog_footer")
    }
}
