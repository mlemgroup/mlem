//
//  CommunityResultView.swift
//  Mlem
//
//  Created by Sjmarf on 26/08/2023.
//

import SwiftUI

struct CommunityResultView: View {
    @EnvironmentObject var searchModel: SearchModel
    @Environment(\.navigationPath) private var navigationPath
    
    let community: APICommunityView

    var body: some View {
        Button {
            navigationPath.wrappedValue.append(CommunityLinkWithContext(community: community.community, feedType: .subscribed))
        } label: {
            HStack(spacing: 15) {
                CommunityAvatarView(community: community.community, avatarSize: 36)
                VStack(alignment: .leading, spacing: 0) {
                    SearchResultTextView(community.community.name, highlight: searchModel.input)
                        .lineLimit(1)
                    if let host = community.community.actorId.host() {
                        Text("@\(host)")
                            .foregroundStyle(.tertiary)
                            .font(.footnote)
                            .lineLimit(1)
                    }
                }
                Spacer()
                HStack {
                    Text("\(community.counts.subscribers)")
                    Image(systemName: community.subscribed != .notSubscribed ? "checkmark": "person.fill")
                }
                .foregroundStyle(community.subscribed != .notSubscribed ? .green : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                searchModel.addFilter(.community(community))
            } label: {
                Label("Add filter", systemImage: "plus")
            }
        }
    }
}
