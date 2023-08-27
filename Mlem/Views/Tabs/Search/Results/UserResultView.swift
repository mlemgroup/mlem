//
//  UserResultView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct UserResultView: View {
    let user: APIPersonView
    let highlight: String
    
    @Environment(\.navigationPath) private var navigationPath
    
    var body: some View {
        Button {
            navigationPath.wrappedValue.append(user.person)
        } label: {
            HStack(spacing: 15) {
                UserAvatarView(user: user.person, avatarSize: 36)
                VStack(alignment: .leading, spacing: 0) {
                    HighlightedResultText(user.person.name, highlight: highlight)
                        .lineLimit(1)
                    if let host = user.person.actorId.host() {
                        Text("@\(host)")
                            .foregroundStyle(.tertiary)
                            .font(.footnote)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {} label: {
                Label("Add filter", systemImage: "plus")
            }
        }
    }
}
