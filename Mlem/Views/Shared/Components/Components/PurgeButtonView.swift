//
//  PurgeButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Foundation
import SwiftUI

struct PurgeButtonView: View {
    let purged: Bool
    let purge: () -> Void
    
    var body: some View {
        Button {
            purge()
        } label: {
            Image(systemName: Icons.purge)
                .resizable()
                .scaledToFit()
                .foregroundStyle(purged ? .white : .primary)
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(purged ? .black : .clear))
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }
    }
}
