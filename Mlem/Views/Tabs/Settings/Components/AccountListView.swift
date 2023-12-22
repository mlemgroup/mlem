//
//  AccountListView.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI
import Dependencies

struct AccountListView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    var body: some View {
        ForEach(accountsTracker.savedAccounts, id: \.self) { account in
            Button { } label: {
                HStack(alignment: .center, spacing: 12) {
                    AvatarView(url: account.avatarUrl, type: .user, avatarSize: 40, iconResolution: .unrestricted)
                        .padding(.leading, -5)
                    VStack(alignment: .leading) {
                        Text(account.username)
                        if let instance = account.instanceLink.host() {
                            Text("@\(instance)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                        .imageScale(.small)
                }
                .padding(.vertical, -2)
            }
            .buttonStyle(.plain)
        }
    }
}
