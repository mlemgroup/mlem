//
//  PurgeButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Dependencies
import Foundation
import SwiftUI

struct PurgeButtonView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    let purged: Bool
    let purge: () -> Void
    
    var body: some View {
        Button {
            purge()
        } label: {
            Image(systemName: Icons.purge)
                .resizable()
                .scaledToFit()
                .foregroundStyle(purged ? Color(uiColor: .systemBackground) : .primary)
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(purged ? .primary : .clear))
                .opacity(siteInformation.isAdmin ? 1 : 0.5)
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }
        .disabled(!siteInformation.isAdmin)
    }
}
