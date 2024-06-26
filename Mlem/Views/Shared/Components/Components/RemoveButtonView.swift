//
//  RemoveButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Foundation
import SwiftUI

struct RemoveButtonView: View {
    let removed: Bool
    let remove: () -> Void
    
    var body: some View {
        Button {
            remove()
        } label: {
            Image(systemName: removed ? Icons.removeFill : Icons.remove)
                .resizable()
                .scaledToFit()
                .foregroundStyle(removed ? .white : .primary)
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(removed ? .red : .clear))
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
