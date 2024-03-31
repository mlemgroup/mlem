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
    let resolve: () -> Void
    
    var body: some View {
        Button {
            resolve()
        } label: {
            Image(systemName: resolved ? Icons.resolveFill : Icons.resolve)
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .foregroundStyle(resolved ? .white : .primary)
                .padding(AppConstants.barIconPadding)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(resolved ? .green : .clear))
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }
    }
}
