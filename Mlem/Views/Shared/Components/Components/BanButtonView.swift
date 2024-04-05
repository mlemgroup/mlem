//
//  BanButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Foundation
import SwiftUI

struct BanButtonView: View {
    let banned: Bool
    let iconName: String
    let iconNameFill: String
    let ban: () -> Void
    
    init(banned: Bool, instanceBan: Bool, ban: @escaping () -> Void) {
        self.banned = banned
        if instanceBan {
            self.iconName = Icons.instanceBan
            self.iconNameFill = Icons.instanceBanned
        } else {
            self.iconName = Icons.communityBan
            self.iconNameFill = Icons.communityBanFill
        }
        self.ban = ban
    }
    
    var body: some View {
        Button {
            ban()
        } label: {
            Image(systemName: banned ? iconNameFill : iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(banned ? .white : .primary)
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(banned ? .red : .clear))
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }.transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
