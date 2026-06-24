//
//  PostInfoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-06-23.
//

import SwiftUI
import MlemMiddleware

private struct InfoEntry {
    let title: LocalizedStringResource
    let value: CustomStringConvertible?
    let copyable: Bool
    
    init(_ title: LocalizedStringResource, value: CustomStringConvertible?, copyable: Bool = true) {
        self.title = title
        self.value = value
        self.copyable = copyable
    }
}

struct PostInfoView: View {
    @Environment(\.locale) var locale
    
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
                    entry(.init("Created", value: post.created))
                    entry(.init("Last Updated", value: post.updated))
                    entry(.init("Language", value: language))
                    entry(.init("NSFW", value: post.nsfw, copyable: false))
                    entry(.init("Deleted", value: post.deleted, copyable: false))
                    entry(.init("Removed", value: post.removed, copyable: false))
                    entry(.init("Locked", value: post.locked, copyable: false))
                    entry(.init("Pinned to Community", value: post.pinnedCommunity, copyable: false))
                    entry(.init("Pinned to Instance", value: post.pinnedInstance, copyable: false))
                }
                
                section {
                    entry(.init("Title", value: post.title))
                    if let creator = post.creator.value,
                       let creatorIsModerator = post.creatorIsModerator.value,
                       let creatorIsAdmin = post.creatorIsAdmin.value,
                       let creatorBannedFromCommunity = post.creatorBannedFromCommunity.value {
                        entry(.init("Creator", value: creator.actorId), subEntries: [
                            .init("ID", value: post.creatorId),
                            .init("Moderator", value: creatorIsModerator),
                            .init("Admin", value: creatorIsAdmin),
                            .init("Banned from community", value: creatorBannedFromCommunity)
                        ])
                    }
                    ExpectedView(post.community) { community in
                        entry(.init("Community", value: community.actorId), subEntries: [
                            .init("ID", value: post.communityId)
                        ])
                    }
                    entry(.init("Content", value: post.content))
                    entry(.init("Link URL", value: post.linkUrl))
                    entry(.init("Thumbnail URL", value: post.thumbnailUrl))
                    embed(post.embed)
                    poll(post.poll)
                    entry(.init("Alt Text", value: post.altText))
                }
                
                section {
                    entry(.init("Local ID", value: post.id))
                    entry(.init("Actor ID", value: post.actorId))
                }
            }
            .padding(.top, 16)
        }
        .presentationBackground(.themedGroupedBackground)
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled)
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
    
    private func entry(_ entry: InfoEntry, subEntries: [InfoEntry] = []) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title).fontWeight(.semibold)
            if let value = entry.value {
                if value.description.isEmpty {
                    Text("Empty").foregroundStyle(.themedSecondary)
                } else {
                    Button {
                        if entry.copyable {
                            UIPasteboard.general.string = "\(value)"
                            ToastModel.main.add(.success("Copied"))
                        }
                    } label: {
                        Text(verbatim: "\(value)")
                    }
                    .contentShape(.rect)
                    .buttonStyle(.plain)
                }
            } else {
                Text("None")
                    .foregroundStyle(.themedSecondary)
            }
            
            ForEach(subEntries, id: \.title.key) { subEntry in
                Text("\(Image(systemName: "arrow.turn.down.right")) ").foregroundStyle(.themedSecondary) +
                Text(subEntry.title) +
                Text(": ") +
                subEntryValue(subEntry)
            }
        }
        .font(.subheadline)
    }
    
    private func subEntryValue(_ subEntry: InfoEntry) -> Text {
        if let value = subEntry.value {
            return Text(verbatim: "\(value)")
        }
        return Text("None")
            .foregroundStyle(.themedSecondary)
    }
    
    @ViewBuilder
    private func embed(_ embed: PostEmbed?) -> some View {
        if let embed {
            entry(.init("Embedded Content", value: embed.title ?? "Untitled"), subEntries: [
                .init("Description", value: embed.description),
                .init("Video URL", value: embed.videoUrl)
            ])
        } else {
            entry(.init("Embedded Content", value: nil))
        }
    }
    
    @ViewBuilder
    private func poll(_ poll: PostPoll?) -> some View {
        if let poll {
            entry(.init("Poll", value: poll.type.description), subEntries: [
                .init("End date", value: poll.endDate),
                .init("Local only", value: poll.localOnly),
                .init("Latest vote", value: poll.latestVote)
            ])
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
