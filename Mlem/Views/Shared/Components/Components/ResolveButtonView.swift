//
//  ResolveButtonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-29.
//

import Foundation
import SwiftUI

struct ResolveButtonView: View {
    let resolved: Bool
    let resolve: () async -> Void
    
    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await resolve()
            }
        } label: {
            Image(systemName: resolved ? Icons.resolveFill : Icons.resolve)
                .resizable()
                .scaledToFit()
                .foregroundStyle(resolved ? .white : .primary)
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(resolved ? .green : .clear))
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
