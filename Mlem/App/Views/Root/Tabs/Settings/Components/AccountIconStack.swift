//
//  AccountIconStack.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import SwiftUI

struct AccountIconStack: View {
    let accounts: [any UserProviding]
    
    let avatarSize: CGFloat
    let spacing: CGFloat
    let outlineWidth: CGFloat
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            HStack {
                ForEach(accounts, id: \.id) { account in
                    AvatarView(
                        url: account.avatarUrl,
                        type: .person,
                        avatarSize: avatarSize,
                        lineWidth: 0,
                        iconResolution: .unrestricted
                    )
                    .padding(outlineWidth)
                    .background {
                        Circle()
                            .fill(backgroundColor)
                    }
                    .frame(maxWidth: spacing)
                }
            }
        }
    }
}
