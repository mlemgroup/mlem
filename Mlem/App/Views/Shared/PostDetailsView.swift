//
//  PostDetailsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-06-23.
//

import SwiftUI
import MlemMiddleware
import ComponentViews

private struct InfoEntry {
    /// Name of the entry
    let title: String
    
    /// Values, if present, associated with the entry
    let values: [CustomStringConvertible]?
    
    /// Whether entries should copy to clipboard on tap
    let copyable: Bool
    
    /// Whether `nil` indicates a contentful absence for `values` (i.e., "None" should be displayed if `values` is nil)
    let valueExpected: Bool
    
    init(_ title: LocalizedStringResource, value: CustomStringConvertible?, copyable: Bool = false, valueExpected: Bool = true) {
        self.title = .init(localized: title)
        self.values = value.map { [$0] }
        self.copyable = copyable
        self.valueExpected = valueExpected
    }
    
    init(_ title: LocalizedStringResource, values: [CustomStringConvertible]?, copyable: Bool = false, valueExpected: Bool = true) {
        self.title = .init(localized: title)
        self.values = values
        self.copyable = copyable
        self.valueExpected = valueExpected
    }
    
    init(verbatim title: String, value: CustomStringConvertible?, copyable: Bool = false, valueExpected: Bool = true) {
        self.title = title
        self.values = value.map { [$0] }
        self.copyable = copyable
        self.valueExpected = valueExpected
    }
    
    init(verbatim title: String, values: [CustomStringConvertible]?, copyable: Bool = false, valueExpected: Bool = true) {
        self.title = title
        self.values = values
        self.copyable = copyable
        self.valueExpected = valueExpected
    }
}

struct PostDetailsView: View {
    @Environment(\.locale) var locale
    @Environment(ToastModel.self) var toastModel
    
    let post: Post
    
