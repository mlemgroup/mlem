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
    
    var body: some View {
        Image(systemName: Icons.communityBan)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
            .padding(AppConstants.barIconPadding)
            .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(banned ? .red : .clear))
            .padding(AppConstants.standardSpacing)
            .contentShape(Rectangle())
    }
}
