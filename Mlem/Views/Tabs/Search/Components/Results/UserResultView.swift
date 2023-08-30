//
//  UserResultView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct UserResultView: View {
    @EnvironmentObject var searchModel: SearchModel
    @Environment(\.navigationPath) private var navigationPath
    
    let user: APIPersonView
    
    var body: some View {
        Button {
            navigationPath.wrappedValue.append(user.person)
        } label: {
            HStack(spacing: 15) {
                UserAvatarView(user: user.person, avatarSize: 36)
                VStack(alignment: .leading, spacing: 0) {
                    SearchResultTextView(user.person.name, highlight: searchModel.input)
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
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                searchModel.addFilter(.user(user))
            } label: {
                Label("Add filter", systemImage: "plus")
            }
        }
    }
}