    var language: String? {
        if let language = post.api.myInstance?.language(withId: post.languageId),
           let languageCode = language.languageCode {
            return locale.localizedString(forLanguageCode: languageCode.identifier)
        }
        return nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                section {
                    entry(.init("Local ID", value: post.id, copyable: true))
                    entry(.init("Actor ID", value: post.actorId, copyable: true))
                }
                
                section {
                    entry(.init("Created", value: post.created, copyable: true))
                    entry(.init("Last Updated", value: post.updated, copyable: true))
                    entry(.init("Language", value: language, copyable: true))
                    entry(.init("NSFW", value: post.nsfw))
                    entry(.init("Deleted", value: post.deleted))
                    entry(.init("Removed", value: post.removed))
                    entry(.init("Locked", value: post.locked))
                    entry(.init("Pinned to Community", value: post.pinnedCommunity))
                    entry(.init("Pinned to Instance", value: post.pinnedInstance))
                }
                
                section {
                    entry(.init("Title", value: post.title, copyable: true))
                    if let creator = post.creator.value,
                       let creatorIsModerator = post.creatorIsModerator.value,
                       let creatorIsAdmin = post.creatorIsAdmin.value,
                       let creatorBannedFromCommunity = post.creatorBannedFromCommunity.value,
                       let creatorBlocked = post.creatorBlocked.value {
                        entry(.init("Creator", value: creator.actorId, copyable: true), subEntries: [
                            .init("Local ID", value: post.creatorId, copyable: true),
                            .init("Moderator", value: creatorIsModerator),
                            .init("Admin", value: creatorIsAdmin),
                            .init("Banned from Community", value: creatorBannedFromCommunity),
                            .init("Blocked", value: creatorBlocked)
                        ])
                    }
                    ExpectedView(post.community) { community in
                        entry(.init("Community", value: community.actorId), subEntries: [
                            .init("Local ID", value: post.communityId)
                        ])
                    }
                    entry(.init("Content", value: post.content, copyable: true))
                    entry(.init("Link URL", value: post.linkUrl, copyable: true))
                    entry(.init("Thumbnail URL", value: post.thumbnailUrl, copyable: true))
                    embed(post.embed)
                    poll(post.poll)
                    entry(.init("Alt Text", value: post.altText, copyable: true))
                }
                
                section {
                    ExpectedView(post.commentCount) { commentCount in
                        entry(.init("Comments", value: commentCount))
                    }
                    if let commentCount = post.commentCount.value,
                       let unreadCommentCount = post.unreadCommentCount.value {
                        VStack(alignment: .leading, spacing: 2) {
                            entry(.init("Comments", value: nil, valueExpected: false))
                            entryGrid([
                                .init("Total", value: commentCount),
                                .init("Unread", value: unreadCommentCount)
                            ], isSubEntry: false)
                        }
                    }
                    ExpectedView(post.votes) { votes in
                        VStack(alignment: .leading, spacing: 2) {
                            entry(.init("Score", value: nil, valueExpected: false))
                            entryGrid([
                                .init("Total", value: votes.total),
                                .init("Upvotes", value: votes.upvotes),
                                .init("Downvotes", value: votes.downvotes),
                                .init("My vote", value: votes.myVote)
                            ], isSubEntry: false)
                        }
                    }
                    ExpectedView(post.crossPosts) { crossPosts in
                        entry(.init("Crossposts", values: crossPosts.map { $0.actorId.description }, copyable: true))
                    }
                    ExpectedView(post.saved) { saved in
                        entry(.init("Saved", value: saved))
                    }
                    ExpectedView(post.notificationsEnabled) { notificationsEnabled in
                        entry(.init("Notifications Enabled", value: notificationsEnabled))
                    }
                    ExpectedView(post.read) { read in
                        entry(.init("Read", value: read))
                    }
                    ExpectedView(post.hidden) { hidden in
                        entry(.init("Hidden", value: hidden))
                    }
                }
            }
            .padding(.top, 16)
        }
        .presentationBackground(.themedGroupedBackground)
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CloseButtonToolbarItem()
        }
    }
    
    private func section(@ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 25))
        .padding(.horizontal, 16)
    }
    
    private func entry(_ entry: InfoEntry, subEntries: [InfoEntry]? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: entry.title).fontWeight(.semibold)
            values(for: entry)
            if let subEntries {
                entryGrid(subEntries)
            }
        }
        .font(.subheadline)
    }
    
    @ViewBuilder
    private func values(for entry: InfoEntry) -> some View {
        if entry.valueExpected {
            if let values = entry.values {
                ForEach(Array(zip(values.indices, values)), id: \.0) { _, value in
                    if value.description.isEmpty {
                        Text("Empty").foregroundStyle(.themedSecondary)
                    } else {
                        Button {
                            if entry.copyable {
                                UIPasteboard.general.string = "\(value)"
                                toastModel.add(.success("Copied"))
                            }
                        } label: {
                            Text(verbatim: "\(value)")
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("None")
                    .foregroundStyle(.themedSecondary)
            }
        }
    }
    
    @ViewBuilder
    private func entryGrid(_ entries: [InfoEntry], isSubEntry: Bool = true) -> some View {
        Grid(alignment: .top, verticalSpacing: 2) {
            ForEach(Array(zip(entries.indices, entries)), id: \.0) { _, entry in
                GridRow {
                    Text(verbatim: entry.title)
                    values(for: entry)
                }
                .gridColumnAlignment(.leading)
            }
        }
        .font(isSubEntry ? .footnote : .subheadline)
        .padding(.leading, isSubEntry ? 13 : 0)
    }
    
    @ViewBuilder
    private func embed(_ embed: PostEmbed?) -> some View {
        if let embed {
            entry(.init("Embedded Content", value: embed.title ?? "Untitled", copyable: embed.title != nil), subEntries: [
                .init("Description", value: embed.description, copyable: true),
                .init("Video URL", value: embed.videoUrl, copyable: true)
            ])
        } else {
            entry(.init("Embedded Content", value: nil))
        }
    }
    
    @ViewBuilder
    private func poll(_ poll: PostPoll?) -> some View {
        if let poll {
            VStack(alignment: .leading, spacing: 2) {
                entry(.init("Poll", value: nil, valueExpected: false))
                entryGrid([
                    .init("Type", value: poll.type.description, copyable: true),
                    .init("Latest Vote", value: poll.latestVote, copyable: true),
                    .init("End Date", value: poll.endDate, copyable: true),
                    .init("Local Only", value: poll.localOnly),
                    .init("Choices", value: nil, valueExpected: false)
                ], isSubEntry: false)
                entryGrid(poll.choices.map { .init(verbatim: "\($0.voteCount ?? 0)", value: $0.label) })
            }
            .font(.subheadline)
        } else {
            entry(.init("Poll", value: nil))
        }
    }
}

private extension PostPollType {
    var description: String {
        switch self {
        case .single: "Single Response"
        case .multiple: "Multiple Response"
        }
    }
}
